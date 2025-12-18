import mongoose from "mongoose";

const TeamMatchSchema = new mongoose.Schema(
  {
    teamId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
      required: true
    },

    initialSide: {
      type: String,
      enum: ["offense", "defense"],
      required: true
    },

    attendance: [
      {
        playerId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
          required: true
        },
        present: {
          type: Boolean,
          default: false
        }
      }
    ],

    activePlayers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ],

    score: {
      type: Number,
      default: 0
    },

    playerPoints: [
      {
        playerId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
          required: true
        },
        points: {
          type: Number,
          required: true,
          default: 0
        }
      }
    ],

    result: {
      type: String,
      enum: ["win", "loss", "draw"],
      default: null
    }
  },
  { _id: false }
);

const MatchSchema = new mongoose.Schema(
  {
    /* ============ CORE REFERENCES ============ */

    leagueId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "League",
      required: true
    },

    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    refereeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null
    },

    statKeeperId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null
    },

    /* ============ MATCH INFO ============ */

    format: {
      type: String,
      enum: ["5v5", "7v7"],
      required: true
    },

    venue: {
      type: String,
      default: ""
    },

    gameDate: {
      type: Date,
      required: true
    },

    gameTime: {
      type: String,
      required: true
    },

    status: {
      type: String,
      enum: ["upcoming", "live", "halfTime", "completed", "cancelled"],
      default: "upcoming"
    },

    tossWinnerTeam: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
      default: null
    },

    halfTimeSwitched: {
      type: Boolean,
      default: false
    },

    /* ============ TEAMS ============ */

    teamA: {
      type: TeamMatchSchema,
      required: true
    },

    teamB: {
      type: TeamMatchSchema,
      required: true
    },

    /* ============ ADDITIONAL FIELDS ============ */

    roundName: {
      type: String,
      default: "Group Stage"
    },

    gameNumber: {
      type: String,
      default: ""
    },

    completedAt: {
      type: Date,
      default: null
    }
  },
  { timestamps: true }
);

/* ============ SAFE EXPORT ============ */

if (mongoose.models.Match) {
  delete mongoose.models.Match;
}

const Match = mongoose.model("Match", MatchSchema);
export default Match;

