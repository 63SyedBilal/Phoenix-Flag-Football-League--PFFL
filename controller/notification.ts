import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import Team from "@/modules/team";
import User from "@/modules/user";
import League from "@/modules/league";
import { verifyAccessToken } from "@/lib/jwt";
import mongoose from "mongoose";

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
 * Helper function to format notification messages with proper variables
 */
function formatNotificationMessage(type: string, data: any = {}): string {
  const {
    teamName,
    captainName,
    playerName,
    leagueName,
    amount,
    dueDate,
    receiptNumber,
    venue,
    matchDate,
    matchTime,
    teamA,
    teamB,
    opponentTeam,
    newDate,
    newTime,
    refereeName,
    statKeeperName,
    paymentId,
    transactionId,
    oldCaptainName,
    userName,
    userEmail,
    role,
    creatorName,
    reportType,
    matchResult,
    championship
  } = data;

  switch (type) {
    // Player Notifications
    case "TEAM_INVITE":
      return `You have been invited to join ${teamName || 'a team'} by Captain ${captainName || 'Unknown'}`;

    case "TEAM_INVITE_ACCEPTED":
      return `Your invitation to ${teamName || 'a team'} has been accepted. Welcome to the team!`;

    case "TEAM_INVITE_REJECTED":
      return `Your invitation to ${teamName || 'a team'} has been declined`;

    case "REMOVED_FROM_TEAM":
      return `You have been removed from ${teamName || 'a team'}`;

    case "GAME_ASSIGNED":
      return `You have been assigned to the match: ${teamA || 'Team A'} vs ${teamB || 'Team B'} at ${venue || 'TBD'} on ${matchDate || 'TBD'} at ${matchTime || 'TBD'}`;

    case "PAYMENT_DUE":
      return `Payment of $${amount || '0.00'} is due for ${leagueName || 'league'}. Please complete payment by ${dueDate || 'due date'}`;

    case "PAYMENT_SUCCESS":
      return `Your payment of $${amount || '0.00'} for ${leagueName || 'league'} has been successfully processed. Receipt ID: ${receiptNumber || 'N/A'}`;

    case "MATCH_UPDATE":
      return `Match update: ${teamA || 'Team A'} vs ${teamB || 'Team B'} has been rescheduled to ${newDate || 'new date'} at ${newTime || 'new time'}`;

    case "LEAGUE_START":
      return `${leagueName || 'League'} starts on ${matchDate || 'start date'}. Get ready to play!`;

    // Captain Notifications
    case "PLAYER_JOINED_TEAM":
      return `${playerName || 'A player'} has joined your team ${teamName || 'Unknown'}`;

    case "PLAYER_LEFT_TEAM":
      return `${playerName || 'A player'} has left your team ${teamName || 'Unknown'}`;

    case "TEAM_INVITE_SENT":
      return `Invitation sent to ${playerName || 'a player'} to join ${teamName || 'your team'}`;

    case "TEAM_INVITE_ACCEPTED_BY_PLAYER":
      return `${playerName || 'A player'} has accepted your invitation and joined ${teamName || 'your team'}`;

    case "TEAM_INVITE_REJECTED_BY_PLAYER":
      return `${playerName || 'A player'} has declined your invitation to join ${teamName || 'your team'}`;

    case "LEAGUE_REGISTRATION_SUCCESS":
      return `Your team ${teamName || 'Unknown'} has been successfully registered for ${leagueName || 'a league'}`;

    case "TEAM_PAYMENT_DUE":
      return `Team registration payment of $${amount || '0.00'} is due for ${leagueName || 'league'}. Please complete payment by ${dueDate || 'due date'}`;

    case "TEAM_PAYMENT_SUCCESS":
      return `Team registration payment of $${amount || '0.00'} for ${leagueName || 'league'} has been successfully processed. Receipt ID: ${receiptNumber || 'N/A'}`;

    case "MATCH_SCHEDULED":
      return `Match scheduled: ${teamName || 'Your team'} vs ${opponentTeam || 'Opponent'} on ${matchDate || 'date'} at ${matchTime || 'time'} at ${venue || 'venue'}`;

    case "LEADERSHIP_TRANSFERRED":
      return `Team leadership of ${teamName || 'your team'} has been transferred to ${captainName || 'new captain'}`;

    case "LEADERSHIP_RECEIVED":
      return `You are now the captain of ${teamName || 'a team'}. Leadership transferred from ${oldCaptainName || 'previous captain'}`;

    // Referee Notifications
    case "REFEREE_ASSIGNED":
      return `You have been assigned as referee for: ${teamA || 'Team A'} vs ${teamB || 'Team B'} at ${venue || 'venue'} on ${matchDate || 'date'} at ${matchTime || 'time'}`;

    case "REFEREE_RESCHEDULED":
      return `Referee assignment updated: ${teamA || 'Team A'} vs ${teamB || 'Team B'} rescheduled to ${newDate || 'new date'} at ${newTime || 'new time'} at ${venue || 'venue'}`;

    case "REFEREE_REMINDER_24H":
      return `Reminder: You are refereeing ${teamA || 'Team A'} vs ${teamB || 'Team B'} tomorrow at ${matchTime || 'time'} at ${venue || 'venue'}`;

    case "REFEREE_REMINDER_1H":
      return `Match starting soon: ${teamA || 'Team A'} vs ${teamB || 'Team B'} at ${venue || 'venue'} starts in 1 hour`;

    case "REFEREE_PAYMENT_RECEIVED":
      return `Payment of $${amount || '0.00'} received for refereeing ${teamA || 'Team A'} vs ${teamB || 'Team B'} on ${matchDate || 'date'}. Receipt ID: ${receiptNumber || 'N/A'}`;

    // Stat Keeper Notifications
    case "STATKEEPER_ASSIGNED":
      return `You have been assigned as stat keeper for: ${teamA || 'Team A'} vs ${teamB || 'Team B'} at ${venue || 'venue'} on ${matchDate || 'date'} at ${matchTime || 'time'}`;

    case "STATKEEPER_RESCHEDULED":
      return `Stat keeper assignment updated: ${teamA || 'Team A'} vs ${teamB || 'Team B'} rescheduled to ${newDate || 'new date'} at ${newTime || 'new time'} at ${venue || 'venue'}`;

    case "STATKEEPER_REMINDER_24H":
      return `Reminder: You are keeping stats for ${teamA || 'Team A'} vs ${teamB || 'Team B'} tomorrow at ${matchTime || 'time'} at ${venue || 'venue'}`;

    case "STATKEEPER_REMINDER_1H":
      return `Match starting soon: ${teamA || 'Team A'} vs ${teamB || 'Team B'} at ${venue || 'venue'} starts in 1 hour`;

    case "STATKEEPER_PAYMENT_RECEIVED":
      return `Payment of $${amount || '0.00'} received for stat keeping ${teamA || 'Team A'} vs ${teamB || 'Team B'} on ${matchDate || 'date'}. Receipt ID: ${receiptNumber || 'N/A'}`;

    // Free Agent Notifications
    case "PROFILE_VERIFIED":
      return `Your free agent profile has been verified and is now visible to teams`;

    case "TEAM_INVITE_RECEIVED":
      return `You have received an invitation to join ${teamName || 'a team'} by Captain ${captainName || 'Unknown'}`;

    case "PROFILE_VIEWED":
      return `Captain ${captainName || 'Unknown'} from ${teamName || 'a team'} viewed your profile`;

    case "JOINED_TEAM_SUCCESS":
      return `Congratulations! You have successfully joined ${teamName || 'a team'}`;

    // Admin Notifications
    case "NEW_USER_REGISTRATION":
      return `New user registered: ${userName || 'Unknown'} as ${role || 'user'} on ${matchDate || 'date'}`;

    case "PAYMENT_RECEIVED":
      return `Payment received: ${userName || 'User'} paid $${amount || '0.00'} for ${leagueName || 'service'}. Payment ID: ${paymentId || 'N/A'}`;

    case "LEAGUE_PAYMENT_RECEIVED":
      return `League Payment: ${playerName || 'Player'} paid $${amount || '0.00'} for ${leagueName || 'league'} - ${teamName || 'Team'} on ${matchDate || 'date'} at ${matchTime || 'time'}. Payment ID: ${paymentId || 'N/A'}`;

    case "TEAM_PAYMENT_RECEIVED":
      return `Team Registration Payment: Captain ${captainName || 'Captain'} paid $${amount || '0.00'} for ${teamName || 'Team'} in ${leagueName || 'league'} on ${matchDate || 'date'} at ${matchTime || 'time'}. Payment ID: ${paymentId || 'N/A'}`;

    case "REFEREE_PAYMENT_RECEIVED":
      return `Referee Payment: $${amount || '0.00'} paid to Referee ${refereeName || 'Unknown'} for ${teamA || 'Team A'} vs ${teamB || 'Team B'} on ${matchDate || 'date'}. Payment ID: ${paymentId || 'N/A'}`;

    case "STATKEEPER_PAYMENT_RECEIVED":
      return `Stat Keeper Payment: $${amount || '0.00'} paid to Stat Keeper ${statKeeperName || 'Unknown'} for ${teamA || 'Team A'} vs ${teamB || 'Team B'} on ${matchDate || 'date'}. Payment ID: ${paymentId || 'N/A'}`;

    case "LEAGUE_CREATED":
      return `New league created: ${leagueName || 'Unknown'} by ${creatorName || 'Unknown'} starting ${matchDate || 'date'}`;

    case "TEAM_REGISTRATION":
      return `Team Registration: ${teamName || 'Team'} registered for ${leagueName || 'league'} by Captain ${captainName || 'Captain'}`;

    case "MATCH_COMPLETED":
      return `Match completed: ${teamA || 'Team A'} ${matchResult || 'vs'} ${teamB || 'Team B'} in ${leagueName || 'league'}`;

    case "REPORT_RECEIVED":
      return `New report submitted by ${userName || 'User'}: ${reportType || 'General'} report`;

    case "REFUND_REQUESTED":
      return `Refund requested: ${userName || 'User'} requested refund of $${amount || '0.00'} for payment ID: ${paymentId || 'N/A'}`;

    // Tournament Notifications
    case "TOURNAMENT_ADVANCEMENT":
      return `Your team has advanced to the ${data.stage || 'next round'}! Match scheduled for ${matchDate || 'TBD'}.`;

    case "CHAMPIONSHIP_WON":
      return `🎉 Congratulations! ${teamName || 'Your team'} has won the ${leagueName || 'league'} championship! 🏆`;

    case "TOURNAMENT_COMPLETED":
      return `🏆 ${championship || 'Champion team'} has won the ${leagueName || 'league'} championship!`;

    // Legacy types
    case "LEAGUE_REFEREE_INVITE":
    case "LEAGUE_STATKEEPER_INVITE":
    case "LEAGUE_TEAM_INVITE":
    case "INVITE_ACCEPTED_REFEREE":
    case "INVITE_ACCEPTED_STATKEEPER":
    case "INVITE_ACCEPTED_TEAM":
    case "STATS_APPROVAL_REQUEST":
    case "STATS_APPROVED":
      return data.message || `Notification: ${type}`;

    default:
      return `Notification: ${type}`;
  }
}

/**
 * Helper function to check if a player is already on another team
 * @param playerId - The player's user ID
 * @param currentTeamId - The team ID to exclude from check (allows same team different format)
 * @returns Object with isOnTeam flag, teamId, and teamName if found
 */
async function checkPlayerTeamMembership(
  playerId: string | mongoose.Types.ObjectId,
  currentTeamId: string | mongoose.Types.ObjectId
): Promise<{ isOnTeam: boolean; teamId: string | null; teamName: string | null }> {
  try {
    const playerObjectId = typeof playerId === 'string' 
      ? new mongoose.Types.ObjectId(playerId) 
      : playerId;
    const currentTeamObjectId = typeof currentTeamId === 'string'
      ? new mongoose.Types.ObjectId(currentTeamId)
      : currentTeamId;

    // Find any team where player is in squad5v5 or squad7v7, excluding current team
    const existingTeam = await Team.findOne({
      $or: [
        { squad5v5: playerObjectId },
        { squad7v7: playerObjectId }
      ],
      _id: { $ne: currentTeamObjectId } // Exclude current team (allows same team different format)
    }).lean();

    if (existingTeam) {
      return {
        isOnTeam: true,
        teamId: (existingTeam as any)._id.toString(),
        teamName: (existingTeam as any).teamName || null
      };
    }

    return {
      isOnTeam: false,
      teamId: null,
      teamName: null
    };
  } catch (error: any) {
    console.error("Error checking player team membership:", error);
    // On error, assume player is not on team to avoid blocking valid invites
    return {
      isOnTeam: false,
      teamId: null,
      teamName: null
    };
  }
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

    // Check if player is already on another team (strict team locking)
    // This prevents sending invites that will be rejected
    const teamMembershipCheck = await checkPlayerTeamMembership(playerId, teamId);
    if (teamMembershipCheck.isOnTeam) {
      return NextResponse.json(
        { 
          error: `Player is already on another team (${teamMembershipCheck.teamName || 'Unknown'}). They must be removed from their current team before you can invite them.` 
        },
        { status: 409 }
      );
    }

    // Convert IDs to ObjectIds
    const senderId = new mongoose.Types.ObjectId(decoded.userId);
    const receiverId = new mongoose.Types.ObjectId(playerId);
    const teamObjectId = new mongoose.Types.ObjectId(teamId);

    // Check if there's already a pending invite for this format
    const existingNotification = await Notification.findOne({
      sender: senderId,
      receiver: receiverId,
      team: teamObjectId,
      format: format,
      status: "pending"
    });

    if (existingNotification) {
      return NextResponse.json(
        { error: `Invite already sent to this player for ${format} format` },
        { status: 409 }
      );
    }

    // Create notification with format using ObjectIds
    const notification = await Notification.create({
      sender: senderId,
      receiver: receiverId,
      team: teamObjectId,
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

    console.log("Getting notifications for user:", decoded.userId);

    // Try both string and ObjectId matching
    const userId = decoded.userId.toString();
    const notifications = await Notification.find({
      $or: [
        { receiver: userId },
        { receiver: decoded.userId }
      ],
      status: "pending"
    })
      .populate({
        path: "sender",
        select: "firstName lastName email",
        model: "User"
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
        path: "receiver",
        select: "firstName lastName email",
        model: "User"
      })
      .sort({ createdAt: -1 });

    console.log(`Found ${notifications.length} notifications for user ${userId}`);
    console.log("Notification types:", notifications.map((n: any) => ({ 
      type: n.type, 
      receiver: n.receiver?.toString() || n.receiver,
      sender: n.sender && typeof n.sender === 'object' && 'firstName' in n.sender 
        ? `${n.sender.firstName} ${n.sender.lastName}` 
        : "null",
      league: n.league && typeof n.league === 'object' && 'leagueName' in n.league
        ? n.league.leagueName 
        : "null",
      team: n.team && typeof n.team === 'object' && 'teamName' in n.team
        ? n.team.teamName 
        : "null"
    })));

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

    const notificationType = notification.type;

    // Handle TEAM_INVITE
    if (notificationType === "TEAM_INVITE") {
      // Get team - notification.team might be ObjectId or populated object
      const teamId = notification.team?.toString ? notification.team.toString() : (notification.team as any)?._id?.toString() || notification.team;
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

      // Check if player is already on another team (strict team locking)
      const teamMembershipCheck = await checkPlayerTeamMembership(decoded.userId, teamId);
      if (teamMembershipCheck.isOnTeam) {
        return NextResponse.json(
          { 
            error: `You are already on another team (${teamMembershipCheck.teamName || 'Unknown'}). You must be removed from your current team before joining a new team.` 
          },
          { status: 409 }
        );
      }

      // Get the user to check and update role
      const user = await User.findById(decoded.userId);
      if (!user) {
        return NextResponse.json(
          { error: "User not found" },
          { status: 404 }
        );
      }

      // Track if role was changed
      const wasFreeAgent = user.role === "free-agent";
      const previousRole = user.role;

      // Ensure user role is "player" (not just for free-agents)
      // Only update if role is not already "player" or "captain"
      if (user.role !== "player" && user.role !== "captain") {
        console.log(`🔄 Changing user role from ${user.role} to player for user: ${user.email}`);
        user.role = "player";
        await user.save();
        console.log(`✅ User role updated to player`);
      }

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

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      // Create notification to Captain that invite was accepted
      try {
        const captainId = (team as any).captain;
        const playerObjectId = new mongoose.Types.ObjectId(decoded.userId);
        const teamObjectId = new mongoose.Types.ObjectId(teamId);

        const captainNotification = await Notification.create({
          sender: playerObjectId, // Player who accepted
          receiver: captainId, // Captain
          team: teamObjectId,
          type: "TEAM_INVITE_ACCEPTED",
          status: "pending",
          format: format
        });

        console.log(`✅ Captain notification created: ${captainNotification._id.toString()}`);
        console.log(`   Player: ${user.firstName} ${user.lastName} (${user.email})`);
        console.log(`   Team: ${(team as any).teamName}`);
        console.log(`   Format: ${format}`);
      } catch (notifError: any) {
        console.error("❌ Error creating captain notification:", notifError);
        // Don't fail the invite acceptance if notification creation fails
        // This is a non-critical operation
      }

      // Populate for response
      await notification.populate("sender", "firstName lastName email");
      await notification.populate("team", "teamName image");
      await notification.populate("receiver", "firstName lastName email");

      // Populate updated team for response
      await updatedTeam.populate("captain", "firstName lastName email role");
      await (updatedTeam as any).populate("squad5v5", "firstName lastName email role");
      await (updatedTeam as any).populate("squad7v7", "firstName lastName email role");
      await (updatedTeam as any).populate("players", "firstName lastName email role");

      const roleChanged = previousRole !== user.role;
      const roleChangeMessage = roleChanged 
        ? ` Your role has been updated from ${previousRole} to player.` 
        : "";

      return NextResponse.json(
        {
          message: `Invite accepted successfully. You have been added to the ${format} squad.${roleChangeMessage}`,
          data: notification,
          team: updatedTeam, // Include updated team data for frontend refresh
          roleChanged: roleChanged,
          newRole: user.role
        },
        { status: 200 }
      );
    }

    // Handle LEAGUE_REFEREE_INVITE
    if (notificationType === "LEAGUE_REFEREE_INVITE") {
      const leagueId = notification.league?.toString ? notification.league.toString() : (notification.league as any)?._id?.toString() || notification.league;
      const league = await League.findById(leagueId);
      
      if (!league) {
        return NextResponse.json(
          { error: "League not found" },
          { status: 404 }
        );
      }

      const refereeId = decoded.userId.toString();
      const referees = (league as any).referees || [];
      
      if (referees.some((r: any) => r.toString() === refereeId)) {
        return NextResponse.json(
          { error: "You are already a referee in this league" },
          { status: 400 }
        );
      }

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      // Add referee to league
      (league as any).referees.push(decoded.userId);
      await league.save();

      await notification.populate("sender", "firstName lastName email");
      await notification.populate("league", "leagueName");
      await notification.populate("receiver", "firstName lastName email");

      return NextResponse.json(
        {
          message: "Invite accepted successfully. You have been added as a referee to the league.",
          data: notification
        },
        { status: 200 }
      );
    }

    // Handle LEAGUE_STATKEEPER_INVITE
    if (notificationType === "LEAGUE_STATKEEPER_INVITE") {
      const leagueId = notification.league?.toString ? notification.league.toString() : (notification.league as any)?._id?.toString() || notification.league;
      const league = await League.findById(leagueId);
      
      if (!league) {
        return NextResponse.json(
          { error: "League not found" },
          { status: 404 }
        );
      }

      const statKeeperId = decoded.userId.toString();
      const statKeepers = (league as any).statKeepers || [];
      
      if (statKeepers.some((sk: any) => sk.toString() === statKeeperId)) {
        return NextResponse.json(
          { error: "You are already a stat keeper in this league" },
          { status: 400 }
        );
      }

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      // Add stat keeper to league
      (league as any).statKeepers.push(decoded.userId);
      await league.save();

      await notification.populate("sender", "firstName lastName email");
      await notification.populate("league", "leagueName");
      await notification.populate("receiver", "firstName lastName email");

      return NextResponse.json(
        {
          message: "Invite accepted successfully. You have been added as a stat keeper to the league.",
          data: notification
        },
        { status: 200 }
      );
    }

    // Handle LEAGUE_TEAM_INVITE
    if (notificationType === "LEAGUE_TEAM_INVITE") {
      console.log("🔵 ========== LEAGUE_TEAM_INVITE ACCEPTANCE START ==========");
      console.log("🔵 Notification ID:", notification._id);
      console.log("🔵 Notification Type:", notificationType);
      
      const leagueId = notification.league?.toString ? notification.league.toString() : (notification.league as any)?._id?.toString() || notification.league;
      console.log("🔵 League ID (raw):", notification.league);
      console.log("🔵 League ID (processed):", leagueId);
      
      const league = await League.findById(leagueId);
      console.log("🔵 League found:", league ? "YES" : "NO");
      
      if (!league) {
        console.error("❌ League not found with ID:", leagueId);
        return NextResponse.json(
          { error: "League not found" },
          { status: 404 }
        );
      }
      
      console.log("🔵 League Name:", (league as any).leagueName);
      console.log("🔵 League Fee:", (league as any).perPlayerLeagueFee);

      const teamId = notification.team?.toString ? notification.team.toString() : (notification.team as any)?._id?.toString() || notification.team;
      console.log("🔵 Team ID (raw):", notification.team);
      console.log("🔵 Team ID (processed):", teamId);
      
      const team = await Team.findById(teamId);
      console.log("🔵 Team found:", team ? "YES" : "NO");
      
      if (!team) {
        console.error("❌ Team not found with ID:", teamId);
        return NextResponse.json(
          { error: "Team not found" },
          { status: 404 }
        );
      }
      
      console.log("🔵 Team Name:", team.teamName);
      console.log("🔵 Team Captain ID:", team.captain);
      console.log("🔵 Decoded User ID:", decoded.userId);

      // Verify user is the captain of the team
      if (team.captain.toString() !== decoded.userId) {
        console.error("❌ User is not the captain. Team captain:", team.captain.toString(), "User:", decoded.userId);
        return NextResponse.json(
          { error: "Only the team captain can accept league invitations" },
          { status: 403 }
        );
      }
      
      console.log("✅ User is the captain - proceeding");

      const teams = (league as any).teams || [];
      console.log("🔵 Current teams in league:", teams.length);
      
      if (teams.some((t: any) => t.toString() === teamId)) {
        console.error("❌ Team already in league");
        return NextResponse.json(
          { error: "Team is already in this league" },
          { status: 400 }
        );
      }

      // Add team to league
      console.log("🔵 Adding team to league...");
      (league as any).teams.push(teamId);
      await league.save();
      console.log("✅ Team added to league successfully");

      // Create payment records for all players in the team (including captain)
      // Only create payments for players and captains, not referees/stat-keepers
      console.log("🔵 ========== PAYMENT CREATION START ==========");
      try {
        // Import createPayment function
        console.log("🔵 Importing createPayment function...");
        const { createPayment } = await import("@/controller/payment");
        console.log("✅ createPayment imported successfully");
        
        // Helper to convert string ID to ObjectId
        const toObjectId = (id: string | any): mongoose.Types.ObjectId => {
          if (id instanceof mongoose.Types.ObjectId) {
            return id;
          }
          if (typeof id === 'string') {
            return new mongoose.Types.ObjectId(id);
          }
          return new mongoose.Types.ObjectId(id.toString());
        };

        // Get all unique player IDs from both squads
        console.log("🔵 Getting player IDs from squads...");
        console.log("🔵 squad5v5 (raw):", team.squad5v5);
        console.log("🔵 squad7v7 (raw):", team.squad7v7);
        console.log("🔵 captain (raw):", team.captain);
        
        const squad5v5Ids = (team.squad5v5 || []).map((id: any) => {
          if (id?.toString) return id.toString();
          if (id instanceof mongoose.Types.ObjectId) return id.toString();
          return String(id);
        });
        const squad7v7Ids = (team.squad7v7 || []).map((id: any) => {
          if (id?.toString) return id.toString();
          if (id instanceof mongoose.Types.ObjectId) return id.toString();
          return String(id);
        });
        const captainId = team.captain?.toString ? team.captain.toString() : String(team.captain);
        
        console.log("🔵 squad5v5 IDs:", squad5v5Ids);
        console.log("🔵 squad7v7 IDs:", squad7v7Ids);
        console.log("🔵 captain ID:", captainId);
        
        // Combine all player IDs (including captain) and remove duplicates
        const allPlayerIds = [...new Set([...squad5v5Ids, ...squad7v7Ids, captainId])];
        
        console.log(`💰 ========== PAYMENT CREATION FOR ${allPlayerIds.length} PLAYERS ==========`);
        console.log(`💰 Team Name: ${team.teamName}`);
        console.log(`💰 League Name: ${(league as any).leagueName}`);
        console.log(`💰 League ID: ${leagueId}`);
        console.log(`💰 Team ID: ${teamId}`);
        console.log(`💰 League Fee: $${(league as any).perPlayerLeagueFee}`);
        console.log(`💰 All Player IDs (${allPlayerIds.length}):`, allPlayerIds);
        
        // Create payment for each player
        console.log(`💰 Starting payment creation for ${allPlayerIds.length} players...`);
        const paymentPromises = allPlayerIds.map(async (playerIdStr: string, index: number) => {
          console.log(`\n💰 [${index + 1}/${allPlayerIds.length}] Processing player ID: ${playerIdStr}`);
          try {
            const playerId = toObjectId(playerIdStr);
            const leagueObjectId = toObjectId(leagueId);
            const teamObjectId = toObjectId(teamId);
            
            console.log(`💰 [${index + 1}] Converted IDs:`);
            console.log(`   - Player ID: ${playerId.toString()}`);
            console.log(`   - League ID: ${leagueObjectId.toString()}`);
            console.log(`   - Team ID: ${teamObjectId.toString()}`);
            
            // Get user to check role
            console.log(`💰 [${index + 1}] Looking up user in database...`);
            const player = await User.findById(playerId);
            if (!player) {
              console.error(`❌ [${index + 1}] Player not found in database: ${playerIdStr}`);
              return null;
            }
            
            console.log(`💰 [${index + 1}] User found:`);
            console.log(`   - Email: ${player.email}`);
            console.log(`   - Role: ${player.role}`);
            console.log(`   - Name: ${player.firstName} ${player.lastName}`);
            console.log(`   - User ID: ${player._id}`);
            
            // Only create payment for players and captains, skip referees and stat-keepers
            if (player.role !== "player" && player.role !== "captain" && player.role !== "free-agent") {
              console.log(`⏭️ [${index + 1}] Skipping payment for ${player.email} (role: ${player.role} - not eligible)`);
              return null;
            }
            
            // Create payment
            console.log(`💰 [${index + 1}] Calling createPayment function...`);
            console.log(`   - userId: ${playerId.toString()}`);
            console.log(`   - leagueId: ${leagueObjectId.toString()}`);
            console.log(`   - teamId: ${teamObjectId.toString()}`);
            
            const payment = await createPayment(playerId, leagueObjectId, teamObjectId);
            
            console.log(`✅ [${index + 1}] Payment created successfully!`);
            console.log(`   - Payment ID: ${payment._id}`);
            console.log(`   - Amount: $${payment.amount}`);
            console.log(`   - Status: ${payment.status}`);
            console.log(`   - User: ${player.firstName} ${player.lastName} (${player.email})`);
            console.log(`   - League: ${(league as any).leagueName}`);
            console.log(`   - Team: ${team.teamName}`);
            
            return payment;
          } catch (error: any) {
            console.error(`❌ [${index + 1}] ERROR creating payment for player ${playerIdStr}:`);
            console.error(`   - Error message: ${error.message}`);
            console.error(`   - Error stack: ${error.stack}`);
            if (error.response) {
              console.error(`   - Error response:`, error.response);
            }
            return null;
          }
        });
        
        // Wait for all payments to be created (don't fail if some fail)
        console.log(`💰 Waiting for all payment promises to complete...`);
        const results = await Promise.allSettled(paymentPromises);
        
        console.log(`\n💰 ========== PAYMENT CREATION RESULTS ==========`);
        const successful = results.filter(r => r.status === 'fulfilled' && r.value !== null).length;
        const failed = results.filter(r => r.status === 'rejected' || (r.status === 'fulfilled' && r.value === null)).length;
        const rejected = results.filter(r => r.status === 'rejected').length;
        
        console.log(`💰 Total players processed: ${allPlayerIds.length}`);
        console.log(`✅ Successful payments: ${successful}`);
        console.log(`❌ Failed/Skipped: ${failed}`);
        console.log(`💥 Rejected promises: ${rejected}`);
        
        // Log details of each result
        results.forEach((result, index) => {
          if (result.status === 'fulfilled' && result.value !== null) {
            console.log(`✅ [${index + 1}] Payment created: ${result.value._id}`);
          } else if (result.status === 'fulfilled' && result.value === null) {
            console.log(`⏭️ [${index + 1}] Payment skipped (player not eligible or not found)`);
          } else if (result.status === 'rejected') {
            console.error(`❌ [${index + 1}] Payment promise rejected:`, result.reason);
          }
        });
        
        console.log(`💰 ========== PAYMENT CREATION COMPLETE ==========\n`);
      } catch (paymentError: any) {
        // Log error but don't fail the invitation acceptance
        console.error("❌ ========== PAYMENT CREATION ERROR ==========");
        console.error("❌ Error type:", paymentError.constructor.name);
        console.error("❌ Error message:", paymentError.message);
        console.error("❌ Error stack:", paymentError.stack);
        if (paymentError.cause) {
          console.error("❌ Error cause:", paymentError.cause);
        }
        console.error("❌ ============================================\n");
      }

      // Update notification status
      notification.status = "accepted";
      await notification.save();

      await notification.populate("sender", "firstName lastName email");
      await notification.populate("league", "leagueName");
      await notification.populate("team", "teamName");
      await notification.populate("receiver", "firstName lastName email");

      return NextResponse.json(
        {
          message: "Invite accepted successfully. Your team has been added to the league. Payment records have been created for all team members.",
          data: notification
        },
        { status: 200 }
      );
    }

    return NextResponse.json(
      { error: "Unknown notification type" },
      { status: 400 }
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

    // Handle LEAGUE_TEAM_INVITE rejection
    // Note: Team is not added to league until accepted, so no need to remove on rejection
    if (notification.type === "LEAGUE_TEAM_INVITE") {
      console.log("🔴 League team invitation rejected - team was not added to league");
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
      await notification.populate("league", "leagueName");
    }
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

