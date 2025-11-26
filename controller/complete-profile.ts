import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";
import { verifyAccessToken } from "@/lib/jwt";
import { hashPassword } from "@/lib/auth";

/**
 * Complete user profile - update existing user with profile details
 * PUT /api/complete-profile
 */
export async function completeProfile(req: NextRequest) {
  try {
    await connectDB();

    // Get token from Authorization header
    const authHeader = req.headers.get("authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return NextResponse.json(
        { error: "Authorization token required" },
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const decoded = verifyAccessToken(token);

    const { firstName, lastName, phone, password } = await req.json();

    if (!firstName || !lastName) {
      return NextResponse.json(
        { error: "First name and last name are required" },
        { status: 400 }
      );
    }

    // Find user
    const user = await User.findById(decoded.userId);
    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Check phone uniqueness if phone is provided
    if (phone && phone.trim() !== "") {
      const existingPhone = await User.findOne({
        phone: phone.trim(),
        _id: { $ne: decoded.userId },
      });
      if (existingPhone) {
        return NextResponse.json(
          { error: "Phone number already exists" },
          { status: 409 }
        );
      }
      user.phone = phone.trim();
    }

    // Update password if provided
    if (password && password.trim() !== "") {
      user.password = await hashPassword(password);
    }

    // Update user profile
    user.firstName = firstName.trim();
    user.lastName = lastName.trim();

    await user.save();

    return NextResponse.json(
      {
        message: "Profile completed successfully",
        data: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          role: user.role,
        },
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Complete profile error:", error);
    if (error.message === "Token has expired" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to complete profile" },
      { status: 500 }
    );
  }
}

