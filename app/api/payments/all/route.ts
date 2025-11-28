import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import { verifyAccessToken } from "@/lib/jwt";

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
 * Get all payments for logged-in user
 * GET /api/payments/all
 * Query params:
 *   - status: "paid" | "unpaid" | "all" (optional, defaults to "all")
 */
export async function GET(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUserToken(req);

    const { searchParams } = new URL(req.url);
    const statusFilter = searchParams.get("status") || "all";

    const userId = decoded.userId;

    // Build query
    const query: any = { userId };

    // Filter by status if specified
    if (statusFilter !== "all") {
      query.status = statusFilter;
    }

    // Find all payments for the user
    const payments = await Payment.find(query)
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
      .sort({ createdAt: -1 }); // Most recent first

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

