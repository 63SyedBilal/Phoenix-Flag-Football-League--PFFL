import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { SuperAdmin, User } from "@/modules";

export async function GET(req: NextRequest) {
  try {
    await connectDB();
    
    // Get all super admins
    const superAdmins = await SuperAdmin.find({}).select("-password");
    
    // Get all users
    const users = await User.find({}).select("-password");
    
    return NextResponse.json(
      {
        message: "Users retrieved successfully",
        data: {
          superAdmins: superAdmins.map(admin => ({
            id: admin._id,
            email: admin.email,
            role: admin.role,
            createdAt: admin.createdAt,
          })),
          users: users.map(user => ({
            id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            createdAt: user.createdAt,
          })),
          counts: {
            superAdmins: superAdmins.length,
            users: users.length,
          }
        },
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error fetching users:", error);
    // Return a more user-friendly error message
    if (error.code === "ENOTFOUND" || error.code === "ECONNREFUSED") {
      return NextResponse.json(
        { 
          error: "Database connection failed. Please ensure MongoDB is running.", 
          details: "You need to install and start MongoDB server for this application to work."
        }, 
        { status: 500 }
      );
    }
    return NextResponse.json(
      { error: error.message || "Failed to fetch users" }, 
      { status: 500 }
    );
  }
}