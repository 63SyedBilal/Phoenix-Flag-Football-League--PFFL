import mongoose from "mongoose";

const StatSchema = new mongoose.Schema(
    {
        leagueId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "League",
            required: true,
        },
        matchId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Match",
            required: true,
        },
        teamId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Team",
            required: true,
        },
        playerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        stats: {
            catches: { type: Number, default: 0 },
            catchYards: { type: Number, default: 0 },
            rushes: { type: Number, default: 0 },
            rushYards: { type: Number, default: 0 },
            passAttempts: { type: Number, default: 0 },
            passYards: { type: Number, default: 0 },
            completions: { type: Number, default: 0 },
            touchdowns: { type: Number, default: 0 },
            flagPull: { type: Number, default: 0 },
            sack: { type: Number, default: 0 },
            interceptions: { type: Number, default: 0 },
            safeties: { type: Number, default: 0 },
            extraPoints: { type: Number, default: 0 },
        },
        createdBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        status: {
            type: String,
            enum: ["DRAFT", "PENDING_APPROVAL", "APPROVED"],
            default: "DRAFT",
        },
    },
    { timestamps: true }
);

// Prevent model overwrite error in Next.js development
if (mongoose.models.Stat) {
    delete mongoose.models.Stat;
}

const Stat = mongoose.model("Stat", StatSchema);
export default Stat;
