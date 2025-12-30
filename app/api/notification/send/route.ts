import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import SuperAdmin from "@/modules/superadmin";
import User from "@/modules/user";
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

export async function POST(req: NextRequest) {
    try {
        await connectDB();
        const decoded = await verifyUserToken(req);
        const userId = decoded.userId;

        const body = await req.json();
        const {
            type,
            message,
            isAdmin,
            receiverId,
            teamId,
            leagueId,
            matchId,
            paymentId,
            // Data for formatting
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
            transactionId,
            oldCaptainName,
            userName,
            userEmail,
            role,
            creatorName,
            reportType,
            matchResult,
            championship,
            stage
        } = body;

        let receiverObjectId;

        if (isAdmin) {
            // Find SPECIFIC SuperAdmin to send to: pffl@gmail.com
            let admin = await User.findOne({
                email: "pffl@gmail.com",
                role: "superadmin"
            });
            if (!admin) {
                admin = await SuperAdmin.findOne({ email: "pffl@gmail.com" });
            }
            if (!admin) {
                return NextResponse.json(
                    { error: "Specific admin pffl@gmail.com not found" },
                    { status: 404 }
                );
            }
            receiverObjectId = admin._id;
        } else if (receiverId) {
            receiverObjectId = new mongoose.Types.ObjectId(receiverId);
        } else {
            return NextResponse.json(
                { error: "Receiver is required" },
                { status: 400 }
            );
        }

        // Format the message using the helper function
        const notificationData = {
            teamName, captainName, playerName, leagueName, amount, dueDate, receiptNumber,
            venue, matchDate, matchTime, teamA, teamB, opponentTeam, newDate, newTime,
            refereeName, statKeeperName, transactionId, oldCaptainName, userName, userEmail,
            role, creatorName, reportType, matchResult, championship, stage
        };

        const formattedMessage = message || formatNotificationMessage(type, notificationData);

        const notification = await Notification.create({
            sender: new mongoose.Types.ObjectId(userId),
            receiver: receiverObjectId,
            team: teamId ? new mongoose.Types.ObjectId(teamId) : undefined,
            league: leagueId ? new mongoose.Types.ObjectId(leagueId) : undefined,
            match: matchId ? new mongoose.Types.ObjectId(matchId) : undefined,
            type: type || 'GENERAL_NOTIFICATION',
            status: 'pending',
            message: formattedMessage,
            data: notificationData // Store additional data for future reference
        });

        return NextResponse.json(
            { message: "Notification sent successfully", data: notification },
            { status: 201 }
        );
    } catch (error: any) {
        console.error("Error sending notification:", error);
        return NextResponse.json(
            { error: error.message || "Failed to send notification" },
            { status: 500 }
        );
    }
}

// Import the formatting function
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
    championship,
    stage
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
      return `Your team has advanced to the ${stage || 'next round'}! Match scheduled for ${matchDate || 'TBD'}.`;

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
