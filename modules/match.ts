import mongoose from "mongoose";

/* ================= PLAYER STATS ================= */

const PlayerStatsSchema = new mongoose.Schema(
  {
    playerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    catches: { type: Number, default: 0 },
    catchYards: { type: Number, default: 0 },

    rushes: { type: Number, default: 0 },
    rushYards: { type: Number, default: 0 },

    touchdowns: { type: Number, default: 0 },
    extraPoints: { type: Number, default: 0 },

    defensiveTDs: { type: Number, default: 0 },
    safeties: { type: Number, default: 0 },

    flags: { type: Number, default: 0 },

    totalPoints: { type: Number, default: 0 }
  },
  { _id: false }
);

/* ================= TEAM STATS (GAME SUMMARY) ================= */

const TeamStatsSchema = new mongoose.Schema(
  {
    catches: { type: Number, default: 0 },
    catchYards: { type: Number, default: 0 },

    rushes: { type: Number, default: 0 },
    rushYards: { type: Number, default: 0 },

    touchdowns: { type: Number, default: 0 },
    extraPoints: { type: Number, default: 0 },

    defensiveTDs: { type: Number, default: 0 },
    safeties: { type: Number, default: 0 },

    flags: { type: Number, default: 0 },

    totalPoints: { type: Number, default: 0 }
  },
  { _id: false }
);

/* ================= TEAM MATCH ================= */

const TeamMatchSchema = new mongoose.Schema(
  {
    teamId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
      required: true
    },

    side: {
      type: String,
      enum: ["offense", "defense"],
      required: true
    },

    players: [
      {
        playerId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
          required: true
        },
        isActive: {
          type: Boolean,
          default: false
        }
      }
    ],

    playerActions: [
      {
        playerId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
          required: true
        },
        actionType: {
          type: String,
          enum: [
            "Touchdown",
            "Extra Point from 5-yard line",
            "Extra Point from 12-yard line",
            "Extra Point from 20-yard line",
            "Defensive Touchdown",
            "Extra Point Return only",
            "Safety"
          ],
          required: true
        },
        timestamp: {
          type: Date,
          default: Date.now
        },

      }
    ],

    playerStats: [PlayerStatsSchema],

    teamStats: {
      type: TeamStatsSchema,
      default: () => ({})
    },

    score: {
      type: Number,
      default: 0
    },

    win: {
      type: Boolean,
      default: null
    }
  },
  { _id: false }
);

/* ================= MATCH ================= */

const MatchSchema = new mongoose.Schema(
  {
    /* -------- REFERENCES -------- */

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

    /* -------- GAME INFO -------- */

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
      enum: ["upcoming", "continue", "completed"],
      default: "upcoming"
    },

    timesSwitched: {
      type: String,
      enum: ["halfTime", "fullTime", "overtime", null],
      default: null
    },
    gameWinnerTeam: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
      default: null
    },


    /* -------- TEAMS (LEFT / RIGHT) -------- */

    teamA: {
      type: TeamMatchSchema,
      required: true
    },

    teamB: {
      type: TeamMatchSchema,
      required: true
    },

    /* -------- META -------- */

    roundName: {
      type: String,
      default: "Group Stage"
    },

    gameNumber: {
      type: String,
      default: ""
    },

    // Tournament Match Classification
    matchType: {
      type: String,
      enum: ["league", "semi-final-1", "semi-final-2", "final"],
      default: "league"
    },

    tournamentRound: {
      type: Number, // 1 for league, 2 for semi-finals, 3 for final
      default: 1
    },

    isKnockout: {
      type: Boolean,
      default: false
    },

    // Winner tracking for knockout matches
    winner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team"
    },

    // Tiebreaker information
    tiebreakerUsed: {
      type: Boolean,
      default: false
    },

    tiebreakerType: {
      type: String,
      enum: ["extra-time", "penalties", "random"],
    },

    completedAt: {
      type: Date,
      default: null
    }
  },
  { timestamps: true }
);

/* ================= SAFE EXPORT ================= */

if (mongoose.models.Match) {
  delete mongoose.models.Match;
}

const Match = mongoose.model("Match", MatchSchema);
export default Match;


