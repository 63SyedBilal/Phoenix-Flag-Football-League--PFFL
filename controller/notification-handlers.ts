import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import Team from "@/modules/team";
import User from "@/modules/user";
import League from "@/modules/league";
import SuperAdmin from "@/modules/superadmin";
import { verifyAccessToken } from "@/lib/jwt";
import { createPayment } from "@/controller/payment";
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
async function verifyUserToken(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  return decoded;
}

/**
 * Get all notifications for logged-in user
 * GET /api/notification/all
 */
export async function getAllNotifications(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const userId = toObjectId(decoded.userId);

    console.log("Getting notifications for user:", userId.toString());

    // Find all pending notifications for the user
    // Try both ObjectId and string matching
    const notifications = await Notification.find({
      $or: [
        { receiver: userId },
        { receiver: userId.toString() }
      ],
      status: "pending"
    })
      .populate({
        path: "team",
        select: "teamName image",
        model: "Team"
      })
      .populate({
        path: "league",
        select: "leagueName logo",
        model: "League"
      })
      .populate({
        path: "match",
        select: "teamAName teamBName gameDate gameTime venue status",
        model: "Match"
      })
      .populate({
        path: "receiver",
        select: "firstName lastName email",
        model: "User"
      })
      .sort({ createdAt: -1 });

    console.log(`Found ${notifications.length} raw notifications for user ${userId.toString()}`);

    // Manually populate sender from either User or SuperAdmin collection
    for (const notification of notifications) {
      if (notification.sender) {
        // Try User first
        let senderDoc = await User.findById(notification.sender);
        if (senderDoc) {
          (notification as any).sender = {
            _id: senderDoc._id,
            firstName: senderDoc.firstName,
            lastName: senderDoc.lastName,
            email: senderDoc.email,
            role: senderDoc.role
          };
        } else {
          // Try SuperAdmin
          const superAdminDoc = await SuperAdmin.findById(notification.sender);
          if (superAdminDoc) {
            (notification as any).sender = {
              _id: superAdminDoc._id,
              firstName: "Super",
              lastName: "Admin",
              email: superAdminDoc.email,
              role: superAdminDoc.role
            };
          }
        }
      }
    }

    console.log("Notification types:", notifications.map((n: any) => ({
      type: n.type,
      receiver: n.receiver?.toString() || n.receiver,
      sender: n.sender ? (n.sender.firstName ? `${n.sender.firstName} ${n.sender.lastName}` : n.sender.email) : "null",
      league: n.league ? n.league.leagueName : "null"
    })));

    // Filter out notifications with null sender, receiver, or league (for league invites)
    const validNotifications = notifications.filter((n: any) => {
      if (!n.sender || !n.receiver) {
        console.warn("Filtering out notification with null sender/receiver:", n._id);
        return false;
      }
      // For league invites, league must exist
      if (n.type.includes("LEAGUE") && n.type !== "GAME_ASSIGNED" && !n.league) {
        console.warn("Filtering out league notification with null league:", n._id);
        return false;
      }
      // For GAME_ASSIGNED, match should exist (league is optional but recommended)
      if (n.type === "GAME_ASSIGNED" && !n.match) {
        console.warn("Filtering out GAME_ASSIGNED notification with null match:", n._id);
        return false;
      }
      // For team invites, team must exist
      if (n.type === "TEAM_INVITE" && !n.team) {
        console.warn("Filtering out team notification with null team:", n._id);
        return false;
      }
      return true;
    });

    console.log(`Returning ${validNotifications.length} valid notifications`);

    return NextResponse.json(
      {
        success: true,
        message: "Notifications retrieved successfully",
        data: validNotifications
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getAllNotifications:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to get notifications" },
      { status: 500 }
    );
  }
}

/**
 * Accept notification
 * POST /api/notification/accept
 * Body: { notificationId: string }
 */
export async function acceptNotification(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const { notificationId } = await req.json();

    if (!notificationId) {
      return NextResponse.json(
        { success: false, error: "notificationId is required" },
        { status: 400 }
      );
    }

    const notifObjectId = toObjectId(notificationId);
    const userId = toObjectId(decoded.userId);

    // Find notification
    const notification = await Notification.findById(notifObjectId);
    if (!notification) {
      return NextResponse.json(
        { success: false, error: "Notification not found" },
        { status: 404 }
      );
    }

    // Verify the notification belongs to the logged-in user
    const receiverId = toObjectId(notification.receiver.toString());
    if (receiverId.toString() !== userId.toString()) {
      return NextResponse.json(
        { success: false, error: "You can only accept your own invites" },
        { status: 403 }
      );
    }

    // Check if notification is still pending
    if (notification.status !== "pending") {
      return NextResponse.json(
        { success: false, error: `This invite has already been ${notification.status}` },
        { status: 400 }
      );
    }

    const notificationType = notification.type;

    // Handle LEAGUE_REFEREE_INVITE
    if (notificationType === "LEAGUE_REFEREE_INVITE") {
      const leagueId = toObjectId(notification.league.toString());
      const league = await League.findById(leagueId);
      
      if (!league) {
        return NextResponse.json(
          { success: false, error: "League not found" },
          { status: 404 }
        );
      }

      const referees = (league as any).referees || [];
      if (referees.some((r: any) => r.toString() === userId.toString())) {
        return NextResponse.json(
          { success: false, error: "You are already a referee in this league" },
          { status: 400 }
        );
      }

      // Get the user to check if they're a free-agent
      const user = await User.findById(userId);
      if (!user) {
        return NextResponse.json(
          { success: false, error: "User not found" },
          { status: 404 }
        );
      }

      // Track if role was changed
      const wasFreeAgent = user.role === "free-agent";

      // If user is a free-agent, change their role to referee
      if (wasFreeAgent) {
        console.log(`🔄 Changing user role from free-agent to referee for user: ${user.email}`);
        user.role = "referee";
        await user.save();
        console.log(`✅ User role updated to referee`);
      }

      // Add referee to league
      (league as any).referees.push(userId);
      await league.save();

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      await notification.populate("sender", "firstName lastName email");
      await notification.populate("league", "leagueName logo");
      await notification.populate("receiver", "firstName lastName email");

      const roleChangeMessage = wasFreeAgent 
        ? " Your role has been updated from free-agent to referee." 
        : "";

      return NextResponse.json(
        {
          success: true,
          message: `Invite accepted successfully. You have been added as a referee to the league.${roleChangeMessage}`,
          data: notification
        },
        { status: 200 }
      );
    }

    // Handle LEAGUE_STATKEEPER_INVITE
    if (notificationType === "LEAGUE_STATKEEPER_INVITE") {
      const leagueId = toObjectId(notification.league.toString());
      const league = await League.findById(leagueId);
      
      if (!league) {
        return NextResponse.json(
          { success: false, error: "League not found" },
          { status: 404 }
        );
      }

      const statKeepers = (league as any).statKeepers || [];
      if (statKeepers.some((sk: any) => sk.toString() === userId.toString())) {
        return NextResponse.json(
          { success: false, error: "You are already a stat keeper in this league" },
          { status: 400 }
        );
      }

      // Add stat keeper to league
      (league as any).statKeepers.push(userId);
      await league.save();

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      await notification.populate("sender", "firstName lastName email");
      await notification.populate("league", "leagueName logo");
      await notification.populate("receiver", "firstName lastName email");

      return NextResponse.json(
        {
          success: true,
          message: "Invite accepted successfully. You have been added as a stat keeper to the league.",
          data: notification
        },
        { status: 200 }
      );
    }

    // Handle LEAGUE_TEAM_INVITE
    if (notificationType === "LEAGUE_TEAM_INVITE") {
      const leagueId = toObjectId(notification.league.toString());
      const league = await League.findById(leagueId);
      
      if (!league) {
        return NextResponse.json(
          { success: false, error: "League not found" },
          { status: 404 }
        );
      }

      const teamId = toObjectId(notification.team.toString());
      const team = await Team.findById(teamId);
      
      if (!team) {
        return NextResponse.json(
          { success: false, error: "Team not found" },
          { status: 404 }
        );
      }

      // Verify user is the captain of the team
      if (team.captain.toString() !== userId.toString()) {
        return NextResponse.json(
          { success: false, error: "Only the team captain can accept league invitations" },
          { status: 403 }
        );
      }

      const teams = (league as any).teams || [];
      if (teams.some((t: any) => t.toString() === teamId.toString())) {
        return NextResponse.json(
          { success: false, error: "Team is already in this league" },
          { status: 400 }
        );
      }

      // Add team to league
      (league as any).teams.push(teamId);
      await league.save();

      // Create payment records for all players in the team (including captain)
      // Only create payments for players and captains, not referees/stat-keepers
      try {
        // Get all unique player IDs from both squads
        const squad5v5Ids = (team.squad5v5 || []).map((id: any) => id.toString());
        const squad7v7Ids = (team.squad7v7 || []).map((id: any) => id.toString());
        const captainId = team.captain.toString();
        
        // Combine all player IDs (including captain) and remove duplicates
        const allPlayerIds = [...new Set([...squad5v5Ids, ...squad7v7Ids, captainId])];
        
        console.log(`💰 Creating payments for ${allPlayerIds.length} players in team ${team.teamName} for league ${league.leagueName}`);
        
        // Create payment for each player
        const paymentPromises = allPlayerIds.map(async (playerIdStr: string) => {
          try {
            const playerId = toObjectId(playerIdStr);
            
            // Get user to check role
            const player = await User.findById(playerId);
            if (!player) {
              console.warn(`⚠️ Player not found: ${playerIdStr}`);
              return null;
            }
            
            // Only create payment for players and captains, skip referees and stat-keepers
            if (player.role !== "player" && player.role !== "captain" && player.role !== "free-agent") {
              console.log(`⏭️ Skipping payment for ${player.email} (role: ${player.role})`);
              return null;
            }
            
            // Create payment
            const payment = await createPayment(playerId, leagueId, teamId);
            console.log(`✅ Payment created for ${player.email} (${player.role}): $${payment.amount}`);
            return payment;
          } catch (error: any) {
            console.error(`❌ Error creating payment for player ${playerIdStr}:`, error);
            return null;
          }
        });
        
        // Wait for all payments to be created (don't fail if some fail)
        await Promise.allSettled(paymentPromises);
        console.log(`✅ Payment creation process completed for team ${team.teamName}`);
      } catch (paymentError: any) {
        // Log error but don't fail the invitation acceptance
        console.error("❌ Error creating payments (non-fatal):", paymentError);
      }

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      await notification.populate("sender", "firstName lastName email");
      await notification.populate("league", "leagueName logo");
      await notification.populate("team", "teamName image");
      await notification.populate("receiver", "firstName lastName email");

      return NextResponse.json(
        {
          success: true,
          message: "Invite accepted successfully. Your team has been added to the league. Payment records have been created for all team members.",
          data: notification
        },
        { status: 200 }
      );
    }

    // Handle TEAM_INVITE (existing functionality)
    if (notificationType === "TEAM_INVITE") {
      const teamId = toObjectId(notification.team.toString());
      const team = await Team.findById(teamId);
      
      if (!team) {
        return NextResponse.json(
          { success: false, error: "Team not found" },
          { status: 404 }
        );
      }

      const format = notification.format;
      if (!format || !["5v5", "7v7"].includes(format)) {
        return NextResponse.json(
          { success: false, error: "Invalid format in notification" },
          { status: 400 }
        );
      }

      const squadField = format === "5v5" ? "squad5v5" : "squad7v7";
      const squadPlayers = (team as any)[squadField].map((p: any) => p.toString());
      
      if (squadPlayers.includes(userId.toString())) {
        return NextResponse.json(
          { success: false, error: `You are already in the ${format} squad for this team` },
          { status: 400 }
        );
      }

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      // Add player to the correct squad
      const updateQuery: any = {};
      updateQuery[`$addToSet`] = { [squadField]: userId };

      const updatedTeam = await Team.findByIdAndUpdate(
        teamId,
        updateQuery,
        { new: true }
      );

      if (!updatedTeam) {
        return NextResponse.json(
          { success: false, error: "Failed to add player to squad" },
          { status: 500 }
        );
      }

      await notification.populate("sender", "firstName lastName email");
      await notification.populate("team", "teamName image");
      await notification.populate("receiver", "firstName lastName email");

      return NextResponse.json(
        {
          success: true,
          message: "Invite accepted successfully. You have been added to the team.",
          data: notification
        },
        { status: 200 }
      );
    }

    return NextResponse.json(
      { success: false, error: "Unknown notification type" },
      { status: 400 }
    );
  } catch (error: any) {
    console.error("Error in acceptNotification:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to accept invite" },
      { status: 500 }
    );
  }
}

/**
 * Reject notification
 * POST /api/notification/reject
 * Body: { notificationId: string }
 */
export async function rejectNotification(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const { notificationId } = await req.json();

    if (!notificationId) {
      return NextResponse.json(
        { success: false, error: "notificationId is required" },
        { status: 400 }
      );
    }

    const notifObjectId = toObjectId(notificationId);
    const userId = toObjectId(decoded.userId);

    // Find notification
    const notification = await Notification.findById(notifObjectId);
    if (!notification) {
      return NextResponse.json(
        { success: false, error: "Notification not found" },
        { status: 404 }
      );
    }

    // Verify the notification belongs to the logged-in user
    const receiverId = toObjectId(notification.receiver.toString());
    if (receiverId.toString() !== userId.toString()) {
      return NextResponse.json(
        { success: false, error: "You can only reject your own invites" },
        { status: 403 }
      );
    }

    // Check if notification is still pending
    if (notification.status !== "pending") {
      return NextResponse.json(
        { success: false, error: `This invite has already been ${notification.status}` },
        { status: 400 }
      );
    }

    // Update notification status
    notification.status = "rejected";
    await notification.save();

    // Populate for response
    await notification.populate("sender", "firstName lastName email");
    if (notification.team) {
      await notification.populate("team", "teamName image");
    }
    if (notification.league) {
      await notification.populate("league", "leagueName logo");
    }
    await notification.populate("receiver", "firstName lastName email");

    return NextResponse.json(
      {
        success: true,
        message: "Invite rejected successfully",
        data: notification
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in rejectNotification:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to reject invite" },
      { status: 500 }
    );
  }
}

