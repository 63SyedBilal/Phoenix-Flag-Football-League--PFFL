import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import { verifyAccessToken } from "@/lib/jwt";
import { verifyPaymentOwnership, logPaymentAttempt } from "@/lib/payment-security";

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
 * Create Stripe Payment Intent
 * POST /api/payments/create-intent
 * Body: {
 *   paymentId: string
 * }
 * 
 * This endpoint creates a Payment Intent on Stripe's servers.
 * Returns a clientSecret that the frontend uses with Stripe Elements.
 */
export async function POST(req: NextRequest) {
  console.log("\n💳 ========== CREATE PAYMENT INTENT API CALLED ==========");

  try {
    await connectDB();
    console.log("✅ Database connected");

    // Verify user
    const decoded = await verifyUserToken(req);
    console.log("✅ User authenticated:", decoded.userId);

    // Parse request body
    const body = await req.json();
    const { paymentId } = body;

    console.log("📝 Payment Intent request data:");
    console.log("   - Payment ID:", paymentId);
    console.log("   - User ID:", decoded.userId);

    // Validate input
    if (!paymentId) {
      return NextResponse.json(
        { success: false, error: "Payment ID is required" },
        { status: 400 }
      );
    }

    // Verify payment ownership and status
    console.log("🔒 Step 1: Verifying payment ownership...");
    const verification = await verifyPaymentOwnership(paymentId, decoded.userId);

    if (!verification.valid) {
      logPaymentAttempt(decoded.userId, paymentId, false, verification.error);

      if (verification.errorCode === "ALREADY_PAID") {
        return NextResponse.json(
          {
            success: false,
            error: "This payment has already been processed",
            alreadyPaid: true,
            transactionId: verification.payment?.transactionId,
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
    console.log("   - Amount: $", payment.amount);
    console.log("   - Status:", payment.status);

    // Check if payment intent already exists for this payment
    if (payment.stripePaymentIntentId) {
      console.log("⚠️ Payment Intent already exists:", payment.stripePaymentIntentId);
      
      try {
        // Retrieve existing payment intent
        const stripe = getStripe();
        const existingIntent = await stripe.paymentIntents.retrieve(
          payment.stripePaymentIntentId
        );

        // If intent is still usable, return it
        if (existingIntent.status === "requires_payment_method" || 
            existingIntent.status === "requires_confirmation") {
          console.log("✅ Returning existing Payment Intent");
          return NextResponse.json(
            {
              success: true,
              clientSecret: existingIntent.client_secret,
              paymentIntentId: existingIntent.id,
              amount: payment.amount,
            },
            { status: 200 }
          );
        }
      } catch (err) {
        console.log("⚠️ Existing Payment Intent not found or invalid, creating new one");
      }
    }

    // Create new Payment Intent
    console.log("💳 Step 2: Creating Stripe Payment Intent...");
    
    const stripe = getStripe();
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(payment.amount * 100), // Convert to cents
      currency: "usd",
      automatic_payment_methods: {
        enabled: true,
      },
      description: `Payment for league ${payment.leagueId}`,
      metadata: {
        paymentId: payment._id.toString(),
        userId: payment.userId.toString(),
        leagueId: payment.leagueId.toString(),
        environment: process.env.NODE_ENV || "development",
      },
    });

    console.log("✅ Payment Intent created successfully!");
    console.log("   - Payment Intent ID:", paymentIntent.id);
    console.log("   - Status:", paymentIntent.status);
    console.log("   - Amount: $", paymentIntent.amount / 100);

    // Store Payment Intent ID in our database for reference
    payment.stripePaymentIntentId = paymentIntent.id;
    await payment.save();

    console.log("✅ Payment Intent ID saved to database");
    console.log("💳 ========== PAYMENT INTENT CREATED ==========\n");

    // Return client secret to frontend
    return NextResponse.json(
      {
        success: true,
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        amount: payment.amount,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("❌ Error creating Payment Intent:", error);

    // Handle specific error types
    if (error.message === "No token provided") {
      return NextResponse.json(
        { success: false, error: "Authentication required. Please log in and try again." },
        { status: 401 }
      );
    }

    if (error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: "Your session has expired. Please log in again." },
        { status: 401 }
      );
    }

    // Stripe errors
    if (error.type?.startsWith("Stripe")) {
      return NextResponse.json(
        {
          success: false,
          error: "Payment service error. Please try again.",
          technical: process.env.NODE_ENV === "development" ? error.message : undefined,
        },
        { status: 500 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: "An unexpected error occurred. Please try again.",
        technical: process.env.NODE_ENV === "development" ? error.message : undefined,
      },
      { status: 500 }
    );
  }
}

