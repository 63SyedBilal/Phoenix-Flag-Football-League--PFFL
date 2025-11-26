import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import Team from "@/modules/team";
import User from "@/modules/user";
import { verifyAccessToken } from "@/lib/jwt";

// Helper to get token from request
function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

// Helper to verify user from token
async function verifyUserToken(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  return decoded;
}

/**
 * Captain sends invite to player
 * POST /api/team/invite-player
 */
export async function invitePlayer(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const { playerId, teamId, format } = await req.json();

    if (!playerId || !teamId || !format) {
      return NextResponse.json(
        { error: "playerId, teamId, and format are required" },
        { status: 400 }
      );
    }

    // Validate format
    if (!["5v5", "7v7"].includes(format)) {
      return NextResponse.json(
        { error: "Format must be either '5v5' or '7v7'" },
        { status: 400 }
      );
    }

    // Verify user is a captain
    const user = await User.findById(decoded.userId);
    if (!user || user.role !== "captain") {
      return NextResponse.json(
        { error: "Only captains can send invites" },
        { status: 403 }
      );
    }

    // Verify team exists and belongs to this captain
    const team = await Team.findById(teamId);
    if (!team) {
      return NextResponse.json(
        { error: "Team not found" },
        { status: 404 }
      );
    }

    if (team.captain.toString() !== decoded.userId) {
      return NextResponse.json(
        { error: "You can only invite players to your own team" },
        { status: 403 }
      );
    }

    // Validate: captain cannot invite himself
    if (playerId === decoded.userId) {
      return NextResponse.json(
        { error: "You cannot invite yourself" },
        { status: 400 }
      );
    }

    // Verify player exists
    const player = await User.findById(playerId);
    if (!player) {
      return NextResponse.json(
        { error: "Player not found" },
        { status: 404 }
      );
    }

    // Validate: player cannot join same squad twice
    const squadField = format === "5v5" ? "squad5v5" : "squad7v7";
    const squad = (team as any)[squadField];
    if (squad && squad.includes(playerId)) {
      return NextResponse.json(
        { error: `Player is already in the ${format} squad for this team` },
        { status: 400 }
      );
    }

    // Check if there's already a pending invite for this format
    const existingNotification = await Notification.findOne({
      sender: decoded.userId,
      receiver: playerId,
      team: teamId,
      format: format,
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json(
        { error: `Invite already sent to this player for ${format} format` },
        { status: 409 }
      );
    }

    // Create notification with format
    const notification = await Notification.create({
      sender: decoded.userId,
      receiver: playerId,
      team: teamId,
      type: "TEAM_INVITE",
      status: "pending",
      format: format
    });

    // Populate sender and team
    await notification.populate("sender", "firstName lastName email");
    await notification.populate("team", "teamName");
    await notification.populate("receiver", "firstName lastName email");

    return NextResponse.json(
      {
        message: "Invite sent successfully",
        data: notification
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error in invitePlayer:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to send invite" },
      { status: 500 }
    );
  }
}

/**
 * Get all notifications for logged-in user
 * GET /api/notification/all
 */
export async function getAllNotifications(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const notifications = await Notification.find({
      receiver: decoded.userId,
      status: "pending"
    })
      .populate("sender", "firstName lastName email")
      .populate("team", "teamName image")
      .populate("receiver", "firstName lastName email")
      .sort({ createdAt: -1 });

    return NextResponse.json(
      {
        message: "Notifications retrieved successfully",
        data: notifications
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getAllNotifications:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to get notifications" },
      { status: 500 }
    );
  }
}

/**
 * Player accepts invite
 * PUT /api/notification/accept/:notifId
 */
export async function acceptInvite(req: NextRequest, { params }: { params: { notifId: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const { notifId } = params;

    console.log("Accept invite - Notification ID:", notifId);
    console.log("Accept invite - User ID:", decoded.userId);

    // Find notification
    const notification = await Notification.findById(notifId);

    if (!notification) {
      console.error("Notification not found with ID:", notifId);
      // Try to find all notifications to debug
      const allNotifications = await Notification.find({ receiver: decoded.userId }).limit(5);
      console.log("User's notifications:", allNotifications.map(n => ({ id: n._id.toString(), receiver: n.receiver.toString() })));
      return NextResponse.json(
        { error: "Notification not found", debug: { notifId, userId: decoded.userId } },
        { status: 404 }
      );
    }

    console.log("Notification found:", notification._id.toString());

    // Verify the notification belongs to the logged-in user
    const receiverId = notification.receiver.toString();
    const userId = decoded.userId.toString();
    
    console.log("Receiver ID:", receiverId);
    console.log("User ID:", userId);
    
    if (receiverId !== userId) {
      return NextResponse.json(
        { error: "You can only accept your own invites" },
        { status: 403 }
      );
    }

    // Check if notification is still pending
    if (notification.status !== "pending") {
      return NextResponse.json(
        { error: "This invite has already been " + notification.status },
        { status: 400 }
      );
    }

    // Get team - notification.team might be ObjectId or populated object
    const teamId = notification.team.toString ? notification.team.toString() : (notification.team as any)._id?.toString() || notification.team;
    const team = await Team.findById(teamId);
    
    if (!team) {
      console.error("Team not found with ID:", teamId);
      return NextResponse.json(
        { error: "Team not found" },
        { status: 404 }
      );
    }

    console.log("Team found:", team._id.toString());

    // Get the format from notification
    const format = notification.format;
    if (!format || !["5v5", "7v7"].includes(format)) {
      return NextResponse.json(
        { error: "Invalid format in notification" },
        { status: 400 }
      );
    }

    // Check if player is already in the squad for this format
    const playerIdString = decoded.userId.toString();
    const squadField = format === "5v5" ? "squad5v5" : "squad7v7";
    const squadPlayers = (team as any)[squadField].map((p: any) => p.toString());
    
    if (squadPlayers.includes(playerIdString)) {
      return NextResponse.json(
        { error: `You are already in the ${format} squad for this team` },
        { status: 400 }
      );
    }

    // Update notification status
    notification.status = "accepted";
    await notification.save();

    // Add player to the correct squad using $addToSet to prevent duplicates
    const updateQuery: any = {};
    updateQuery[`$addToSet`] = { [squadField]: decoded.userId };

    const updatedTeam = await Team.findByIdAndUpdate(
      teamId,
      updateQuery,
      { new: true }
    );

    if (!updatedTeam) {
      console.error("Failed to update team");
      return NextResponse.json(
        { error: "Failed to add player to squad" },
        { status: 500 }
      );
    }

    console.log(`${format} squad after:`, (updatedTeam as any)[squadField].map((p: any) => p.toString()));

    // Populate for response
    await notification.populate("sender", "firstName lastName email");
    await notification.populate("team", "teamName image");
    await notification.populate("receiver", "firstName lastName email");

    return NextResponse.json(
      {
        message: "Invite accepted successfully. You have been added to the team.",
        data: notification
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in acceptInvite:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to accept invite" },
      { status: 500 }
    );
  }
}

/**
 * Player rejects invite
 * PUT /api/notification/reject/:notifId
 */
export async function rejectInvite(req: NextRequest, { params }: { params: { notifId: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const { notifId } = params;

    // Find notification
    const notification = await Notification.findById(notifId);
    if (!notification) {
      return NextResponse.json(
        { error: "Notification not found" },
        { status: 404 }
      );
    }

    // Verify the notification belongs to the logged-in user
    if (notification.receiver.toString() !== decoded.userId) {
      return NextResponse.json(
        { error: "You can only reject your own invites" },
        { status: 403 }
      );
    }

    // Check if notification is still pending
    if (notification.status !== "pending") {
      return NextResponse.json(
        { error: "This invite has already been " + notification.status },
        { status: 400 }
      );
    }

    // Update notification status
    notification.status = "rejected";
    await notification.save();

    // Populate for response
    await notification.populate("sender", "firstName lastName email");
    await notification.populate("team", "teamName image");
    await notification.populate("receiver", "firstName lastName email");

    return NextResponse.json(
      {
        message: "Invite rejected successfully",
        data: notification
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in rejectInvite:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to reject invite" },
      { status: 500 }
    );
  }
}

