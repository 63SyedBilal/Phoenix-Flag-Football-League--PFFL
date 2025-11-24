import mongoose, { Schema, Document, Model } from "mongoose"
import { hashPassword } from "@/lib/auth"

export interface ISignup extends Document {
  firstName: string
  lastName: string
  email: string
  phoneNumber: string
  password: string
  accountType: "player" | "captain" | "free-agent"
  role?: "player" | "captain" | "referee" | "stat-keeper" | "superadmin" | "free-agent"
  
  // Profile information (for captain/player)
  profilePic?: string
  position?: string
  emergencyContactName?: string
  emergencyPhoneNumber?: string
  
  // Team information (for captain)
  teamLogo?: string
  teamName?: string
  teamColor?: string
  location?: string
  skillLevel?: "Recreational" | "Intermediate" | "Competitive"
  
  // Verification
  isEmailVerified: boolean
  emailVerificationToken?: string
  emailVerificationExpires?: Date
  
  // Status
  status: "pending" | "completed" | "active"
  signupStep: "signup" | "profile" | "team"
  
  createdAt: Date
  updatedAt: Date
}

export interface ISignupMethods {
  generateEmailVerificationToken(): string
  verifyEmailToken(token: string): boolean
}

export type SignupModel = Model<ISignup, {}, ISignupMethods>

const SignupSchema = new Schema<ISignup, SignupModel, ISignupMethods>(
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
      select: false, // Don't return password by default
    },
    accountType: {
      type: String,
      enum: ["player", "captain", "free-agent"],
      required: [true, "Account type is required"],
    },
    role: {
      type: String,
      enum: ["player", "captain", "referee", "stat-keeper", "superadmin", "free-agent"],
      default: function (this: ISignup) {
        // Map accountType to role
        if (this.accountType === "captain") return "captain"
        if (this.accountType === "player") return "player"
        return "free-agent"
      },
    },
    
    // Profile information
    profilePic: {
      type: String,
      default: null,
    },
    position: {
      type: String,
      default: null,
    },
    emergencyContactName: {
      type: String,
      default: null,
    },
    emergencyPhoneNumber: {
      type: String,
      default: null,
    },
    
    // Team information (for captain)
    teamLogo: {
      type: String,
      default: null,
    },
    teamName: {
      type: String,
      default: null,
      maxlength: [100, "Team name cannot exceed 100 characters"],
    },
    teamColor: {
      type: String,
      default: null,
    },
    location: {
      type: String,
      default: null,
    },
    skillLevel: {
      type: String,
      enum: ["Recreational", "Intermediate", "Competitive"],
      default: null,
    },
    
    // Verification
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    emailVerificationToken: {
      type: String,
      default: null,
    },
    emailVerificationExpires: {
      type: Date,
      default: null,
    },
    
    // Status
    status: {
      type: String,
      enum: ["pending", "completed", "active"],
      default: "pending",
    },
    signupStep: {
      type: String,
      enum: ["signup", "profile", "team"],
      default: "signup",
    },
  },
  {
    timestamps: true,
  }
)

// Indexes for faster queries
SignupSchema.index({ email: 1 })
SignupSchema.index({ accountType: 1 })
SignupSchema.index({ role: 1 })
SignupSchema.index({ status: 1 })
SignupSchema.index({ emailVerificationToken: 1 })

// Method to generate email verification token
SignupSchema.methods.generateEmailVerificationToken = function (): string {
  const crypto = require("crypto")
  const token = crypto.randomBytes(32).toString("hex")
  
  this.emailVerificationToken = token
  this.emailVerificationExpires = Date.now() + 24 * 60 * 60 * 1000 // 24 hours
  
  return token
}

// Method to verify email token
SignupSchema.methods.verifyEmailToken = function (token: string): boolean {
  return (
    this.emailVerificationToken === token &&
    this.emailVerificationExpires &&
    this.emailVerificationExpires > new Date()
  )
}

// Pre-save hook to hash password before saving
SignupSchema.pre("save", async function (next) {
  // Only hash the password if it has been modified (or is new)
  if (this.isModified("password")) {
    try {
      this.password = await hashPassword(this.password)
    } catch (error: any) {
      return next(error)
    }
  }

  // Set role based on accountType if not already set
  if (this.isNew && !this.role) {
    if (this.accountType === "captain") {
      this.role = "captain"
    } else if (this.accountType === "player") {
      this.role = "player"
    } else {
      this.role = "free-agent"
    }
  }
  next()
})

// Export the model
export const Signup =
  (mongoose.models.Signup as SignupModel) ||
  mongoose.model<ISignup, SignupModel>("Signup", SignupSchema)

