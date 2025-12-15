import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";

export async function POST(req: NextRequest) {
  try {
    await connectDB();
    
    const { userId, newRole } = await req.json();
    
    // Find and update the user
    const user = await User.findByIdAndUpdate(
      userId,
      { role: newRole },
      { new: true }
    ).select("-password");
    
    if (!user) {
      return NextResponse.json(
        { error: "User not found" },
        { status: 404 }
      );
    }
    
    return NextResponse.json(
      {
        message: "User role updated successfully",
        user: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          role: user.role,
        }
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Update role error:", error);
    return NextResponse.json(
      { error: error.message || "Failed to update user role" },
      { status: 500 }
    );
  }
}