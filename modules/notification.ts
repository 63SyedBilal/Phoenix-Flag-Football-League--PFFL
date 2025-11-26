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
      required: true
    },

    type: {
      type: String,
      enum: ["TEAM_INVITE"],
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
      required: true
    }
  },
  { timestamps: true }
);

// Prevent model overwrite error in Next.js development
if (mongoose.models.Notification) {
  delete mongoose.models.Notification;
}

const Notification = mongoose.model("Notification", NotificationSchema);

export default Notification;

