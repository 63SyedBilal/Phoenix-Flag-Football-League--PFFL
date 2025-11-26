import mongoose from "mongoose";

const PaymentSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    leagueId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: "League", // Assuming you have a League model
    },
    amount: {
      type: Number,
      required: true,
      min: 0,
    },
    status: {
      type: String,
      enum: ["paid", "unpaid"],
      required: true,
      default: "unpaid",
    },
    transactionId: {
      type: String,
      trim: true,
    },
    // Payment method - required when status is "paid"
    paymentMethod: {
      type: String,
      enum: ["stripe", "paypal"],
      // Will be validated in controller when status is "paid"
    },
    // Team name - for players only
    teamName: {
      type: String,
      trim: true,
    },
    // Player name - for players
    playerName: {
      type: String,
      trim: true,
    },
    // Captain name - for captains
    captainName: {
      type: String,
      trim: true,
    },
    // Free agent name - for free agents
    freeAgentName: {
      type: String,
      trim: true,
    },
  },
  { timestamps: true }
);

// Pre-save validation: paymentMethod required if status is "paid"
PaymentSchema.pre("save", function (next) {
  if (this.status === "paid" && !this.paymentMethod) {
    return next(new Error("Payment method is required when status is 'paid'"));
  }
  next();
});

// Prevent model overwrite error in Next.js development
const Payment = mongoose.models.Payment || mongoose.model("Payment", PaymentSchema);

export default Payment;

