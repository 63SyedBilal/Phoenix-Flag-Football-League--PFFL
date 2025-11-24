import mongoose, { Schema, Document, Model } from "mongoose"
import { verifyPassword, hashPassword } from "@/lib/auth"

export interface ILogin extends Document {
  email: string
  password: string
  role: "player" | "captain" | "referee" | "stat-keeper" | "superadmin" | "free-agent"
  isActive: boolean
  lastLogin?: Date
  loginAttempts: number
  lockUntil?: Date
  createdAt: Date
  updatedAt: Date
}

export interface ILoginMethods {
  comparePassword(candidatePassword: string): Promise<boolean>
  isLocked(): boolean
  incrementLoginAttempts(): Promise<void>
  resetLoginAttempts(): Promise<void>
}

export type LoginModel = Model<ILogin, {}, ILoginMethods>

const LoginSchema = new Schema<ILogin, LoginModel, ILoginMethods>(
  {
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, "Please provide a valid email address"],
      index: true,
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [8, "Password must be at least 8 characters long"],
      select: false, // Don't return password by default
    },
    role: {
      type: String,
      enum: ["player", "captain", "referee", "stat-keeper", "superadmin", "free-agent"],
      required: [true, "Role is required"],
      default: "player",
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastLogin: {
      type: Date,
    },
    loginAttempts: {
      type: Number,
      default: 0,
    },
    lockUntil: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
)

// Index for faster queries
LoginSchema.index({ email: 1 })
LoginSchema.index({ role: 1 })
LoginSchema.index({ isActive: 1 })

// Method to compare password
LoginSchema.methods.comparePassword = async function (
  candidatePassword: string
): Promise<boolean> {
  return verifyPassword(candidatePassword, this.password)
}

// Method to check if account is locked
LoginSchema.methods.isLocked = function (): boolean {
  return !!(this.lockUntil && this.lockUntil > new Date())
}

// Method to increment login attempts
LoginSchema.methods.incrementLoginAttempts = async function (): Promise<void> {
  // If we have a previous lock that has expired, restart at 1
  if (this.lockUntil && this.lockUntil < new Date()) {
    return this.updateOne({
      $set: { loginAttempts: 1 },
      $unset: { lockUntil: 1 },
    })
  }

  const updates: any = { $inc: { loginAttempts: 1 } }

  // Lock account after 5 failed attempts for 2 hours
  if (this.loginAttempts + 1 >= 5 && !this.isLocked()) {
    updates.$set = { lockUntil: Date.now() + 2 * 60 * 60 * 1000 } // 2 hours
  }

  return this.updateOne(updates)
}

// Method to reset login attempts
LoginSchema.methods.resetLoginAttempts = async function (): Promise<void> {
  return this.updateOne({
    $set: { loginAttempts: 0, lastLogin: new Date() },
    $unset: { lockUntil: 1 },
  })
}

// Virtual for account lock status
LoginSchema.virtual("isAccountLocked").get(function () {
  return this.isLocked()
})

// Pre-save hook to hash password before saving
LoginSchema.pre("save", async function (next) {
  // Only hash the password if it has been modified (or is new)
  if (!this.isModified("password")) return next()

  try {
    // Hash the password with cost of 12
    this.password = await hashPassword(this.password)
    next()
  } catch (error: any) {
    next(error)
  }
})

// Export the model
export const Login =
  (mongoose.models.Login as LoginModel) ||
  mongoose.model<ILogin, LoginModel>("Login", LoginSchema)

