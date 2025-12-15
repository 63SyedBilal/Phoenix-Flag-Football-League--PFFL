import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";

export async function POST(req: NextRequest) {
  try {
    await connectDB();
    
    const { email } = await req.json();
    
    // Search for user with exact email
    const user = await User.findOne({ 
      email: email.toLowerCase() 
    }).select("-password");
    
    if (!user) {
      return NextResponse.json(
        { 
          message: "User not found",
          searchedEmail: email,
          suggestion: "Check if the email is correct or create a new user with this email"
        },
        { status: 404 }
      );
    }
    
    return NextResponse.json(
      {
        message: "User found",
        user: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          role: user.role,
          createdAt: user.createdAt,
        }
      },
      { status: 200 }
    );
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}