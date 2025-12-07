import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import { verifyAccessToken } from "@/lib/jwt";

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
 * Process payment (Stripe or PayPal)
 * POST /api/payments/process
 * Body: {
 *   paymentId: string,
 *   paymentMethod: "stripe" | "paypal",
 *   cardNumber: string (for Stripe),
 *   expiryDate: string (for Stripe),
 *   cvv: string (for Stripe),
 *   idempotencyKey?: string (optional, for double-click protection)
 * }
 */
export async function POST(req: NextRequest) {
  console.log("\n💳 ========== PAYMENT PROCESSING API CALLED ==========");

  try {
    await connectDB();
    console.log("✅ Database connected");

    // Verify user
    const decoded = await verifyUserToken(req);
    console.log("✅ User authenticated:", decoded.userId);

    // Parse request body
    const body = await req.json();
    const { 
      paymentId, 
      paymentMethod, 
      cardNumber, 
      expiryDate, 
      cvv,
      idempotencyKey 
    } = body;

    console.log("📝 Payment request data:");
    console.log("   - Payment ID:", paymentId);
    console.log("   - Payment Method:", paymentMethod);
    console.log("   - Idempotency Key:", idempotencyKey || "Not provided");
    console.log("   - Card Details: [REDACTED FOR SECURITY]");

    // Validate input
    if (!paymentId) {
      return NextResponse.json(
        { success: false, error: "Payment ID is required" },
        { status: 400 }
      );
    }

    if (!paymentMethod || !["stripe", "paypal"].includes(paymentMethod)) {
      return NextResponse.json(
        { success: false, error: "Valid payment method is required (stripe or paypal)" },
        { status: 400 }
      );
    }

    // ✔️ Step A — Find and validate payment record
    console.log("💳 Step A: Finding and validating payment record...");
    const payment = await Payment.findById(paymentId);

    if (!payment) {
      console.error("❌ Payment not found:", paymentId);
      return NextResponse.json(
        { success: false, error: "Payment record not found" },
        { status: 404 }
      );
    }

    console.log("✅ Payment found:");
    console.log("   - Payment ID:", payment._id.toString());
    console.log("   - User ID:", payment.userId.toString());
    console.log("   - Amount: $", payment.amount);
    console.log("   - Status:", payment.status);

    // 🔒 SECURITY CHECK: Verify payment belongs to authenticated user
    if (payment.userId.toString() !== decoded.userId) {
      console.error("❌ SECURITY VIOLATION: Payment does not belong to user");
      console.error("   - Payment User ID:", payment.userId.toString());
      console.error("   - Authenticated User ID:", decoded.userId);
      return NextResponse.json(
        { success: false, error: "Unauthorized: You do not have permission to process this payment" },
        { status: 403 }
      );
    }

    // 🔒 IDEMPOTENCY CHECK: Prevent double charging
    if (payment.status === "paid") {
      console.error("❌ Payment already processed (idempotency protection)");
      console.log("   - Transaction ID:", payment.transactionId);
      console.log("   - Payment Method:", payment.paymentMethod);
      return NextResponse.json(
        { 
          success: false, 
          error: "This payment has already been processed",
          alreadyPaid: true,
          transactionId: payment.transactionId
        },
        { status: 400 }
      );
    }

    // Process based on payment method
    if (paymentMethod === "stripe") {
      return await processStripePayment(payment, cardNumber, expiryDate, cvv, idempotencyKey);
    } else if (paymentMethod === "paypal") {
      return NextResponse.json(
        { success: false, error: "PayPal integration coming soon" },
        { status: 501 }
      );
    }

    return NextResponse.json(
      { success: false, error: "Invalid payment method" },
      { status: 400 }
    );
  } catch (error: any) {
    console.error("❌ Error in payment processing API:", error);
    
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

    return NextResponse.json(
      {
        success: false,
        error: "An unexpected error occurred while processing your payment. Please try again.",
        technical: process.env.NODE_ENV === "development" ? error.message : undefined
      },
      { status: 500 }
    );
  }
}

/**
 * Process Stripe payment
 */
async function processStripePayment(
  payment: any,
  cardNumber: string,
  expiryDate: string,
  cvv: string,
  idempotencyKey?: string
) {
  console.log("💳 Step B: Processing Stripe payment...");

  // Validate Stripe-specific fields
  if (!cardNumber || !expiryDate || !cvv) {
    return NextResponse.json(
      { success: false, error: "Card details are required for Stripe payments" },
      { status: 400 }
    );
  }

  try {
    // Parse expiry date (MM/YY)
    const [exp_month, exp_year] = expiryDate.split("/");
    
    if (!exp_month || !exp_year || exp_month.length !== 2 || exp_year.length !== 2) {
      return NextResponse.json(
        { success: false, error: "Invalid expiry date format. Please use MM/YY format." },
        { status: 400 }
      );
    }

    const fullYear = `20${exp_year}`;
    const cleanCardNumber = cardNumber.replace(/\s/g, "");

    // Validate card number length
    if (cleanCardNumber.length < 13 || cleanCardNumber.length > 19) {
      return NextResponse.json(
        { success: false, error: "Invalid card number. Please check and try again." },
        { status: 400 }
      );
    }

    // Validate CVV length
    if (cvv.length < 3 || cvv.length > 4) {
      return NextResponse.json(
        { success: false, error: "Invalid CVV. Please enter 3 or 4 digits." },
        { status: 400 }
      );
    }

    console.log("💳 Creating payment method...");
    // Create a payment method with the card details
    const stripe = getStripe();
    const paymentMethod = await stripe.paymentMethods.create({
      type: "card",
      card: {
        number: cleanCardNumber,
        exp_month: parseInt(exp_month),
        exp_year: parseInt(fullYear),
        cvc: cvv,
      },
    });

    console.log("✅ Payment method created:", paymentMethod.id);

    console.log("💳 Creating payment intent...");
    
    // Prepare payment intent options
    const paymentIntentOptions: any = {
      amount: Math.round(payment.amount * 100), // Convert to cents
      currency: "usd",
      payment_method: paymentMethod.id,
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
        environment: process.env.NODE_ENV || "development"
      },
    };

    // Add idempotency key if provided (prevents duplicate charges)
    if (idempotencyKey) {
      paymentIntentOptions.idempotency_key = idempotencyKey;
      console.log("🔒 Using idempotency key for duplicate prevention");
    }

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create(
      paymentIntentOptions,
      idempotencyKey ? { idempotencyKey } : undefined
    );

    console.log("✅ Payment intent created:", paymentIntent.id);
    console.log("   - Status:", paymentIntent.status);
    console.log("   - Amount: $", paymentIntent.amount / 100);

    // Check if payment was successful
    if (paymentIntent.status !== "succeeded") {
      console.error("❌ Payment intent failed:", paymentIntent.status);
      
      // Provide user-friendly error messages
      let errorMessage = "Payment failed. Please try again.";
      
      if (paymentIntent.status === "requires_payment_method") {
        errorMessage = "Your card was declined. Please check your card details or try a different card.";
      } else if (paymentIntent.status === "requires_action") {
        errorMessage = "Additional authentication is required. Please contact your bank.";
      } else if (paymentIntent.status === "requires_confirmation") {
        errorMessage = "Payment confirmation failed. Please try again.";
      }
      
      return NextResponse.json(
        {
          success: false,
          error: errorMessage,
          paymentStatus: paymentIntent.status
        },
        { status: 400 }
      );
    }

    // ✔️ Step C — Update Database
    console.log("💳 Step C: Updating payment record in database...");
    payment.status = "paid";
    payment.transactionId = paymentIntent.id;
    payment.paymentMethod = "stripe";
    await payment.save();

    console.log("✅ Payment record updated successfully!");
    console.log("   - Status:", payment.status);
    console.log("   - Transaction ID:", payment.transactionId);
    console.log("   - Payment Method:", payment.paymentMethod);

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
    
    // Provide user-friendly error messages based on Stripe error type
    let errorMessage = "Payment processing failed. Please try again.";
    
    if (stripeError.type === "StripeCardError") {
      errorMessage = stripeError.message || "Your card was declined. Please check your card details or try a different card.";
    } else if (stripeError.type === "StripeInvalidRequestError") {
      errorMessage = "Invalid payment information. Please check your details and try again.";
    } else if (stripeError.type === "StripeAPIError") {
      errorMessage = "Payment service is temporarily unavailable. Please try again in a few moments.";
    } else if (stripeError.type === "StripeConnectionError") {
      errorMessage = "Network error. Please check your connection and try again.";
    } else if (stripeError.type === "StripeAuthenticationError") {
      errorMessage = "Payment service authentication error. Please contact support.";
    }
    
    return NextResponse.json(
      {
        success: false,
        error: errorMessage,
        errorType: stripeError.type,
        technical: process.env.NODE_ENV === "development" ? stripeError.message : undefined
      },
      { status: 400 }
    );
  }
}

