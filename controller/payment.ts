import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import League from "@/modules/league";
import User from "@/modules/user";
import Team from "@/modules/team";
import { verifyAccessToken } from "@/lib/jwt";
import mongoose from "mongoose";

// Helper to convert string ID to ObjectId
function toObjectId(id: string | mongoose.Types.ObjectId): mongoose.Types.ObjectId {
  if (id instanceof mongoose.Types.ObjectId) {
    return id;
  }
  return new mongoose.Types.ObjectId(id);
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
 * Create payment record for a user and league
 * This is called automatically when a user accepts a league invitation
 * @param userId - User ID
 * @param leagueId - League ID
 * @param teamId - Optional team ID (for team-based payments)
 * @returns Created payment document
 */
export async function createPayment(
  userId: string | mongoose.Types.ObjectId,
  leagueId: string | mongoose.Types.ObjectId,
  teamId?: string | mongoose.Types.ObjectId
): Promise<any> {
  console.log("\n💳 ========== createPayment FUNCTION CALLED ==========");
  console.log("💳 Input parameters:");
  console.log("   - userId:", userId, `(type: ${typeof userId})`);
  console.log("   - leagueId:", leagueId, `(type: ${typeof leagueId})`);
  console.log("   - teamId:", teamId || "N/A", `(type: ${typeof teamId})`);
  
  try {
    console.log("💳 Connecting to database...");
    await connectDB();
    console.log("✅ Database connected");

    const userObjectId = toObjectId(userId);
    const leagueObjectId = toObjectId(leagueId);
    
    console.log("💳 Converted IDs:");
    console.log("   - userObjectId:", userObjectId.toString());
    console.log("   - leagueObjectId:", leagueObjectId.toString());

    // Check if payment already exists
    console.log("💳 Checking for existing payment...");
    const existingPayment = await Payment.findOne({
      userId: userObjectId,
      leagueId: leagueObjectId,
    });

    if (existingPayment) {
      console.log(`⚠️ Payment already exists for user ${userObjectId.toString()} and league ${leagueObjectId.toString()}`);
      console.log(`   - Existing Payment ID: ${existingPayment._id}`);
      console.log(`   - Amount: $${existingPayment.amount}`);
      console.log(`   - Status: ${existingPayment.status}`);
      return existingPayment;
    }
    console.log("✅ No existing payment found - proceeding to create new payment");

    // Get league to fetch entry fee
    console.log("💳 Fetching league from database...");
    const league = await League.findById(leagueObjectId);
    if (!league) {
      console.error("❌ League not found with ID:", leagueObjectId.toString());
      throw new Error("League not found");
    }
    console.log("✅ League found:");
    console.log("   - League Name:", (league as any).leagueName);
    console.log("   - League ID:", league._id.toString());
    console.log("   - Per Player Fee:", (league as any).perPlayerLeagueFee);

    // Get user to fetch name and role
    console.log("💳 Fetching user from database...");
    const user = await User.findById(userObjectId);
    if (!user) {
      console.error("❌ User not found with ID:", userObjectId.toString());
      throw new Error("User not found");
    }
    console.log("✅ User found:");
    console.log("   - User Email:", user.email);
    console.log("   - User Name:", `${user.firstName} ${user.lastName}`);
    console.log("   - User Role:", user.role);
    console.log("   - User ID:", user._id.toString());

    // Get team info if teamId is provided
    let teamName = "";
    if (teamId) {
      console.log("💳 Fetching team from database...");
      const teamObjectId = toObjectId(teamId);
      console.log("   - Team ID:", teamObjectId.toString());
      const team = await Team.findById(teamObjectId);
      if (team) {
        teamName = team.teamName;
        console.log("✅ Team found:");
        console.log("   - Team Name:", teamName);
        console.log("   - Team ID:", team._id.toString());
      } else {
        console.warn("⚠️ Team not found with ID:", teamObjectId.toString());
      }
    } else {
      console.log("💳 No teamId provided");
    }

    // Determine payment amount (per player fee)
    const amount = (league as any).perPlayerLeagueFee || 0;
    
    console.log("💳 Payment calculation:");
    console.log("   - League perPlayerLeagueFee:", (league as any).perPlayerLeagueFee);
    console.log("   - Calculated amount:", amount);

    // Build user name
    const userName = `${user.firstName || ""} ${user.lastName || ""}`.trim() || user.email;
    console.log("💳 User name built:", userName);

    // Create payment document based on user role
    console.log("💳 Building payment data object...");
    const paymentData: any = {
      userId: userObjectId,
      leagueId: leagueObjectId,
      amount,
      status: "unpaid",
    };

    // Add role-specific fields
    if (user.role === "captain") {
      paymentData.captainName = userName;
      console.log("💳 Added captainName:", userName);
    } else if (user.role === "player") {
      paymentData.playerName = userName;
      console.log("💳 Added playerName:", userName);
    } else if (user.role === "free-agent") {
      paymentData.freeAgentName = userName;
      console.log("💳 Added freeAgentName:", userName);
    }

    // Add team name if available
    if (teamName) {
      paymentData.teamName = teamName;
      console.log("💳 Added teamName:", teamName);
    }

    console.log("💳 Final payment data object:");
    console.log("   - userId:", paymentData.userId.toString());
    console.log("   - leagueId:", paymentData.leagueId.toString());
    console.log("   - amount:", paymentData.amount);
    console.log("   - status:", paymentData.status);
    console.log("   - captainName:", paymentData.captainName || "N/A");
    console.log("   - playerName:", paymentData.playerName || "N/A");
    console.log("   - freeAgentName:", paymentData.freeAgentName || "N/A");
    console.log("   - teamName:", paymentData.teamName || "N/A");

    console.log("💳 Creating Payment document...");
    const payment = new Payment(paymentData);
    console.log("💳 Payment document created (not saved yet)");
    console.log("   - Payment _id:", payment._id);

    console.log("💳 Saving payment to database...");
    await payment.save();
    console.log("✅ Payment saved successfully!");

    console.log("💳 Final payment details:");
    console.log("   - Payment ID:", payment._id.toString());
    console.log("   - User ID:", payment.userId.toString());
    console.log("   - League ID:", payment.leagueId.toString());
    console.log("   - Amount: $", payment.amount);
    console.log("   - Status:", payment.status);
    console.log("   - Created At:", payment.createdAt);
    console.log("💳 ========== createPayment FUNCTION COMPLETE ==========\n");

    return payment;
  } catch (error: any) {
    console.error("Error creating payment:", error);
    throw error;
  }
}

/**
 * Get payment for logged-in user and specific league
 * GET /api/payments/my?leagueId=xxx
 */
export async function getMyPayment(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const { searchParams } = new URL(req.url);
    const leagueId = searchParams.get("leagueId");

    if (!leagueId) {
      return NextResponse.json(
        { success: false, error: "leagueId query parameter is required" },
        { status: 400 }
      );
    }

    const userId = toObjectId(decoded.userId);
    const leagueObjectId = toObjectId(leagueId);

    // Find payment
    const payment = await Payment.findOne({
      userId,
      leagueId: leagueObjectId,
    })
      .populate({
        path: "userId",
        select: "firstName lastName email role",
        model: "User",
      })
      .populate({
        path: "leagueId",
        select: "leagueName logo format startDate endDate",
        model: "League",
      });

    // If no payment exists, create one automatically
    if (!payment) {
      console.log(`No payment found for user ${userId.toString()} and league ${leagueObjectId.toString()}. Creating one...`);
      
      try {
        const newPayment = await createPayment(userId, leagueObjectId);
        
        // Populate the new payment
        await newPayment.populate({
          path: "userId",
          select: "firstName lastName email role",
          model: "User",
        });
        await newPayment.populate({
          path: "leagueId",
          select: "leagueName logo format startDate endDate",
          model: "League",
        });

        return NextResponse.json(
          {
            success: true,
            message: "Payment record created",
            data: newPayment,
          },
          { status: 200 }
        );
      } catch (createError: any) {
        console.error("Error creating payment:", createError);
        return NextResponse.json(
          {
            success: false,
            error: createError.message || "Failed to create payment record",
          },
          { status: 500 }
        );
      }
    }

    return NextResponse.json(
      {
        success: true,
        message: "Payment retrieved successfully",
        data: payment,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getMyPayment:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to get payment" },
      { status: 500 }
    );
  }
}

/**
 * Update payment to paid status
 * PATCH /api/payments/pay
 * Body: { leagueId: string, transactionId: string, paymentMethod: "stripe" | "paypal" }
 */
export async function updatePayment(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const body = await req.json();
    const { leagueId, transactionId, paymentMethod } = body;

    if (!leagueId) {
      return NextResponse.json(
        { success: false, error: "leagueId is required" },
        { status: 400 }
      );
    }

    if (!transactionId) {
      return NextResponse.json(
        { success: false, error: "transactionId is required" },
        { status: 400 }
      );
    }

    if (!paymentMethod) {
      return NextResponse.json(
        { success: false, error: "paymentMethod is required" },
        { status: 400 }
      );
    }

    if (!["stripe", "paypal"].includes(paymentMethod)) {
      return NextResponse.json(
        { success: false, error: "paymentMethod must be 'stripe' or 'paypal'" },
        { status: 400 }
      );
    }

    const userId = toObjectId(decoded.userId);
    const leagueObjectId = toObjectId(leagueId);

    // Find existing payment
    let payment = await Payment.findOne({
      userId,
      leagueId: leagueObjectId,
    });

    // If no payment exists, create one first
    if (!payment) {
      console.log(`No payment found. Creating unpaid payment for user ${userId.toString()} and league ${leagueObjectId.toString()}`);
      try {
        payment = await createPayment(userId, leagueObjectId);
      } catch (createError: any) {
        console.error("Error creating payment:", createError);
        return NextResponse.json(
          {
            success: false,
            error: createError.message || "Failed to create payment record",
          },
          { status: 500 }
        );
      }
    }

    // Check if already paid
    if (payment.status === "paid") {
      return NextResponse.json(
        {
          success: false,
          error: "Payment has already been processed",
        },
        { status: 400 }
      );
    }

    // Update payment
    payment.status = "paid";
    payment.transactionId = transactionId;
    payment.paymentMethod = paymentMethod;
    await payment.save();

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

    console.log(`✅ Payment updated to paid for user ${userId.toString()} in league ${leagueObjectId.toString()}`);

    return NextResponse.json(
      {
        success: true,
        message: "Payment processed successfully",
        data: payment,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in updatePayment:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to update payment" },
      { status: 500 }
    );
  }
}

/**
 * Get all unpaid payments for logged-in user
 * GET /api/payments/unpaid
 */
export async function getAllUnpaidPayments(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const userId = toObjectId(decoded.userId);

    // Find all unpaid payments for the user
    const payments = await Payment.find({
      userId,
      status: "unpaid",
    })
      .populate({
        path: "userId",
        select: "firstName lastName email role",
        model: "User",
      })
      .populate({
        path: "leagueId",
        select: "leagueName logo format startDate endDate status",
        model: "League",
      })
      .sort({ createdAt: -1 });

    return NextResponse.json(
      {
        success: true,
        message: "Unpaid payments retrieved successfully",
        data: payments,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getAllUnpaidPayments:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to get unpaid payments" },
      { status: 500 }
    );
  }
}

