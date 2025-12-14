import mongoose from "mongoose";

const MatchSchema = new mongoose.Schema(
  {
    leagueId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "League",
      required: true,
    },

    teamA: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
      required: true,
    },

    teamAName: {
      type: String,
      default: "",
    },

    teamB: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
      required: true,
    },

    teamBName: {
      type: String,
      default: "",
    },

    gameDate: {
      type: Date,
      required: true,
    },

    gameTime: {
      type: String,
      required: true,
    },

    venue: {
      type: String,
      default: "",
    },

    refereeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    statKeeperId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    roundName: {
      type: String,
      default: "Group Stage",
    },

    gameNumber: {
      type: String,
      default: "",
    },

    status: {
      type: String,
      enum: ["upcoming", "live", "completed", "cancelled"],
      default: "upcoming",
    },

    homeScore: {
      type: Number,
      default: null,
    },

    awayScore: {
      type: Number,
      default: null,
    },
  },
  { timestamps: true }
);

// Prevent model overwrite error in Next.js development
if (mongoose.models.Match) {
  delete mongoose.models.Match;
}

const Match = mongoose.model("Match", MatchSchema);

export default Match;

