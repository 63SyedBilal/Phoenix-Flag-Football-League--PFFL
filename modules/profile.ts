import mongoose from "mongoose";

const ProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true
    },

    yearOfExperience: {
      type: Number,
      default: 0
    },

    position: {
      type: String,
      trim: true,
      default: ""
    },

    jerseyNumber: {
      type: Number,
      default: null
    },

    emergencyNumber: {
      type: String,
      required: true,
      trim: true
    },

    emergencyPhoneNumber: {
      type: String,
      required: true,
      trim: true
    },

    image: {
      type: String,  // Cloudinary URL
      default: ""
    },

    paymentStatus: {
      type: String,
      enum: ["paid", "unpaid", "pending"],
      default: "unpaid"
    }
  },
  { timestamps: true }
);

// Prevent model overwrite error in Next.js development
// Delete the model if it exists to force recompilation with new schema
if (mongoose.models.Profile) {
  delete mongoose.models.Profile;
}

const Profile = mongoose.model("Profile", ProfileSchema);

export default Profile;

