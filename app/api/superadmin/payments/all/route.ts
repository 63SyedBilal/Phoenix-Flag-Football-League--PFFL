import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Payment from "@/modules/payment";
import User from "@/modules/user";
import { verifyAccessToken } from "@/lib/jwt";

// Helper to get token from request
function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

// Helper to verify user is superadmin
async function verifyUser(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  
  if (decoded.role !== "superadmin") {
    const user = await User.findById(decoded.userId);
    if (!user || user.role !== "superadmin") {
      throw new Error("Unauthorized - Superadmin access required");
    }
  }
  
  return decoded;
}

/**
 * Get all payments (for superadmin)
 * GET /api/superadmin/payments/all
 * Query params:
 *   - status: "paid" | "unpaid" | "all" (optional, defaults to "all")
 */
export async function GET(req: NextRequest) {
  try {
    await connectDB();
    await verifyUser(req);

    const { searchParams } = new URL(req.url);
    const statusFilter = searchParams.get("status") || "all";

    // Build query
    const query: any = {};

    // Filter by status if specified
    if (statusFilter !== "all") {
      query.status = statusFilter;
    }

    // Find all payments
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
        message: "All payments retrieved successfully for superadmin",
        data: payments,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in superadmin getAllPayments:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    if (error.message === "Unauthorized - Superadmin access required") {
      return NextResponse.json({ error: error.message }, { status: 403 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to get payments" },
      { status: 500 }
    );
  }
}

