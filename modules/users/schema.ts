import mongoose, { Schema, Document, Model } from "mongoose"
import { hashPassword, verifyPassword } from "@/lib/auth"

export interface IUser extends Document {
  firstName: string
  lastName: string
  email: string
  phoneNumber: string
  password: string
  role: "free-agent" | "captain" | "player" | "referee" | "stat-keeper" | "superadmin"
  leagueId?: mongoose.Types.ObjectId | null
  teamId?: mongoose.Types.ObjectId | null
  createdAt: Date
  updatedAt: Date
}

export interface IUserMethods {
  comparePassword(candidatePassword: string): Promise<boolean>
  getFullName(): string
}

export type UserModel = Model<IUser, {}, IUserMethods>

const UserSchema = new Schema<IUser, UserModel, IUserMethods>(
  {
    firstName: {
      type: String,
      required: [true, "First name is required"],
      trim: true,
      maxlength: [50, "First name cannot exceed 50 characters"],
    },
    lastName: {
      type: String,
      required: [true, "Last name is required"],
      trim: true,
      maxlength: [50, "Last name cannot exceed 50 characters"],
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, "Please provide a valid email address"],
      index: true,
    },
    phoneNumber: {
      type: String,
      required: [true, "Phone number is required"],
      trim: true,
      match: [/^\+?[\d\s\-()]+$/, "Please provide a valid phone number"],
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [8, "Password must be at least 8 characters long"],
      select: false, // Never send password in API response
    },
    role: {
      type: String,
      enum: ["free-agent", "captain", "player", "referee", "stat-keeper", "superadmin"],
      default: "free-agent",
    },
    leagueId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "League",
      default: null,
    },
    teamId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Team",
      default: null,
    },
  },
  {
    timestamps: true,
  }
)

// Indexes for faster queries
UserSchema.index({ email: 1 })
UserSchema.index({ role: 1 })
UserSchema.index({ leagueId: 1 })
UserSchema.index({ teamId: 1 })
UserSchema.index({ createdAt: -1 })

// Method to compare password
UserSchema.methods.comparePassword = async function (
  candidatePassword: string
): Promise<boolean> {
  return verifyPassword(candidatePassword, this.password)
}

// Method to get full name
UserSchema.methods.getFullName = function (): string {
  return `${this.firstName} ${this.lastName}`
}

// Pre-save hook to hash password before saving
UserSchema.pre("save", async function (next) {
  // Only hash the password if it has been modified (or is new)
  if (!this.isModified("password")) return next()

  try {
    // Hash the password
    this.password = await hashPassword(this.password)
    next()
  } catch (error: any) {
    next(error)
  }
})

// Virtual for full name
UserSchema.virtual("fullName").get(function () {
  return `${this.firstName} ${this.lastName}`
})

// Ensure virtual fields are serialized
UserSchema.set("toJSON", {
  virtuals: true,
  transform: function (doc, ret) {
    delete ret.password
    delete ret.__v
    return ret
  },
})

UserSchema.set("toObject", {
  virtuals: true,
  transform: function (doc, ret) {
    delete ret.password
    delete ret.__v
    return ret
  },
})

// Export the model
export const User =
  (mongoose.models.User as UserModel) ||
  mongoose.model<IUser, UserModel>("User", UserSchema)



