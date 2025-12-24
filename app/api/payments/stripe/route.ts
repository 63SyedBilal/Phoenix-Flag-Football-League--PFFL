import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import { verifyAccessToken } from "@/lib/jwt";
import { verifyPaymentOwnership, validateCardDetails, logPaymentAttempt } from "@/lib/payment-security";
import User from "@/modules/user";
import mongoose from "mongoose";

// Initialize Stripe lazily to avoid build-time errors
function getStripe() {
  const secretKey = process.env.STRIPE_SECRET_KEY;
  if (!secretKey) {
    throw new Error("STRIPE_SECRET_KEY environment variable is not set");
  }
  return new Stripe(secretKey, {
    apiVersion: "2025-11-17.clover",
  });
}

// Helper to get token from request
function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

// Helper to verify user from token
async function verifyUserToken(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");

  const decoded = verifyAccessToken(token);
  return decoded;
}

/**
 * Process Stripe payment
 * POST /api/payments/stripe
 * Body: {
 *   paymentId: string,
 *   cardNumber: string,
 *   expiryDate: string,
 *   cvv: string
 * }
 */
export async function POST(req: NextRequest) {
  console.log("\n💳 ========== STRIPE PAYMENT API CALLED ==========");

  try {
    await connectDB();
    console.log("✅ Database connected");

    // Verify user
    const decoded = await verifyUserToken(req);
    console.log("✅ User authenticated:", decoded.userId);

    // Parse request body
    const body = await req.json();
    const { paymentId, cardNumber, expiryDate, cvv } = body;

    console.log("📝 Payment request data:");
    console.log("   - Payment ID:", paymentId);
    console.log("   - Card Details: [REDACTED FOR SECURITY]");

    // Validate input
    if (!paymentId) {
      return NextResponse.json(
        { success: false, error: "Payment ID is required" },
        { status: 400 }
      );
    }

    if (!cardNumber || !expiryDate || !cvv) {
      return NextResponse.json(
        { success: false, error: "Card details are required" },
        { status: 400 }
      );
    }

    // ✔️ Step A — Find and verify payment record with security checks
    console.log("💳 Step A: Finding and verifying payment record...");

    const verification = await verifyPaymentOwnership(paymentId, decoded.userId);

    if (!verification.valid) {
      logPaymentAttempt(decoded.userId, paymentId, false, verification.error);

      if (verification.errorCode === "ALREADY_PAID") {
        return NextResponse.json(
          {
            success: false,
            error: verification.error,
            alreadyPaid: true,
            transactionId: verification.payment?.transactionId
          },
          { status: 400 }
        );
      }

      const statusCode = verification.errorCode === "UNAUTHORIZED" ? 403 : 404;
      return NextResponse.json(
        { success: false, error: verification.error },
        { status: statusCode }
      );
    }

    const payment = verification.payment;

    console.log("✅ Payment verified:");
    console.log("   - Payment ID:", payment._id.toString());
    console.log("   - User ID:", payment.userId.toString());
    console.log("   - Amount: $", payment.amount);
    console.log("   - Status:", payment.status);

    // Validate card details format
    const cardValidation = validateCardDetails(cardNumber, expiryDate, cvv);
    if (!cardValidation.valid) {
      logPaymentAttempt(decoded.userId, paymentId, false, cardValidation.error);
      return NextResponse.json(
        { success: false, error: cardValidation.error },
        { status: 400 }
      );
    }

    // ✔️ Step B — Process Stripe charge
    console.log("💳 Step B: Processing Stripe charge...");

    try {
      // Parse expiry date (MM/YY)
      const [exp_month, exp_year] = expiryDate.split("/");
      const fullYear = `20${exp_year}`;

      const stripe = getStripe();
      let paymentMethodId: string;
      const cleanCardNumber = cardNumber.replace(/\s/g, "");

      // 🧪 SPECIAL HANDLING FOR TEST CARDS: 
      // Sending raw card data to Stripe requires special approval (PCI DSS). 
      // In test mode, we use pm_card_visa for the standard test card to bypass this.
      if (cleanCardNumber === "4242424242424242") {
        console.log("🧪 Test card detected, using pm_card_visa for testing");
        paymentMethodId = "pm_card_visa";
      } else {
        console.log("💳 Creating payment method...");
        // Create a payment method with the card details
        const paymentMethod = await stripe.paymentMethods.create({
          type: "card",
          card: {
            number: cleanCardNumber,
            exp_month: parseInt(exp_month),
            exp_year: parseInt(fullYear),
            cvc: cvv,
          },
        });
        paymentMethodId = paymentMethod.id;
        console.log("✅ Payment method created:", paymentMethodId);
      }

      console.log("💳 Creating payment intent...");
      // Create a payment intent
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(payment.amount * 100), // Convert to cents
        currency: "usd",
        payment_method: paymentMethodId,
        confirm: true,
        automatic_payment_methods: {
          enabled: true,
          allow_redirects: "never",
        },
        description: `Payment for league ${payment.leagueId}`,
        metadata: {
          paymentId: payment._id.toString(),
          userId: payment.userId.toString(),
          leagueId: payment.leagueId.toString(),
        },
      });

      console.log("✅ Payment intent created:", paymentIntent.id);
      console.log("   - Status:", paymentIntent.status);
      console.log("   - Amount: $", paymentIntent.amount / 100);

      // Check if payment was successful
      if (paymentIntent.status !== "succeeded") {
        console.error("❌ Payment intent failed:", paymentIntent.status);
        return NextResponse.json(
          {
            success: false,
            error: `Payment failed: ${paymentIntent.status}`,
          },
          { status: 400 }
        );
      }

      // ✔️ Step C — Update DB
      console.log("💳 Step C: Updating payment record in database...");
      try {
        payment.status = "paid";
        payment.transactionId = paymentIntent.id;
        payment.stripePaymentIntentId = paymentIntent.id;
        payment.paymentMethod = "stripe";

        const savedPayment = await payment.save();
        console.log("✅ Payment record updated successfully!");
        console.log("   - New Status:", savedPayment.status);
        console.log("   - Transaction ID:", savedPayment.transactionId);

        // 🔄 Update User Role if they are a Free Agent
        console.log("🔄 Checking if user role needs update...");
        const user = await User.findById(payment.userId);

        if (user && user.role === "free-agent") {
          console.log(`🔄 User ${user.email} is a free-agent. Updating to player...`);
          user.role = "player";
          await user.save();
          console.log("✅ User role updated to 'player'");
        } else if (user) {
          console.log(`ℹ️ User role is ${user.role}, no update needed.`);
        }

      } catch (err: any) {
        console.error("❌ Database update failed:", err.message);
      }

      // Log successful payment attempt
      logPaymentAttempt(decoded.userId, paymentId, true);

      // Populate for response
      await payment.populate({
        path: "userId",
        select: "firstName lastName email role",
        model: "User",
      });
      await payment.populate({
        path: "leagueId",
        select: "leagueName logo format startDate endDate",
        model: "League",
      });

      console.log("💳 ========== STRIPE PAYMENT SUCCESSFUL ==========\n");

      return NextResponse.json(
        {
          success: true,
          message: "Payment processed successfully! Your payment has been confirmed.",
          transactionId: paymentIntent.id,
          data: payment,
        },
        { status: 200 }
      );
    } catch (stripeError: any) {
      console.error("❌ Stripe error:", stripeError);
      logPaymentAttempt(decoded.userId, paymentId, false, stripeError.message);

      // Provide user-friendly error messages
      let errorMessage = "Payment processing failed. Please try again.";

      if (stripeError.type === "StripeCardError") {
        errorMessage = stripeError.message || "Your card was declined. Please check your card details or try a different card.";
      } else if (stripeError.type === "StripeInvalidRequestError") {
        errorMessage = "Invalid payment information. Please check your details and try again.";
      }

      return NextResponse.json(
        {
          success: false,
          error: errorMessage,
        },
        { status: 400 }
      );
    }
  } catch (error: any) {
    console.error("❌ Error in Stripe payment API:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      {
        success: false,
        error: error.message || "Failed to process payment",
      },
      { status: 500 }
    );
  }
}

