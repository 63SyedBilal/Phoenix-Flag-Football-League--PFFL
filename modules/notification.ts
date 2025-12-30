import mongoose from "mongoose";

const NotificationSchema = new mongoose.Schema(
  {
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    }, // captain

    receiver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    }, // player

    team: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
    },

    league: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "League",
    },

    match: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Match",
    },

    type: {
      type: String,
      enum: [
        // Player Notifications
        "TEAM_INVITE", "TEAM_INVITE_ACCEPTED", "TEAM_INVITE_REJECTED", "REMOVED_FROM_TEAM",
        "GAME_ASSIGNED", "PAYMENT_DUE", "PAYMENT_SUCCESS", "MATCH_UPDATE", "LEAGUE_START",

        // Captain Notifications
        "PLAYER_JOINED_TEAM", "PLAYER_LEFT_TEAM", "TEAM_INVITE_SENT", "TEAM_INVITE_ACCEPTED_BY_PLAYER",
        "TEAM_INVITE_REJECTED_BY_PLAYER", "LEAGUE_REGISTRATION_SUCCESS", "TEAM_PAYMENT_DUE",
        "TEAM_PAYMENT_SUCCESS", "MATCH_SCHEDULED", "LEADERSHIP_TRANSFERRED", "LEADERSHIP_RECEIVED",

        // Referee Notifications
        "REFEREE_ASSIGNED", "REFEREE_RESCHEDULED", "MATCH_CANCELLED", "REFEREE_REMINDER_24H",
        "REFEREE_REMINDER_1H", "REFEREE_PAYMENT_RECEIVED",

        // Stat Keeper Notifications
        "STATKEEPER_ASSIGNED", "STATKEEPER_RESCHEDULED", "STATKEEPER_REMINDER_24H",
        "STATKEEPER_REMINDER_1H", "STATKEEPER_PAYMENT_RECEIVED",

        // Free Agent Notifications
        "PROFILE_VERIFIED", "TEAM_INVITE_RECEIVED", "PROFILE_VIEWED", "JOINED_TEAM_SUCCESS",

        // Admin Notifications
        "NEW_USER_REGISTRATION", "PAYMENT_RECEIVED", "LEAGUE_CREATED", "TEAM_REGISTRATION",
        "MATCH_COMPLETED", "REPORT_RECEIVED", "REFUND_REQUESTED", "LEAGUE_PAYMENT_RECEIVED",
        "TEAM_PAYMENT_RECEIVED", "REFEREE_PAYMENT_RECEIVED", "STATKEEPER_PAYMENT_RECEIVED",

        // Tournament Notifications
        "TOURNAMENT_ADVANCEMENT", "SEMI_FINAL_ASSIGNMENT", "FINAL_ASSIGNMENT", "CHAMPIONSHIP_WON",
        "TOURNAMENT_COMPLETED",

        // Legacy/Other
        "LEAGUE_REFEREE_INVITE", "LEAGUE_STATKEEPER_INVITE", "LEAGUE_TEAM_INVITE",
        "INVITE_ACCEPTED_REFEREE", "INVITE_ACCEPTED_STATKEEPER", "INVITE_ACCEPTED_TEAM",
        "STATS_APPROVAL_REQUEST", "STATS_APPROVED"
      ],
      default: "TEAM_INVITE"
    },

    status: {
      type: String,
      enum: ["pending", "accepted", "rejected"],
      default: "pending"
    },

    format: {
      type: String,
      enum: ["5v5", "7v7"],
    },
    message: {
      type: String,
      default: ""
    },
    data: {
      type: mongoose.Schema.Types.Mixed,
      default: {}
    }
  },
  { timestamps: true }
);

// Prevent model overwrite error in Next.js development
const Notification = mongoose.models.Notification || mongoose.model("Notification", NotificationSchema);

export default Notification;

