import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";
import { verifyAccessToken } from "@/lib/jwt";

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
 * Check if jersey number is available
 * GET /api/user/check-jersey?number=10&excludeUserId=123
 */
export async function GET(req: NextRequest) {
  try {
    await connectDB();
    await verifyUser(req);

    const { searchParams } = new URL(req.url);
    const jerseyNumber = searchParams.get("number");
    const excludeUserId = searchParams.get("excludeUserId");

    if (!jerseyNumber) {
      return NextResponse.json(
        { error: "Jersey number is required" },
        { status: 400 }
      );
    }

    const jerseyNum = parseInt(jerseyNumber);
    if (isNaN(jerseyNum)) {
      return NextResponse.json(
        { error: "Jersey number must be a valid number" },
        { status: 400 }
      );
    }

    // Build query to find users with this jersey number
    const query: any = { jerseyNumber: jerseyNum };
    
    // Exclude current user if updating their own profile
    if (excludeUserId) {
      query._id = { $ne: excludeUserId };
    }

    const existingUser = await User.findOne(query).select("firstName lastName email jerseyNumber");

    if (existingUser) {
      const userName = existingUser.firstName && existingUser.lastName 
        ? `${existingUser.firstName} ${existingUser.lastName}`.trim()
        : existingUser.email;

      return NextResponse.json(
        {
          available: false,
          message: `Jersey number ${jerseyNumber} is already assigned to ${userName}`,
          assignedTo: {
            id: existingUser._id,
            name: userName,
            email: existingUser.email,
          },
        },
        { status: 200 }
      );
    }

    return NextResponse.json(
      {
        available: true,
        message: `Jersey number ${jerseyNumber} is available`,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error checking jersey number:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to check jersey number" },
      { status: 500 }
    );
  }
}