import mongoose from "mongoose";

const TeamSchema = new mongoose.Schema(
  {
    teamName: {
      type: String,
      required: true,
      trim: true
    },

    enterCode: {
      type: String,
      required: false,
      unique: true,
      sparse: true, // Allow multiple null/undefined values
      trim: true
    },

    location: {
      type: String,
      required: true,
      trim: true
    },

    skillLevel: {
      type: String,
      enum: ["beginner", "intermediate", "advanced", "professional"],
      default: "beginner"
    },

    image: {
      type: String, // cloudinary URL
      default: ""
    },

    captain: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true
    },

    squad5v5: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ],

    squad7v7: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ],

  },
  { timestamps: true }
);

// Virtual to get all unique players from both squads
TeamSchema.virtual("allPlayers").get(function() {
  const squad5v5Ids = (this.squad5v5 || []).map((id: any) => id.toString())
  const squad7v7Ids = (this.squad7v7 || []).map((id: any) => id.toString())
  const allIds = [...new Set([...squad5v5Ids, ...squad7v7Ids])]
  return allIds
})

// Prevent model overwrite error in Next.js development
// Delete the model if it exists to force recompilation with new schema
if (mongoose.models.Team) {
  delete mongoose.models.Team;
}

const Team = mongoose.model("Team", TeamSchema);

export default Team;

