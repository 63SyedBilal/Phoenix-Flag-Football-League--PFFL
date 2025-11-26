import mongoose from "mongoose";

const SuperAdminSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
    },

    password: {
      type: String,
      required: true,
      select: false,
    },

    role: {
      type: String,
      default: "superadmin",
      enum: ["superadmin"],
    },
  },
  { timestamps: true }
);

// Prevent model overwrite error in Next.js development
const SuperAdmin = mongoose.models.SuperAdmin || mongoose.model("SuperAdmin", SuperAdminSchema);

export default SuperAdmin;

