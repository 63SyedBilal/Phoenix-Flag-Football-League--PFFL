import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { verifyAccessToken } from "@/lib/jwt";
import Payment from "@/modules/payment";
import User from "@/modules/user";

function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

async function verifyUser(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  const decoded = verifyAccessToken(token);
  
  // Verify user is superadmin - check token role first, then database
  if (decoded.role !== "superadmin") {
    // Also check database in case role is not in token
    const user = await User.findById(decoded.userId);
    if (!user || user.role !== "superadmin") {
      throw new Error("Unauthorized - Superadmin access required");
    }
  }
  
  return decoded;
}

export async function GET(req: NextRequest) {
  try {
    await connectDB();
    await verifyUser(req);

    // Find all unpaid payments
    const payments = await Payment.find({
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
        message: "All unpaid payments retrieved successfully",
        data: payments,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getAllUnpaidPayments (superadmin):", error);
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message.includes("Unauthorized")) {
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

