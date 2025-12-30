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

/**
 * Get available referees for a league on a specific date
 * GET /api/league/:leagueId/available-referees?date=2024-01-01
 */
export async function getAvailableReferees(req: NextRequest, { params }: { params: { leagueId: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { leagueId } = params;
    const { searchParams } = new URL(req.url);
    const dateParam = searchParams.get('date');

    if (!dateParam) {
      return NextResponse.json({ error: "Date parameter is required" }, { status: 400 });
    }

    // Parse the date
    const targetDate = new Date(dateParam);
    if (isNaN(targetDate.getTime())) {
      return NextResponse.json({ error: "Invalid date format" }, { status: 400 });
    }

    // Find the league
    const league = await League.findById(leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Get all referees assigned to this league
    const leagueReferees = (league as any).referees || [];

    if (leagueReferees.length === 0) {
      return NextResponse.json({
        success: true,
        data: [],
        message: "No referees assigned to this league"
      });
    }

    // Get referee details and check their availability on the target date
    const referees = await User.find({
      _id: { $in: leagueReferees },
      role: 'referee'
    }).select('firstName lastName email profileImage');

    // For now, assume all league referees are available
    // In a more advanced system, you could check their schedules/calendars
    // to see if they're already assigned to matches on this date
    const availableReferees = referees.map(referee => ({
      id: referee._id.toString(),
      name: `${referee.firstName} ${referee.lastName}`,
      email: referee.email,
      profileImage: referee.profileImage || '',
      isAvailable: true // All referees are considered available for now
    }));

    return NextResponse.json({
      success: true,
      data: availableReferees,
      message: `Found ${availableReferees.length} available referees for ${dateParam}`
    });

  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get available referees" }, { status: 500 });
  }
}

/**
 * Get available stat keepers for a league on a specific date
 * GET /api/league/:leagueId/available-statkeepers?date=2024-01-01
 */
export async function getAvailableStatKeepers(req: NextRequest, { params }: { params: { leagueId: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { leagueId } = params;
    const { searchParams } = new URL(req.url);
    const dateParam = searchParams.get('date');

    if (!dateParam) {
      return NextResponse.json({ error: "Date parameter is required" }, { status: 400 });
    }

    // Parse the date
    const targetDate = new Date(dateParam);
    if (isNaN(targetDate.getTime())) {
      return NextResponse.json({ error: "Invalid date format" }, { status: 400 });
    }

    // Find the league
    const league = await League.findById(leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Get all stat keepers assigned to this league
    const leagueStatKeepers = (league as any).statKeepers || [];

    if (leagueStatKeepers.length === 0) {
      return NextResponse.json({
        success: true,
        data: [],
        message: "No stat keepers assigned to this league"
      });
    }

    // Get stat keeper details and check their availability on the target date
    const statKeepers = await User.find({
      _id: { $in: leagueStatKeepers },
      role: 'stat-keeper'
    }).select('firstName lastName email profileImage');

    // For now, assume all league stat keepers are available
    // In a more advanced system, you could check their schedules/calendars
    // to see if they're already assigned to matches on this date
    const availableStatKeepers = statKeepers.map(statKeeper => ({
      id: statKeeper._id.toString(),
      name: `${statKeeper.firstName} ${statKeeper.lastName}`,
      email: statKeeper.email,
      profileImage: statKeeper.profileImage || '',
      isAvailable: true // All stat keepers are considered available for now
    }));

    return NextResponse.json({
      success: true,
      data: availableStatKeepers,
      message: `Found ${availableStatKeepers.length} available stat keepers for ${dateParam}`
    });

  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get available stat keepers" }, { status: 500 });
  }
}

/**
 * Bulk assign officials to multiple matches
 * POST /api/league/:leagueId/assign-officials
 * Body: {
 *   assignments: [
 *     {
 *       matchId: "match_id",
 *       refereeId: "referee_id", // optional
 *       statKeeperId: "statkeeper_id" // optional
 *     }
 *   ]
 * }
 */
export async function bulkAssignOfficials(req: NextRequest, { params }: { params: { leagueId: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { leagueId } = params;
    const { assignments } = await req.json();

    if (!assignments || !Array.isArray(assignments)) {
      return NextResponse.json({ error: "Assignments array is required" }, { status: 400 });
    }

    // Validate league exists
    const league = await League.findById(leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    const results = [];
    const errors = [];

    for (const assignment of assignments) {
      try {
        const { matchId, refereeId, statKeeperId } = assignment;

        if (!matchId) {
          errors.push({ matchId, error: "matchId is required" });
          continue;
        }

        // Find the match
        const match = await (await import("@/modules")).Match.findById(matchId);
        if (!match) {
          errors.push({ matchId, error: "Match not found" });
          continue;
        }

        // Verify match belongs to this league
        if (match.leagueId.toString() !== leagueId) {
          errors.push({ matchId, error: "Match does not belong to this league" });
          continue;
        }

        // Validate officials if provided
        if (refereeId) {
          const referee = await User.findById(refereeId);
          if (!referee || referee.role !== 'referee') {
            errors.push({ matchId, refereeId, error: "Invalid referee" });
            continue;
          }

          // Check if referee is assigned to this league
          const leagueReferees = (league as any).referees || [];
          if (!leagueReferees.some((r: any) => r.toString() === refereeId)) {
            errors.push({ matchId, refereeId, error: "Referee not assigned to this league" });
            continue;
          }
        }

        if (statKeeperId) {
          const statKeeper = await User.findById(statKeeperId);
          if (!statKeeper || statKeeper.role !== 'stat-keeper') {
            errors.push({ matchId, statKeeperId, error: "Invalid stat keeper" });
            continue;
          }

          // Check if stat keeper is assigned to this league
          const leagueStatKeepers = (league as any).statKeepers || [];
          if (!leagueStatKeepers.some((sk: any) => sk.toString() === statKeeperId)) {
            errors.push({ matchId, statKeeperId, error: "Stat keeper not assigned to this league" });
            continue;
          }
        }

        // Update the match with officials
        const updateData: any = {};
        if (refereeId) updateData.refereeId = refereeId;
        if (statKeeperId) updateData.statKeeperId = statKeeperId;

        await (await import("@/modules")).Match.findByIdAndUpdate(matchId, updateData);

        // Create notifications for assigned officials
        if (refereeId) {
          await Notification.create({
            sender: (await verifyAdmin(req)).userId, // Superadmin ID
            receiver: refereeId,
            league: leagueId,
            type: "MATCH_ASSIGNMENT",
            status: "pending",
            message: `You have been assigned as referee for a match in ${league.leagueName}. Match date: ${match.gameDate ? new Date(match.gameDate).toLocaleDateString() : 'TBD'}`
          });
        }

        if (statKeeperId) {
          await Notification.create({
            sender: (await verifyAdmin(req)).userId, // Superadmin ID
            receiver: statKeeperId,
            league: leagueId,
            type: "MATCH_ASSIGNMENT",
            status: "pending",
            message: `You have been assigned as stat keeper for a match in ${league.leagueName}. Match date: ${match.gameDate ? new Date(match.gameDate).toLocaleDateString() : 'TBD'}`
          });
        }

        results.push({
          matchId,
          refereeId,
          statKeeperId,
          status: "assigned"
        });

      } catch (assignmentError: any) {
        errors.push({
          matchId: assignment.matchId,
          error: assignmentError.message || "Assignment failed"
        });
      }
    }

    return NextResponse.json({
      success: true,
      data: {
        successful: results,
        failed: errors,
        summary: {
          total: assignments.length,
          successful: results.length,
          failed: errors.length
        }
      },
      message: `Bulk assignment completed: ${results.length} successful, ${errors.length} failed`
    });

  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to bulk assign officials" }, { status: 500 });
  }
}

/**
 * Check league payment status for a user (captain or player)
 * GET /api/league/:leagueId/payment-status/:captainId
 */
export async function checkLeaguePaymentStatus(req: NextRequest, { params }: { params: { id: string, captainId: string } }) {
  try {
    await connectDB();
    await verifyUser(req); // Ensure user is authenticated

    const { id: leagueId, captainId } = params;
    const leagueObjectId = toObjectId(leagueId);
    const userObjectId = toObjectId(captainId); // Renamed from captainObjectId - can be any user

    console.log('💳 [PAYMENT CHECK] Checking payment status for:', {
      leagueId,
      userId: captainId
    });

    // Find the league
    const league = await League.findById(leagueObjectId);
    if (!league) {
      console.log('❌ [PAYMENT CHECK] League not found');
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // DIRECTLY check for payments - NO team membership check needed!
    const Payment = (await import("@/modules/payment")).default;

    const payment = await Payment.findOne({
      leagueId: leagueObjectId,
      userId: userObjectId,
      status: { $in: ["completed", "paid", "success", "Paid", "PAID", "SUCCESS"] }
    }).sort({ createdAt: -1 });

    const isPaid = payment !== null;

    console.log(`✅ [PAYMENT CHECK] User: ${captainId}, League: ${leagueId}, Result: ${isPaid ? 'PAID' : 'UNPAID'}`);

    const response = {
      isPaid: isPaid,
      leagueId: leagueId,
      captainId: captainId, // Keep field name for backward compatibility
      userId: captainId, // Also include userId for clarity
      paymentDate: payment?.createdAt || null,
      amount: payment?.amount || 0,
      paymentId: payment?._id || null,
      transactionId: payment?.stripePaymentIntentId || null
    };

    return NextResponse.json({
      success: true,
      data: response
    }, { status: 200 });

  } catch (error: any) {
    console.error("❌ [PAYMENT CHECK] Error checking league payment status:", error);
    return NextResponse.json({
      error: error.message || "Failed to check league payment status"
    }, { status: 500 });
  }
}

/**
 * Get league summary data
 * GET /api/league/:leagueId/summary
 */
export async function getLeagueSummary(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req); // Ensure user is authenticated

    const { id: leagueId } = params;
    const leagueObjectId = toObjectId(leagueId);

    // Find the league with populated teams
    const league = await League.findById(leagueObjectId)
      .populate({
        path: 'teams',
        select: 'teamName captain players squad5v5 squad7v7'
      })
      .populate({
        path: 'matches',
        select: 'date time status'
      });

    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Count total matches
    const totalMatches = league.matches?.length ?? 0;

    // Count total teams
    const totalTeams = league.teams?.length ?? 0;

    // Calculate match format (5v5, 7v7, 11v11)
    const format = league.format || '5v5';

    // Get league status
    const now = new Date();
    const startDate = new Date(league.startDate);
    const endDate = new Date(league.endDate);

    let status = 'upcoming';
    if (now >= startDate && now <= endDate) {
      status = 'in_progress';
    } else if (now > endDate) {
      status = 'completed';
    }

    // Get captain's team information (if user is a captain)
    const currentUserId = decoded.userId;
    let captainTeamInfo = null;

    if (currentUserId) {
      const captainTeam = league.teams?.find(team =>
        team.captain?.toString() === currentUserId.toString()
      );

      if (captainTeam) {
        // Count players in the captain's team
        const playerCount = (captainTeam.squad5v5?.length ?? 0) +
          (captainTeam.squad7v7?.length ?? 0) +
          (captainTeam.players?.length ?? 0);

        captainTeamInfo = {
          teamId: captainTeam._id,
          teamName: captainTeam.teamName,
          playerCount: playerCount,
          position: null, // Will be calculated if league is in progress
        };
      }
    }

    const summary = {
      leagueId: league._id,
      leagueName: league.leagueName,
      logo: league.logo,
      totalTeams: totalTeams,
      totalMatches: totalMatches,
      startDate: league.startDate,
      endDate: league.endDate,
      matchFormat: format,
      leagueStatus: status,
      perPlayerFee: league.perPlayerLeagueFee,
      captainTeam: captainTeamInfo,
    };

    return NextResponse.json({
      success: true,
      data: summary
    }, { status: 200 });

  } catch (error: any) {
    console.error("Error getting league summary:", error);
    return NextResponse.json({
      error: error.message || "Failed to get league summary"
    }, { status: 500 });
  }
}

