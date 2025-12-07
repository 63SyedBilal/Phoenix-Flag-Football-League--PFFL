import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import { verifyAccessToken } from "@/lib/jwt";
import { logPaymentAttempt } from "@/lib/payment-security";

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
 * Confirm Payment Success and Update Database
 * POST /api/payments/confirm
 * Body: {
 *   paymentId: string,
 *   paymentIntentId: string
 * }
 * 
 * This endpoint is called after Stripe Elements successfully processes the payment.
 * It verifies the payment with Stripe and updates our database.
 */
export async function POST(req: NextRequest) {
  console.log("\n💳 ========== PAYMENT CONFIRMATION API CALLED ==========");

  try {
    await connectDB();
    console.log("✅ Database connected");

    // Verify user
    const decoded = await verifyUserToken(req);
    console.log("✅ User authenticated:", decoded.userId);

    // Parse request body
    const body = await req.json();
    const { paymentId, paymentIntentId } = body;

    console.log("📝 Payment confirmation data:");
    console.log("   - Payment ID:", paymentId);
    console.log("   - Payment Intent ID:", paymentIntentId);

    // Validate input
    if (!paymentId || !paymentIntentId) {
      return NextResponse.json(
        { success: false, error: "Payment ID and Payment Intent ID are required" },
        { status: 400 }
      );
    }

    // Find payment record
    console.log("🔍 Step 1: Finding payment record...");
    const payment = await Payment.findById(paymentId);

    if (!payment) {
      console.error("❌ Payment not found:", paymentId);
      logPaymentAttempt(decoded.userId, paymentId, false, "Payment not found");
      return NextResponse.json(
        { success: false, error: "Payment record not found" },
        { status: 404 }
      );
    }

    // Verify ownership
    if (payment.userId.toString() !== decoded.userId) {
      console.error("❌ SECURITY: Payment does not belong to user");
      logPaymentAttempt(decoded.userId, paymentId, false, "Unauthorized access attempt");
      return NextResponse.json(
        { success: false, error: "Unauthorized: You do not have permission to confirm this payment" },
        { status: 403 }
      );
    }

    console.log("✅ Payment found and verified:");
    console.log("   - Payment ID:", payment._id.toString());
    console.log("   - Current Status:", payment.status);
    console.log("   - Amount: $", payment.amount);

    // Check if already marked as paid
    if (payment.status === "paid") {
      console.log("⚠️ Payment already marked as paid");
      return NextResponse.json(
        {
          success: true,
          message: "Payment already confirmed",
          alreadyPaid: true,
          transactionId: payment.transactionId,
        },
        { status: 200 }
      );
    }

    // Verify with Stripe that payment succeeded
    console.log("🔍 Step 2: Verifying payment with Stripe...");
    const stripe = getStripe();
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    console.log("✅ Payment Intent retrieved:");
    console.log("   - Status:", paymentIntent.status);
    console.log("   - Amount: $", paymentIntent.amount / 100);

    // Check if payment succeeded
    if (paymentIntent.status !== "succeeded") {
      console.error("❌ Payment Intent not succeeded:", paymentIntent.status);
      logPaymentAttempt(decoded.userId, paymentId, false, `Payment status: ${paymentIntent.status}`);
      
      let errorMessage = "Payment was not successful. Please try again.";
      
      if (paymentIntent.status === "requires_payment_method") {
        errorMessage = "Payment failed. Please check your card details and try again.";
      } else if (paymentIntent.status === "requires_action") {
        errorMessage = "Additional authentication required. Please complete the authentication and try again.";
      } else if (paymentIntent.status === "processing") {
        errorMessage = "Payment is still processing. Please wait a moment and refresh the page.";
      } else if (paymentIntent.status === "canceled") {
        errorMessage = "Payment was canceled. Please try again.";
      }
      
      return NextResponse.json(
        {
          success: false,
          error: errorMessage,
          paymentStatus: paymentIntent.status,
        },
        { status: 400 }
      );
    }

    // Update payment record in database
    console.log("💾 Step 3: Updating payment record...");
    payment.status = "paid";
    payment.transactionId = paymentIntent.id;
    payment.paymentMethod = "stripe";
    await payment.save();

    console.log("✅ Payment record updated successfully!");
    console.log("   - Status:", payment.status);
    console.log("   - Transaction ID:", payment.transactionId);
    console.log("   - Payment Method:", payment.paymentMethod);

    // Log successful payment
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

    console.log("💳 ========== PAYMENT CONFIRMED SUCCESSFULLY ==========\n");

    return NextResponse.json(
      {
        success: true,
        message: "Payment confirmed successfully! Your payment has been processed.",
        transactionId: paymentIntent.id,
        data: payment,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("❌ Error confirming payment:", error);

    // Handle specific error types
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: "Authentication required. Please log in and try again." },
        { status: 401 }
      );
    }

    // Stripe errors
    if (error.type?.startsWith("Stripe")) {
      return NextResponse.json(
        {
          success: false,
          error: "Failed to verify payment with Stripe. Please contact support.",
          technical: process.env.NODE_ENV === "development" ? error.message : undefined,
        },
        { status: 500 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: "An unexpected error occurred while confirming your payment. Please contact support.",
        technical: process.env.NODE_ENV === "development" ? error.message : undefined,
      },
      { status: 500 }
    );
  }
}

