import mongoose from "mongoose";
import { hashPassword, verifyPassword } from "@/lib/auth";

const UserSchema = new mongoose.Schema(
  {
    firstName: {
      type: String,
      default: "",
      trim: true,
    },
    lastName: {
      type: String,
      default: "",
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: {
      type: String,
  trim: true,
  unique: true,
  sparse: true,      // 💯 THIS FIXES THE ERROR
  default: undefined // make sure nothing like "" or null is stored
    },
    password: {
      type: String,
      select: false,
    },
    role: {
      type: String,
      enum: ["player", "captain", "referee", "stat-keeper", "free-agent"],
      default: "free-agent",
    },
  },
  { timestamps: true }
);

// Convert empty phone strings to undefined to avoid unique constraint issues
UserSchema.pre("save", function () {
  if (this.phone === "" || this.phone === null) {
    this.phone = undefined;
  }
});

// Hash password before saving (only if password is provided)
UserSchema.pre("save", async function () {
  if (this.isModified("password") && this.password) {
    try {
      // Only hash if password is not already hashed (doesn't start with $2a$ or $2b$)
      if (!this.password.startsWith("$2a$") && !this.password.startsWith("$2b$")) {
        console.log("🔐 Hashing password for user:", this.email);
        this.password = await hashPassword(this.password);
        console.log("✅ Password hashed successfully");
      } else {
        console.log("🔐 Password already hashed, skipping");
      }
    } catch (error) {
      console.error("❌ Error hashing password:", error);
      throw error;
    }
  }
});

// Method to compare password
UserSchema.methods.comparePassword = async function (candidatePassword: string) {
  if (!this.password) {
    return false;
  }
  return verifyPassword(candidatePassword, this.password);
};

// Prevent model overwrite error in Next.js development
// Delete the model if it exists to force recompilation with new schema
if (mongoose.models.User) {
  delete mongoose.models.User;
}

const User = mongoose.model("User", UserSchema);

export default User;
