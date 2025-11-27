import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { Payment, League, User } from "@/modules";
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
async function verifyUser(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  return decoded;
}

/**
 * Create payment records for a user for all active leagues
 * This is called automatically when a player or captain is created
 * @param userId - The user ID
 * @param userRole - The user's role (player or captain)
 * @param userName - The user's full name
 */
export async function createPaymentsForUser(
  userId: string,
  userRole: string,
  userName: string
) {
  try {
    await connectDB();

    // Only create payments for players and captains
    if (userRole !== "player" && userRole !== "captain") {
      return { success: true, message: "Payments only created for players and captains" };
    }

    const userObjectId = toObjectId(userId);

    // Get all leagues (both active and pending)
    // Users should be able to pay for leagues even if they haven't started yet
    const allLeagues = await League.find({});

    if (allLeagues.length === 0) {
      return { success: true, message: "No leagues found" };
    }

    // Create payment records for each league (active and pending)
    const paymentPromises = allLeagues.map(async (league: any) => {
      // Check if payment already exists
      const existingPayment = await Payment.findOne({
        userId: userObjectId,
        leagueId: league._id,
      });

      if (existingPayment) {
        return null; // Skip if payment already exists
      }

      // Create new payment record
      const paymentData: any = {
        userId: userObjectId,
        leagueId: league._id,
        amount: league.perPlayerLeagueFee || 0,
        status: "unpaid",
      };

      // Add role-specific name field
      if (userRole === "player") {
        paymentData.playerName = userName;
      } else if (userRole === "captain") {
        paymentData.captainName = userName;
      }

      return Payment.create(paymentData);
    });

    const payments = await Promise.all(paymentPromises);
    const createdPayments = payments.filter((p) => p !== null);

    return {
      success: true,
      message: `Created ${createdPayments.length} payment records`,
      count: createdPayments.length,
    };
  } catch (error: any) {
    console.error("Error creating payments for user:", error);
    return {
      success: false,
      error: error.message || "Failed to create payments",
    };
  }
}

/**
 * Get payment reminders (unpaid payments) for logged-in user
 * GET /api/payment/reminders
 */
export async function getPaymentReminders(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const userId = toObjectId(decoded.userId);

    // Get user to check role and name
    const user = await User.findById(userId);
    if (!user) {
      return NextResponse.json(
        { success: false, error: "User not found" },
        { status: 404 }
      );
    }

    // Only create/fetch payments for players and captains
    if (user.role !== "player" && user.role !== "captain") {
      return NextResponse.json(
        {
          success: true,
          message: "Payment reminders only available for players and captains",
          data: [],
        },
        { status: 200 }
      );
    }

    // Get all leagues (both active and pending)
    // Users should be able to pay for leagues even if they haven't started yet
    const allLeagues = await League.find({});

    // Get all existing payments for this user
    const existingPayments = await Payment.find({
      userId,
    });

    // Find leagues that don't have payment records (both active and pending)
    const leaguesWithoutPayments = allLeagues.filter((league: any) => {
      return !existingPayments.some((payment: any) => {
        return payment.leagueId.toString() === league._id.toString();
      });
    });

    // Create missing payment records
    if (leaguesWithoutPayments.length > 0) {
      const userName = `${user.firstName} ${user.lastName}`.trim() || user.email;
      
      const newPaymentPromises = leaguesWithoutPayments.map(async (league: any) => {
        const paymentData: any = {
          userId,
          leagueId: league._id,
          amount: league.perPlayerLeagueFee || 0,
          status: "unpaid",
        };

        // Add role-specific name field
        if (user.role === "player") {
          paymentData.playerName = userName;
        } else if (user.role === "captain") {
          paymentData.captainName = userName;
        }

        return Payment.create(paymentData);
      });

      await Promise.all(newPaymentPromises);
      console.log(`Created ${leaguesWithoutPayments.length} missing payment records for user ${userId.toString()}`);
    }

    // Now find all unpaid payments for the user (including newly created ones)
    const unpaidPayments = await Payment.find({
      userId,
      status: "unpaid",
    })
      .populate({
        path: "leagueId",
        select: "leagueName logo format startDate endDate perPlayerLeagueFee status",
        model: "League",
      })
      .populate({
        path: "userId",
        select: "firstName lastName email",
        model: "User",
      })
      .sort({ createdAt: -1 });

    // Format payments for frontend
    const formattedPayments = unpaidPayments.map((payment: any) => {
      const league = payment.leagueId;
      
      // Format dates
      const startDate = league?.startDate
        ? new Date(league.startDate).toLocaleDateString("en-US", {
            day: "numeric",
            month: "long",
            year: "numeric",
          })
        : "";
      const endDate = league?.endDate
        ? new Date(league.endDate).toLocaleDateString("en-US", {
            day: "numeric",
            month: "long",
            year: "numeric",
          })
        : "";

      // Determine league status based on start date
      const currentDate = new Date();
      const leagueStartDate = league?.startDate ? new Date(league.startDate) : null;
      const leagueStatus = leagueStartDate && leagueStartDate <= currentDate ? "active" : "pending";

      return {
        _id: payment._id.toString(),
        id: payment._id.toString(),
        amount: `$${payment.amount || 0}`,
        leagueDetails: {
          name: league?.leagueName || "Unknown League",
          logo: league?.logo || "/placeholder-logo.png",
          format: league?.format || "5v5",
          startDate,
          endDate,
          leagueFee: `$${league?.perPlayerLeagueFee || 0}`,
          status: leagueStatus,
        },
      };
    });

    return NextResponse.json(
      {
        success: true,
        message: "Payment reminders retrieved successfully",
        data: formattedPayments,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getPaymentReminders:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to get payment reminders" },
      { status: 500 }
    );
  }
}

/**
 * Update payment status (mark as paid)
 * PUT /api/payment/:id
 */
export async function updatePayment(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id } = params;
    const paymentId = toObjectId(id);
    const { transactionId, paymentMethod, amount, status } = await req.json();

    // Find the payment
    const payment = await Payment.findById(paymentId)
      .populate({
        path: "userId",
        select: "firstName lastName email",
        model: "User",
      });

    if (!payment) {
      return NextResponse.json(
        { success: false, error: "Payment not found" },
        { status: 404 }
      );
    }

    // Verify the payment belongs to the logged-in user
    const userId = toObjectId(decoded.userId);
    if (payment.userId.toString() !== userId.toString()) {
      return NextResponse.json(
        { success: false, error: "Unauthorized: This payment does not belong to you" },
        { status: 403 }
      );
    }

    // Update payment fields
    if (transactionId !== undefined) {
      (payment as any).transactionId = transactionId;
    }

    if (paymentMethod !== undefined) {
      if (!["stripe", "paypal"].includes(paymentMethod)) {
        return NextResponse.json(
          { success: false, error: "Payment method must be 'stripe' or 'paypal'" },
          { status: 400 }
        );
      }
      (payment as any).paymentMethod = paymentMethod;
    }

    if (amount !== undefined) {
      if (amount < 0) {
        return NextResponse.json(
          { success: false, error: "Amount must be positive" },
          { status: 400 }
        );
      }
      (payment as any).amount = amount;
    }

    if (status !== undefined) {
      if (!["paid", "unpaid"].includes(status)) {
        return NextResponse.json(
          { success: false, error: "Status must be 'paid' or 'unpaid'" },
          { status: 400 }
        );
      }
      (payment as any).status = status;

      // If marking as paid, paymentMethod is required
      if (status === "paid" && !paymentMethod && !(payment as any).paymentMethod) {
        return NextResponse.json(
          { success: false, error: "Payment method is required when status is 'paid'" },
          { status: 400 }
        );
      }
    }

    await payment.save();

    // Populate league for response
    await payment.populate({
      path: "leagueId",
      select: "leagueName logo format startDate endDate perPlayerLeagueFee",
      model: "League",
    });

    return NextResponse.json(
      {
        success: true,
        message: "Payment updated successfully",
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
 * Create payment records for all existing players and captains when a new league is created
 * @param leagueId - The new league ID
 * @param leagueFee - The league fee per player
 */
export async function createPaymentsForNewLeague(
  leagueId: string,
  leagueFee: number
) {
  try {
    await connectDB();

    const leagueObjectId = toObjectId(leagueId);

    // Get all players and captains
    const users = await User.find({
      role: { $in: ["player", "captain"] }
    });

    if (users.length === 0) {
      return { success: true, message: "No players or captains found" };
    }

    // Create payment records for each user
    const paymentPromises = users.map(async (user: any) => {
      // Check if payment already exists
      const existingPayment = await Payment.findOne({
        userId: user._id,
        leagueId: leagueObjectId,
      });

      if (existingPayment) {
        return null; // Skip if payment already exists
      }

      // Create new payment record
      const userName = `${user.firstName} ${user.lastName}`.trim() || user.email;
      const paymentData: any = {
        userId: user._id,
        leagueId: leagueObjectId,
        amount: leagueFee,
        status: "unpaid",
      };

      // Add role-specific name field
      if (user.role === "player") {
        paymentData.playerName = userName;
      } else if (user.role === "captain") {
        paymentData.captainName = userName;
      }

      return Payment.create(paymentData);
    });

    const payments = await Promise.all(paymentPromises);
    const createdPayments = payments.filter((p) => p !== null);

    return {
      success: true,
      message: `Created ${createdPayments.length} payment records for new league`,
      count: createdPayments.length,
    };
  } catch (error: any) {
    console.error("Error creating payments for new league:", error);
    return {
      success: false,
      error: error.message || "Failed to create payments",
    };
  }
}

/**
 * Get all payments for a user (paid and unpaid)
 * GET /api/payment/all
 */
export async function getAllPayments(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const userId = toObjectId(decoded.userId);

    // Find all payments for the user
    const payments = await Payment.find({ userId })
      .populate({
        path: "leagueId",
        select: "leagueName logo format startDate endDate perPlayerLeagueFee",
        model: "League",
      })
      .populate({
        path: "userId",
        select: "firstName lastName email",
        model: "User",
      })
      .sort({ createdAt: -1 });

    return NextResponse.json(
      {
        success: true,
        message: "Payments retrieved successfully",
        data: payments,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getAllPayments:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      );
    }
    return NextResponse.json(
      { success: false, error: error.message || "Failed to get payments" },
      { status: 500 }
    );
  }
}

