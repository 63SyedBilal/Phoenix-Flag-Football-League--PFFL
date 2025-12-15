import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";

// CORS headers helper
function getCorsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '86400',
  };
}

export async function OPTIONS() {
  return NextResponse.json({}, { headers: getCorsHeaders() });
}

/**
 * Admin endpoint to update user password
 * POST /api/admin/update-user-password
 * Body: { email: string, password: string }
 */
export async function POST(req: NextRequest) {
  try {
    await connectDB();
    
    const { email, password } = await req.json();
    
    if (!email || !password) {
      return NextResponse.json(
        { error: "Email and password are required" },
        { status: 400, headers: getCorsHeaders() }
      );
    }
    
    const user = await User.findOne({ email: email.toLowerCase() });
    
    if (!user) {
      return NextResponse.json(
        { error: "User not found" },
        { status: 404, headers: getCorsHeaders() }
      );
    }
    
    // Update password (will be hashed by pre-save hook)
    user.password = password;
    await user.save();
    
    return NextResponse.json(
      {
        message: "Password updated successfully",
        data: {
          email: user.email,
          role: user.role,
        },
      },
      { status: 200, headers: getCorsHeaders() }
    );
  } catch (error: any) {
    console.error("Error updating password:", error);
    return NextResponse.json(
      { error: error.message || "Failed to update password" },
      { status: 500, headers: getCorsHeaders() }
    );
  }
}

