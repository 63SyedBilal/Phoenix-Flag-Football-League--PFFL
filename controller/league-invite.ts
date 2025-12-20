import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { League, User, Team, Notification } from "@/modules";
import SuperAdmin from "@/modules/superadmin";
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

// Helper to verify admin from token
async function verifyAdmin(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  if (decoded.role !== "superadmin") throw new Error("Unauthorized");
  
  return decoded;
}

/**
 * Invite referee to league
 * POST /api/league/:leagueId/invite/referee
 * Body: { superadminId: string, refereeId: string }
 */
export async function inviteReferee(req: NextRequest, { params }: { params: { leagueId: string } }) {
  try {
    console.log("🔥 [inviteReferee] Function started");
    console.log("🔥 [inviteReferee] Connecting to DB...");
    await connectDB();
    console.log("🔥 [inviteReferee] DB connected, verifying admin...");
    const decoded = await verifyAdmin(req);
    console.log("🔥 [inviteReferee] Admin verified");

    console.log("🔍 Decoded token in inviteReferee:", {
      userId: decoded.userId,
      role: decoded.role,
      email: decoded.email
    });

    const { leagueId: leagueIdParam } = params;
    const body = await req.json();
    const { superadminId, refereeId } = body;

    console.log("📥 Request params and body:", {
      leagueIdParam,
      superadminId,
      refereeId
    });

    // Validate leagueId from params
    if (!leagueIdParam) {
      return NextResponse.json(
        { success: false, error: "League ID is missing from URL params" },
        { status: 400 }
      );
    }

    // Validate decoded token has userId
    if (!decoded.userId) {
      return NextResponse.json(
        { success: false, error: "User ID missing from token" },
        { status: 401 }
      );
    }

    // Extract superadminId from token if not provided in body (for backward compatibility)
    const senderIdFromToken = toObjectId(decoded.userId);
    const senderId = superadminId ? toObjectId(superadminId) : senderIdFromToken;
    const receiverId = refereeId ? toObjectId(refereeId) : null;

    // STRICT VALIDATION: Ensure all IDs are present before creating notification
    if (!senderId) {
      return NextResponse.json(
        { success: false, error: "SenderId is missing" },
        { status: 400 }
      );
    }

    if (!receiverId) {
      return NextResponse.json(
        { success: false, error: "refereeId is required" },
        { status: 400 }
      );
    }

    // Convert league ID to ObjectId
    const leagueObjectId = toObjectId(leagueIdParam);

    if (!leagueObjectId) {
      return NextResponse.json(
        { success: false, error: "LeagueId is missing or invalid" },
        { status: 400 }
      );
    }

    console.log("✅ All IDs validated:", {
      senderId: senderId.toString(),
      receiverId: receiverId.toString(),
      leagueObjectId: leagueObjectId.toString()
    });

    // Validate league exists
    console.log("🔍 Looking for league with ID:", leagueObjectId.toString());
    const league = await League.findById(leagueObjectId);
    console.log("🔍 League found:", league ? league.leagueName : "NULL");
    
    if (!league) {
      console.error("❌ League not found in DB. ID:", leagueObjectId.toString());
      return NextResponse.json(
        { success: false, error: "League not found" },
        { status: 404 }
      );
    }

    // Validate sender exists (check SuperAdmin collection since sender is superadmin)
    console.log("🔍 Looking for sender (superadmin) with ID:", senderId.toString());
    const sender = await SuperAdmin.findById(senderId);
    console.log("🔍 Sender found:", sender ? `${sender.email} (role: ${sender.role})` : "NULL");
    
    if (!sender) {
      console.error("❌ Sender not found in SuperAdmin collection. ID:", senderId.toString());
      console.error("❌ This means the JWT token contains a userId that doesn't exist in the SuperAdmin database!");
      return NextResponse.json(
        { success: false, error: "Sender (superadmin) not found" },
        { status: 404 }
      );
    }

    // Validate receiver exists and is a referee or free-agent (free-agents can become referees)
    console.log("🔍 Looking for receiver (referee or free-agent) with ID:", receiverId.toString());
    const receiver = await User.findById(receiverId);
    console.log("🔍 Receiver found:", receiver ? `${receiver.firstName} ${receiver.lastName} (${receiver.email}, role: ${receiver.role})` : "NULL");
    if (!receiver) {
      return NextResponse.json(
        { success: false, error: "Receiver not found" },
        { status: 404 }
      );
    }

    if (receiver.role !== "referee" && receiver.role !== "free-agent") {
      return NextResponse.json(
        { success: false, error: "User must be a referee or free-agent to be invited as a referee" },
        { status: 400 }
      );
    }

    // Check if referee is already in the league
    const referees = (league as any).referees || [];
    if (referees.some((r: any) => r.toString() === receiverId.toString())) {
      return NextResponse.json(
        { success: false, error: "Referee already in league" },
        { status: 409 }
      );
    }

    // Check if there's already a pending invite
    const existingNotification = await Notification.findOne({
      sender: senderId,
      receiver: receiverId,
      league: leagueObjectId,
      type: "LEAGUE_REFEREE_INVITE",
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json(
        { success: false, error: "Invite already sent to this referee" },
        { status: 409 }
      );
    }

    // FINAL CHECK: Log all IDs before creating notification
    console.log("🚀 Creating REFEREE notification with:", {
      sender: senderId.toString(),
      senderExists: !!sender,
      receiver: receiverId.toString(),
      receiverExists: !!receiver,
      league: leagueObjectId.toString(),
      leagueExists: !!league,
      type: "LEAGUE_REFEREE_INVITE"
    });

    // Create notification
    const notification = await Notification.create({
      sender: senderId,
      receiver: receiverId,
      league: leagueObjectId,
      type: "LEAGUE_REFEREE_INVITE",
      status: "pending"
    });

    console.log("✅ Notification created:", {
      _id: notification._id.toString(),
      sender: notification.sender,
      receiver: notification.receiver,
      league: notification.league
    });

    // Populate notification with proper array format
    // Note: sender is SuperAdmin, receiver is User
    await notification.populate([
      { path: "sender", select: "email role", model: "SuperAdmin" },
      { path: "receiver", select: "firstName lastName email", model: "User" },
      { path: "league", select: "leagueName logo", model: "League" }
    ]);

    console.log("✅ Notification populated:", {
      notificationId: notification._id.toString(),
      sender: notification.sender ? (notification.sender as any).email : "NULL",
      receiver: notification.receiver ? `${(notification.receiver as any).firstName} ${(notification.receiver as any).lastName}` : "NULL",
      league: notification.league ? (notification.league as any).leagueName : "NULL",
      type: "LEAGUE_REFEREE_INVITE"
    });

    return NextResponse.json(
      {
        success: true,
        message: "Referee invitation sent successfully",
        data: notification
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error in inviteReferee:", error);
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to invite referee" },
      { status: 500 }
    );
  }
}

/**
 * Invite stat keeper to league
 * POST /api/league/:leagueId/invite/statkeeper
 * Body: { superadminId: string, statKeeperId: string }
 */
export async function inviteStatKeeper(req: NextRequest, { params }: { params: { leagueId: string } }) {
  try {
    console.log("🔥 [inviteStatKeeper] Function started");
    console.log("🔥 [inviteStatKeeper] Connecting to DB...");
    await connectDB();
    console.log("🔥 [inviteStatKeeper] DB connected, verifying admin...");
    const decoded = await verifyAdmin(req);
    console.log("🔥 [inviteStatKeeper] Admin verified");

    console.log("🔍 Decoded token in inviteStatKeeper:", {
      userId: decoded.userId,
      role: decoded.role,
      email: decoded.email
    });

    const { leagueId: leagueIdParam } = params;
    const body = await req.json();
    const { superadminId, statKeeperId } = body;

    console.log("📥 Request params and body:", {
      leagueIdParam,
      superadminId,
      statKeeperId
    });

    // Validate leagueId from params
    if (!leagueIdParam) {
      return NextResponse.json(
        { success: false, error: "League ID is missing from URL params" },
        { status: 400 }
      );
    }

    // Validate decoded token has userId
    if (!decoded.userId) {
      return NextResponse.json(
        { success: false, error: "User ID missing from token" },
        { status: 401 }
      );
    }

    // Extract superadminId from token if not provided in body (for backward compatibility)
    const senderIdFromToken = toObjectId(decoded.userId);
    const senderId = superadminId ? toObjectId(superadminId) : senderIdFromToken;
    const receiverId = statKeeperId ? toObjectId(statKeeperId) : null;

    // STRICT VALIDATION: Ensure all IDs are present before creating notification
    if (!senderId) {
      return NextResponse.json(
        { success: false, error: "SenderId is missing" },
        { status: 400 }
      );
    }

    if (!receiverId) {
      return NextResponse.json(
        { success: false, error: "statKeeperId is required" },
        { status: 400 }
      );
    }

    // Convert league ID to ObjectId
    const leagueObjectId = toObjectId(leagueIdParam);

    if (!leagueObjectId) {
      return NextResponse.json(
        { success: false, error: "LeagueId is missing or invalid" },
        { status: 400 }
      );
    }

    console.log("✅ All IDs validated:", {
      senderId: senderId.toString(),
      receiverId: receiverId.toString(),
      leagueObjectId: leagueObjectId.toString()
    });

    // Validate league exists
    console.log("🔍 Looking for league with ID:", leagueObjectId.toString());
    const league = await League.findById(leagueObjectId);
    console.log("🔍 League found:", league ? league.leagueName : "NULL");
    
    if (!league) {
      console.error("❌ League not found in DB. ID:", leagueObjectId.toString());
      return NextResponse.json(
        { success: false, error: "League not found" },
        { status: 404 }
      );
    }

    // Validate sender exists (check SuperAdmin collection since sender is superadmin)
    console.log("🔍 Looking for sender (superadmin) with ID:", senderId.toString());
    const sender = await SuperAdmin.findById(senderId);
    console.log("🔍 Sender found:", sender ? `${sender.email} (role: ${sender.role})` : "NULL");
    
    if (!sender) {
      console.error("❌ Sender not found in SuperAdmin collection. ID:", senderId.toString());
      console.error("❌ This means the JWT token contains a userId that doesn't exist in the SuperAdmin database!");
      return NextResponse.json(
        { success: false, error: "Sender (superadmin) not found" },
        { status: 404 }
      );
    }

    // Validate receiver exists and is a stat keeper
    console.log("🔍 Looking for receiver (stat keeper) with ID:", receiverId.toString());
    const receiver = await User.findById(receiverId);
    console.log("🔍 Receiver found:", receiver ? `${receiver.firstName} ${receiver.lastName} (${receiver.email}, role: ${receiver.role})` : "NULL");
    if (!receiver) {
      return NextResponse.json(
        { success: false, error: "Receiver (stat keeper) not found" },
        { status: 404 }
      );
    }

    if (receiver.role !== "stat-keeper") {
      return NextResponse.json(
        { success: false, error: "User is not a stat keeper" },
        { status: 400 }
      );
    }

    // Check if stat keeper is already in the league
    const statKeepers = (league as any).statKeepers || [];
    if (statKeepers.some((sk: any) => sk.toString() === receiverId.toString())) {
      return NextResponse.json(
        { success: false, error: "Stat keeper already in league" },
        { status: 409 }
      );
    }

    // Check if there's already a pending invite
    const existingNotification = await Notification.findOne({
      sender: senderId,
      receiver: receiverId,
      league: leagueObjectId,
      type: "LEAGUE_STATKEEPER_INVITE",
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json(
        { success: false, error: "Invite already sent to this stat keeper" },
        { status: 409 }
      );
    }

    // FINAL CHECK: Log all IDs before creating notification
    console.log("🚀 Creating STATKEEPER notification with:", {
      sender: senderId.toString(),
      senderExists: !!sender,
      receiver: receiverId.toString(),
      receiverExists: !!receiver,
      league: leagueObjectId.toString(),
      leagueExists: !!league,
      type: "LEAGUE_STATKEEPER_INVITE"
    });

    // Create notification
    const notification = await Notification.create({
      sender: senderId,
      receiver: receiverId,
      league: leagueObjectId,
      type: "LEAGUE_STATKEEPER_INVITE",
      status: "pending"
    });

    console.log("✅ Notification created:", {
      _id: notification._id.toString(),
      sender: notification.sender,
      receiver: notification.receiver,
      league: notification.league
    });

    // Populate notification with proper array format
    // Note: sender is SuperAdmin, receiver is User
    await notification.populate([
      { path: "sender", select: "email role", model: "SuperAdmin" },
      { path: "receiver", select: "firstName lastName email", model: "User" },
      { path: "league", select: "leagueName logo", model: "League" }
    ]);

    console.log("✅ Notification populated:", {
      notificationId: notification._id.toString(),
      sender: notification.sender ? (notification.sender as any).email : "NULL",
      receiver: notification.receiver ? `${(notification.receiver as any).firstName} ${(notification.receiver as any).lastName}` : "NULL",
      league: notification.league ? (notification.league as any).leagueName : "NULL",
      type: "LEAGUE_STATKEEPER_INVITE"
    });

    return NextResponse.json(
      {
        success: true,
        message: "Stat keeper invitation sent successfully",
        data: notification
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error in inviteStatKeeper:", error);
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to invite stat keeper" },
      { status: 500 }
    );
  }
}

/**
 * Invite team to league
 * POST /api/league/:leagueId/invite/team
 * Body: { superadminId: string, teamId: string }
 */
export async function inviteTeam(req: NextRequest, { params }: { params: { leagueId: string } }) {
  try {
    console.log("🔥 [inviteTeam] Function started");
    console.log("🔥 [inviteTeam] Connecting to DB...");
    await connectDB();
    console.log("🔥 [inviteTeam] DB connected, verifying admin...");
    const decoded = await verifyAdmin(req);
    console.log("🔥 [inviteTeam] Admin verified");

    console.log("🔍 Decoded token in inviteTeam:", {
      userId: decoded.userId,
      role: decoded.role,
      email: decoded.email
    });

    const { leagueId: leagueIdParam } = params;
    const body = await req.json();
    const { superadminId, teamId } = body;

    console.log("📥 Request params and body:", {
      leagueIdParam,
      superadminId,
      teamId
    });

    // Validate leagueId from params
    if (!leagueIdParam) {
      return NextResponse.json(
        { success: false, error: "League ID is missing from URL params" },
        { status: 400 }
      );
    }

    // Validate decoded token has userId
    if (!decoded.userId) {
      return NextResponse.json(
        { success: false, error: "User ID missing from token" },
        { status: 401 }
      );
    }

    // Extract superadminId from token if not provided in body (for backward compatibility)
    const senderIdFromToken = toObjectId(decoded.userId);
    const senderId = superadminId ? toObjectId(superadminId) : senderIdFromToken;
    const teamObjectId = teamId ? toObjectId(teamId) : null;

    // STRICT VALIDATION: Ensure all IDs are present before creating notification
    if (!senderId) {
      return NextResponse.json(
        { success: false, error: "SenderId is missing" },
        { status: 400 }
      );
    }

    if (!teamObjectId) {
      return NextResponse.json(
        { success: false, error: "teamId is required" },
        { status: 400 }
      );
    }

    // Convert league ID to ObjectId
    const leagueObjectId = toObjectId(leagueIdParam);

    if (!leagueObjectId) {
      return NextResponse.json(
        { success: false, error: "LeagueId is missing or invalid" },
        { status: 400 }
      );
    }

    console.log("✅ All IDs validated (before captain lookup):", {
      senderId: senderId.toString(),
      teamObjectId: teamObjectId.toString(),
      leagueObjectId: leagueObjectId.toString()
    });

    // Validate league exists
    console.log("🔍 Looking for league with ID:", leagueObjectId.toString());
    const league = await League.findById(leagueObjectId);
    console.log("🔍 League found:", league ? league.leagueName : "NULL");
    
    if (!league) {
      console.error("❌ League not found in DB. ID:", leagueObjectId.toString());
      return NextResponse.json(
        { success: false, error: "League not found" },
        { status: 404 }
      );
    }

    // Validate sender exists (check SuperAdmin collection since sender is superadmin)
    console.log("🔍 Looking for sender (superadmin) with ID:", senderId.toString());
    const sender = await SuperAdmin.findById(senderId);
    console.log("🔍 Sender found:", sender ? `${sender.email} (role: ${sender.role})` : "NULL");
    
    if (!sender) {
      console.error("❌ Sender not found in SuperAdmin collection. ID:", senderId.toString());
      console.error("❌ This means the JWT token contains a userId that doesn't exist in the SuperAdmin database!");
      return NextResponse.json(
        { success: false, error: "Sender (superadmin) not found" },
        { status: 404 }
      );
    }

    // Validate team exists
    console.log("🔍 Looking for team with ID:", teamObjectId.toString());
    const team = await Team.findById(teamObjectId);
    console.log("🔍 Team found:", team ? team.teamName : "NULL");
    if (!team) {
      return NextResponse.json(
        { success: false, error: "Team not found" },
        { status: 404 }
      );
    }

    // Get team captain to send notification to
    const captainId = toObjectId(team.captain.toString());

    // Validate captain exists
    const captain = await User.findById(captainId);
    if (!captain) {
      return NextResponse.json(
        { success: false, error: "Team captain not found" },
        { status: 404 }
      );
    }

    // FINAL VALIDATION: Ensure captainId (receiver) is valid before creating notification
    if (!captainId) {
      return NextResponse.json(
        { success: false, error: "Captain ID is missing" },
        { status: 400 }
      );
    }

    console.log("✅ Final validation before creating notification:", {
      senderId: senderId.toString(),
      receiverId: captainId.toString(),
      leagueObjectId: leagueObjectId.toString(),
      teamObjectId: teamObjectId.toString()
    });

    // Check if there's already a pending invite
    const existingNotification = await Notification.findOne({
      sender: senderId,
      receiver: captainId,
      league: leagueObjectId,
      team: teamObjectId,
      type: "LEAGUE_TEAM_INVITE",
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json(
        { success: false, error: "Invite already sent to this team" },
        { status: 409 }
      );
    }

    // FINAL CHECK: Log all IDs before creating notification
    console.log("🚀 Creating TEAM notification with:", {
      sender: senderId.toString(),
      senderExists: !!sender,
      receiver: captainId.toString(),
      receiverExists: !!captain,
      league: leagueObjectId.toString(),
      leagueExists: !!league,
      team: teamObjectId.toString(),
      teamExists: !!team,
      type: "LEAGUE_TEAM_INVITE"
    });

    // Create notification for team captain
    const notification = await Notification.create({
      sender: senderId,
      receiver: captainId,
      league: leagueObjectId,
      team: teamObjectId,
      type: "LEAGUE_TEAM_INVITE",
      status: "pending"
    });

    console.log("✅ Notification created:", {
      _id: notification._id.toString(),
      sender: notification.sender,
      receiver: notification.receiver,
      league: notification.league,
      team: notification.team
    });

    // Populate notification with proper array format
    // Note: sender is SuperAdmin, receiver is User (team captain)
    await notification.populate([
      { path: "sender", select: "email role", model: "SuperAdmin" },
      { path: "receiver", select: "firstName lastName email", model: "User" },
      { path: "league", select: "leagueName logo", model: "League" },
      { path: "team", select: "teamName image", model: "Team" }
    ]);

    console.log("✅ Notification populated:", {
      notificationId: notification._id.toString(),
      sender: notification.sender ? (notification.sender as any).email : "NULL",
      receiver: notification.receiver ? `${(notification.receiver as any).firstName} ${(notification.receiver as any).lastName}` : "NULL",
      league: notification.league ? (notification.league as any).leagueName : "NULL",
      team: notification.team ? (notification.team as any).teamName : "NULL",
      type: "LEAGUE_TEAM_INVITE"
    });

    return NextResponse.json(
      {
        success: true,
        message: "Team invitation sent successfully",
        data: notification
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error in inviteTeam:", error);
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message === "Unauthorized") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to invite team" },
      { status: 500 }
    );
  }
}

