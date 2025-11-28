import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { League, User, Team, Notification } from "@/modules";
import { verifyAccessToken } from "@/lib/jwt";
import mongoose from "mongoose";

// Helper to convert string ID to ObjectId
function toObjectId(id: string | mongoose.Types.ObjectId): mongoose.Types.ObjectId {
  if (id instanceof mongoose.Types.ObjectId) {
    return id;
  }
  return new mongoose.Types.ObjectId(id);
}

// Helper to get token from request
function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

// Helper to verify user from token
async function verifyUser(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  return decoded;
}

// Helper to verify admin from token
async function verifyAdmin(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  if (decoded.role !== "superadmin") throw new Error("Unauthorized");
  
  return decoded;
}

/**
 * Create league (only superadmin can create)
 * POST /api/league
 */
export async function createLeague(req: NextRequest) {
  try {
    await connectDB();
    await verifyAdmin(req);
    
    const { 
      leagueName, 
      logo, 
      format, 
      startDate, 
      endDate, 
      minimumPlayers, 
      entryFeeType, 
      perPlayerLeagueFee,
      referee,
      statKeeper,
      teams,
      status
    } = await req.json();

    // Validate required fields
    if (!leagueName || !format || !startDate || !endDate || !minimumPlayers || !entryFeeType) {
      return NextResponse.json(
        { error: "League name, format, start date, end date, minimum players, and entry fee type are required" },
        { status: 400 }
      );
    }

    // Validate format enum
    if (!["5v5", "7v7"].includes(format)) {
      return NextResponse.json({ error: "Format must be either '5v5' or '7v7'" }, { status: 400 });
    }

    // Validate entryFeeType enum
    if (!["stripe", "paypal"].includes(entryFeeType)) {
      return NextResponse.json({ error: "Entry fee type must be either 'stripe' or 'paypal'" }, { status: 400 });
    }

    // Validate dates
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return NextResponse.json({ error: "Invalid date format" }, { status: 400 });
    }

    if (start >= end) {
      return NextResponse.json({ error: "End date must be after start date" }, { status: 400 });
    }

    // Validate minimum players
    if (minimumPlayers < 1) {
      return NextResponse.json({ error: "Minimum players must be at least 1" }, { status: 400 });
    }

    // Teams, referees, and stat keepers will be added via invitations, not directly
    // So we don't validate them here

    // Validate status enum
    if (status && !["active", "pending"].includes(status)) {
      return NextResponse.json({ error: "Status must be either 'active' or 'pending'" }, { status: 400 });
    }

    const leagueData: any = {
      leagueName: leagueName.trim(),
      format,
      startDate: start,
      endDate: end,
      minimumPlayers,
      entryFeeType,
      perPlayerLeagueFee: perPlayerLeagueFee || 0,
      logo: logo || "",
      status: status || "pending",
      referees: [],
      statKeepers: [],
      teams: [],
    };

    const league = await League.create(leagueData);
    const leagueId = (league as any)._id.toString();

    // Populate related fields
    const populatedLeague = await League.findById(leagueId)
      .populate("referees", "firstName lastName email role")
      .populate("statKeepers", "firstName lastName email role")
      .populate("teams", "teamName enterCode location skillLevel");

    // Ensure the _id is included as a string in the response
    const responseData = {
      ...(populatedLeague as any).toObject(),
      _id: leagueId,
      id: leagueId
    };

    return NextResponse.json(
      {
        message: "League created successfully",
        data: responseData,
      },
      { status: 201 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to create league" }, { status: 500 });
  }
}

/**
 * Get all leagues (with optional filters)
 * GET /api/league?status=active&format=5v5
 */
export async function getAllLeagues(req: NextRequest) {
  try {
    await connectDB();
    await verifyUser(req);

    const { searchParams } = new URL(req.url);
    const status = searchParams.get("status");
    const format = searchParams.get("format");

    let query: any = {};
    
    if (status) {
      if (!["active", "pending"].includes(status)) {
        return NextResponse.json({ error: "Invalid status filter" }, { status: 400 });
      }
      query.status = status;
    }

    if (format) {
      if (!["5v5", "7v7"].includes(format)) {
        return NextResponse.json({ error: "Invalid format filter" }, { status: 400 });
      }
      query.format = format;
    }

    const leagues = await League.find(query)
      .populate("referees", "firstName lastName email role")
      .populate("statKeepers", "firstName lastName email role")
      .populate("teams", "teamName enterCode location skillLevel")
      .sort({ createdAt: -1 })
      .exec();

    // Automatically set status based on start date
    const currentDate = new Date();
    const leaguesWithStatus = leagues.map((league: any) => {
      const leagueObj = league.toObject();
      const startDate = new Date(leagueObj.startDate);
      
      // If start date has passed, set to active, otherwise pending
      leagueObj.status = startDate <= currentDate ? "active" : "pending";
      
      return leagueObj;
    });

    return NextResponse.json(
      {
        message: "Leagues retrieved successfully",
        data: leaguesWithStatus,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get leagues" }, { status: 500 });
  }
}

/**
 * Get league by ID
 * GET /api/league/:id
 */
export async function getLeague(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const leagueId = toObjectId(id);

    const league = await League.findById(leagueId)
      .populate("referees", "firstName lastName email role")
      .populate("statKeepers", "firstName lastName email role")
      .populate("teams", "teamName enterCode location skillLevel");

    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Automatically set status based on start date
    const leagueObj = (league as any).toObject();
    const currentDate = new Date();
    const startDate = new Date(leagueObj.startDate);
    
    // If start date has passed, set to active, otherwise pending
    leagueObj.status = startDate <= currentDate ? "active" : "pending";

    return NextResponse.json(
      {
        message: "League retrieved successfully",
        data: leagueObj,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get league" }, { status: 500 });
  }
}

/**
 * Update league
 * PUT /api/league/:id
 */
export async function updateLeague(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id } = params;
    const leagueId = toObjectId(id);
    const {
      leagueName,
      logo,
      format,
      startDate,
      endDate,
      minimumPlayers,
      entryFeeType,
      perPlayerLeagueFee,
      teams,
      status,
    } = await req.json();

    const league = await League.findById(leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    if (leagueName !== undefined) {
      (league as any).leagueName = leagueName.trim();
    }

    if (logo !== undefined) {
      (league as any).logo = logo;
    }

    if (format !== undefined) {
      if (!["5v5", "7v7"].includes(format)) {
        return NextResponse.json({ error: "Format must be either '5v5' or '7v7'" }, { status: 400 });
      }
      (league as any).format = format;
    }

    if (startDate !== undefined) {
      const start = new Date(startDate);
      if (isNaN(start.getTime())) {
        return NextResponse.json({ error: "Invalid start date format" }, { status: 400 });
      }
      (league as any).startDate = start;
    }

    if (endDate !== undefined) {
      const end = new Date(endDate);
      if (isNaN(end.getTime())) {
        return NextResponse.json({ error: "Invalid end date format" }, { status: 400 });
      }
      (league as any).endDate = end;
    }

    // Validate date range if both dates are being updated
    if (startDate !== undefined || endDate !== undefined) {
      const start = (league as any).startDate;
      const end = (league as any).endDate;
      if (start >= end) {
        return NextResponse.json({ error: "End date must be after start date" }, { status: 400 });
      }
    }

    if (minimumPlayers !== undefined) {
      if (minimumPlayers < 1) {
        return NextResponse.json({ error: "Minimum players must be at least 1" }, { status: 400 });
      }
      (league as any).minimumPlayers = minimumPlayers;
    }

    if (entryFeeType !== undefined) {
      if (!["stripe", "paypal"].includes(entryFeeType)) {
        return NextResponse.json({ error: "Entry fee type must be either 'stripe' or 'paypal'" }, { status: 400 });
      }
      (league as any).entryFeeType = entryFeeType;
    }

    if (perPlayerLeagueFee !== undefined) {
      (league as any).perPlayerLeagueFee = perPlayerLeagueFee;
    }

    // Teams, referees, and stat keepers are managed via invitations, not direct updates
    // They can only be added/removed through the invitation accept/reject flow

    if (status !== undefined) {
      if (!["active", "pending"].includes(status)) {
        return NextResponse.json({ error: "Status must be either 'active' or 'pending'" }, { status: 400 });
      }
      (league as any).status = status;
    }

    await league.save();

    // Populate before returning
    const populatedLeague = await League.findById(leagueId)
      .populate("referees", "firstName lastName email role")
      .populate("statKeepers", "firstName lastName email role")
      .populate("teams", "teamName enterCode location skillLevel");

    return NextResponse.json(
      {
        message: "League updated successfully",
        data: populatedLeague,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to update league" }, { status: 500 });
  }
}

/**
 * Delete league
 * DELETE /api/league/:id
 */
export async function deleteLeague(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id } = params;
    const leagueId = toObjectId(id);

    const league = await League.findById(leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    await League.findByIdAndDelete(leagueId);

    return NextResponse.json({ message: "League deleted successfully" }, { status: 200 });
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to delete league" }, { status: 500 });
  }
}

/**
 * Add team to league
 * POST /api/league/:id/teams
 * Body: { teamId: string }
 */
export async function addTeamToLeague(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id } = params;
    const leagueId = toObjectId(id);
    const { teamId } = await req.json();

    if (!teamId) {
      return NextResponse.json({ error: "Team ID is required" }, { status: 400 });
    }

    const league = await League.findById(leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    const team = await Team.findById(teamId);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    const teams = (league as any).teams || [];
    
    // Check if team is already in the league
    if (teams.some((t: any) => t.toString() === teamId)) {
      return NextResponse.json({ error: "Team already in league" }, { status: 409 });
    }

    teams.push(teamId);
    (league as any).teams = teams;
    await league.save();

    const populatedLeague = await League.findById(leagueId)
      .populate("referees", "firstName lastName email role")
      .populate("statKeepers", "firstName lastName email role")
      .populate("teams", "teamName enterCode location skillLevel");

    return NextResponse.json(
      {
        message: "Team added to league successfully",
        data: populatedLeague,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to add team to league" }, { status: 500 });
  }
}

/**
 * Remove team from league
 * DELETE /api/league/:id/teams/:teamId
 */
export async function removeTeamFromLeague(req: NextRequest, { params }: { params: { id: string; teamId: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id, teamId } = params;
    const leagueId = toObjectId(id);

    const league = await League.findById(leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    const teams = (league as any).teams || [];
    
    // Check if team is in the league
    if (!teams.some((t: any) => t.toString() === teamId)) {
      return NextResponse.json({ error: "Team not in league" }, { status: 404 });
    }

    (league as any).teams = teams.filter((t: any) => t.toString() !== teamId);
    await league.save();

    const populatedLeague = await League.findById(leagueId)
      .populate("referees", "firstName lastName email role")
      .populate("statKeepers", "firstName lastName email role")
      .populate("teams", "teamName enterCode location skillLevel");

    return NextResponse.json(
      {
        message: "Team removed from league successfully",
        data: populatedLeague,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to remove team from league" }, { status: 500 });
  }
}

/**
 * Invite referee to league
 * POST /api/league/:id/invite-referee
 * Body: { refereeId: string }
 */
export async function inviteRefereeToLeague(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyAdmin(req);

    const { id } = params;
    const { refereeId } = await req.json();

    console.log("inviteRefereeToLeague - League ID:", id);
    console.log("inviteRefereeToLeague - Referee ID:", refereeId);
    console.log("inviteRefereeToLeague - League ID type:", typeof id);

    if (!id) {
      console.error("inviteRefereeToLeague - League ID is missing!");
      return NextResponse.json({ error: "League ID is required" }, { status: 400 });
    }

    if (!refereeId) {
      return NextResponse.json({ error: "Referee ID is required" }, { status: 400 });
    }

    // Convert league ID to ObjectId
    const leagueId = toObjectId(id);
    console.log("inviteRefereeToLeague - Searching for league with ID:", leagueId.toString());
    const league = await League.findById(leagueId);
    if (!league) {
      console.error("inviteRefereeToLeague - League not found with ID:", id);
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    console.log("inviteRefereeToLeague - League found:", {
      _id: (league as any)._id?.toString(),
      leagueName: (league as any).leagueName
    });

    const referee = await User.findById(refereeId);
    if (!referee) {
      return NextResponse.json({ error: "Referee not found" }, { status: 404 });
    }

    if (referee.role !== "referee") {
      return NextResponse.json({ error: "User is not a referee" }, { status: 400 });
    }

    // Check if referee is already in the league
    const referees = (league as any).referees || [];
    if (referees.some((r: any) => r.toString() === refereeId)) {
      return NextResponse.json({ error: "Referee already in league" }, { status: 409 });
    }

    // Convert IDs to ObjectIds (leagueId already converted above)
    const senderId = toObjectId(decoded.userId);
    const receiverId = toObjectId(refereeId);

    // Check if there's already a pending invite
    const existingNotification = await Notification.findOne({
      sender: senderId,
      receiver: receiverId,
      league: leagueId,
      type: "LEAGUE_REFEREE_INVITE",
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json({ error: "Invite already sent to this referee" }, { status: 409 });
    }

    // Create notification with ObjectIds
    const notification = await Notification.create({
      sender: senderId,
      receiver: receiverId,
      league: leagueId,
      type: "LEAGUE_REFEREE_INVITE",
      status: "pending"
    });

    console.log("Created referee notification:", {
      notificationId: notification._id,
      sender: senderId.toString(),
      receiver: receiverId.toString(),
      league: leagueId.toString(),
      type: "LEAGUE_REFEREE_INVITE"
    });

    await notification.populate("sender", "firstName lastName email");
    await notification.populate("receiver", "firstName lastName email");
    await notification.populate("league", "leagueName");

    return NextResponse.json(
      {
        message: "Referee invitation sent successfully",
        data: notification
      },
      { status: 201 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to invite referee" }, { status: 500 });
  }
}

/**
 * Invite stat keeper to league
 * POST /api/league/:id/invite-statkeeper
 * Body: { statKeeperId: string }
 */
export async function inviteStatKeeperToLeague(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyAdmin(req);

    const { id } = params;
    const { statKeeperId } = await req.json();

    console.log("inviteStatKeeperToLeague - League ID:", id);
    console.log("inviteStatKeeperToLeague - Stat Keeper ID:", statKeeperId);
    console.log("inviteStatKeeperToLeague - League ID type:", typeof id);

    if (!id) {
      console.error("inviteStatKeeperToLeague - League ID is missing!");
      return NextResponse.json({ error: "League ID is required" }, { status: 400 });
    }

    if (!statKeeperId) {
      return NextResponse.json({ error: "Stat keeper ID is required" }, { status: 400 });
    }

    // Convert league ID to ObjectId
    const leagueId = toObjectId(id);
    console.log("inviteStatKeeperToLeague - Searching for league with ID:", leagueId.toString());
    const league = await League.findById(leagueId);
    if (!league) {
      console.error("inviteStatKeeperToLeague - League not found with ID:", id);
      console.error("inviteStatKeeperToLeague - Checking if league exists with different format...");
      // Try to find by string comparison
      const allLeagues = await League.find({});
      console.log("inviteStatKeeperToLeague - Total leagues in DB:", allLeagues.length);
      allLeagues.forEach((l: any) => {
        console.log("inviteStatKeeperToLeague - League in DB:", {
          _id: l._id?.toString(),
          id: l.id,
          leagueName: l.leagueName
        });
      });
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    console.log("inviteStatKeeperToLeague - League found:", {
      _id: (league as any)._id?.toString(),
      leagueName: (league as any).leagueName
    });

    const statKeeper = await User.findById(statKeeperId);
    if (!statKeeper) {
      return NextResponse.json({ error: "Stat keeper not found" }, { status: 404 });
    }

    if (statKeeper.role !== "stat-keeper") {
      return NextResponse.json({ error: "User is not a stat keeper" }, { status: 400 });
    }

    // Check if stat keeper is already in the league
    const statKeepers = (league as any).statKeepers || [];
    if (statKeepers.some((sk: any) => sk.toString() === statKeeperId)) {
      return NextResponse.json({ error: "Stat keeper already in league" }, { status: 409 });
    }

    // Convert IDs to ObjectIds
    const senderId = toObjectId(decoded.userId);
    const receiverId = toObjectId(statKeeperId);

    // Check if there's already a pending invite
    const existingNotification = await Notification.findOne({
      sender: senderId,
      receiver: receiverId,
      league: leagueId,
      type: "LEAGUE_STATKEEPER_INVITE",
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json({ error: "Invite already sent to this stat keeper" }, { status: 409 });
    }

    // Create notification with ObjectIds
    const notification = await Notification.create({
      sender: senderId,
      receiver: receiverId,
      league: leagueId,
      type: "LEAGUE_STATKEEPER_INVITE",
      status: "pending"
    });

    console.log("Created stat keeper notification:", {
      notificationId: notification._id,
      sender: senderId.toString(),
      receiver: receiverId.toString(),
      league: leagueId.toString(),
      type: "LEAGUE_STATKEEPER_INVITE"
    });
    
    // Verify notification was saved correctly
    const savedNotification = await Notification.findById(notification._id);
    console.log("Saved notification:", {
      sender: savedNotification?.sender?.toString(),
      receiver: savedNotification?.receiver?.toString(),
      league: savedNotification?.league?.toString()
    });

    await notification.populate("sender", "firstName lastName email");
    await notification.populate("receiver", "firstName lastName email");
    await notification.populate("league", "leagueName");

    return NextResponse.json(
      {
        message: "Stat keeper invitation sent successfully",
        data: notification
      },
      { status: 201 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to invite stat keeper" }, { status: 500 });
  }
}

/**
 * Invite team to league
 * POST /api/league/:id/invite-team
 * Body: { teamId: string }
 */
export async function inviteTeamToLeague(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyAdmin(req);

    const { id } = params;
    const { teamId } = await req.json();

    console.log("inviteTeamToLeague - League ID:", id);
    console.log("inviteTeamToLeague - Team ID:", teamId);
    console.log("inviteTeamToLeague - League ID type:", typeof id);

    if (!id) {
      console.error("inviteTeamToLeague - League ID is missing!");
      return NextResponse.json({ error: "League ID is required" }, { status: 400 });
    }

    if (!teamId) {
      return NextResponse.json({ error: "Team ID is required" }, { status: 400 });
    }

    // Convert league ID to ObjectId
    const leagueId = toObjectId(id);
    console.log("inviteTeamToLeague - Searching for league with ID:", leagueId.toString());
    const league = await League.findById(leagueId);
    if (!league) {
      console.error("inviteTeamToLeague - League not found with ID:", id);
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    console.log("inviteTeamToLeague - League found:", {
      _id: (league as any)._id?.toString(),
      leagueName: (league as any).leagueName
    });

    const team = await Team.findById(teamId);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    // Check if team is already in the league
    const teams = (league as any).teams || [];
    if (teams.some((t: any) => t.toString() === teamId)) {
      return NextResponse.json({ error: "Team already in league" }, { status: 409 });
    }

    // Get team captain to send notification to
    const captainId = team.captain.toString();

    // Convert IDs to ObjectIds
    const senderId = toObjectId(decoded.userId);
    const receiverId = toObjectId(captainId);
    const teamObjectId = toObjectId(teamId);

    // Check if there's already a pending invite
    const existingNotification = await Notification.findOne({
      sender: senderId,
      receiver: receiverId,
      league: leagueId,
      team: teamObjectId,
      type: "LEAGUE_TEAM_INVITE",
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json({ error: "Invite already sent to this team" }, { status: 409 });
    }

    // Create notification for team captain with ObjectIds
    const notification = await Notification.create({
      sender: senderId,
      receiver: receiverId,
      league: leagueId,
      team: teamObjectId,
      type: "LEAGUE_TEAM_INVITE",
      status: "pending"
    });

    console.log("Created team notification:", {
      notificationId: notification._id,
      sender: senderId.toString(),
      receiver: receiverId.toString(),
      league: leagueId.toString(),
      team: teamObjectId.toString(),
      type: "LEAGUE_TEAM_INVITE"
    });

    await notification.populate("sender", "firstName lastName email");
    await notification.populate("receiver", "firstName lastName email");
    await notification.populate("league", "leagueName");
    await notification.populate("team", "teamName");

    return NextResponse.json(
      {
        message: "Team invitation sent successfully",
        data: notification
      },
      { status: 201 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to invite team" }, { status: 500 });
  }
}

