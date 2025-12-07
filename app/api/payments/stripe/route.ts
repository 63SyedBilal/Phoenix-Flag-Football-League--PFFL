import { NextRequest, NextResponse } from "next/server";
import Stripe from "stripe";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import { verifyAccessToken } from "@/lib/jwt";
import { verifyPaymentOwnership, validateCardDetails, logPaymentAttempt } from "@/lib/payment-security";

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

      console.log("💳 Creating payment method...");
      // Create a payment method with the card details
      const stripe = getStripe();
      const paymentMethod = await stripe.paymentMethods.create({
        type: "card",
        card: {
          number: cardNumber.replace(/\s/g, ""),
          exp_month: parseInt(exp_month),
          exp_year: parseInt(fullYear),
          cvc: cvv,
        },
      });

      console.log("✅ Payment method created:", paymentMethod.id);

      console.log("💳 Creating payment intent...");
      // Create a payment intent
      const paymentIntent = await stripe.paymentIntents.create({
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
      payment.status = "paid";
      payment.transactionId = paymentIntent.id;
      payment.paymentMethod = "stripe";
      await payment.save();

      console.log("✅ Payment record updated successfully!");
      console.log("   - Status:", payment.status);
      console.log("   - Transaction ID:", payment.transactionId);
      console.log("   - Payment Method:", payment.paymentMethod);
      
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

