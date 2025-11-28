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
      ref: "League",
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
    stripePaymentIntentId: {
      type: String,
      trim: true,
    },
    paymentMethod: {
      type: String,
      enum: ["stripe", "paypal"],
    },

    teamName: { type: String, trim: true },
    playerName: { type: String, trim: true },
    captainName: { type: String, trim: true },
    freeAgentName: { type: String, trim: true },
  },
  { timestamps: true }
);

// 🔥 FIXED — async hook WITHOUT next()
PaymentSchema.pre("save", async function () {
  if (this.status === "paid" && !this.paymentMethod) {
    throw new Error("Payment method is required when status is 'paid'");
  }
});

// Prevent overwrite
const Payment =
  mongoose.models.Payment || mongoose.model("Payment", PaymentSchema);

export default Payment;
