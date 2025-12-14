import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { SuperAdmin, User } from "@/modules";
import { hashPassword } from "@/lib/auth";

export async function POST(req: NextRequest) {
  try {
    await connectDB();
    
    // Check if users already exist
    const superAdminCount = await SuperAdmin.countDocuments();
    const userCount = await User.countDocuments();
    
    if (superAdminCount > 0 || userCount > 0) {
      return NextResponse.json(
        { error: "Users already exist in the database. Seeding skipped." }, 
        { status: 409 }
      );
    }
    
    // Hash the common password
    const password = "123456";
    const hashedPassword = await hashPassword(password);
    
    // Create Super Admin
    const superAdmin = await SuperAdmin.create({
      email: "superadmin@gmail.com",
      password: hashedPassword,
    });
    
    // Create users for all roles
    const roles = ["player", "free-agent", "captain", "referee", "stat-keeper"];
    const users = [];
    
    for (let i = 0; i < roles.length; i++) {
      const role = roles[i];
      const user = await User.create({
        firstName: role.charAt(0).toUpperCase() + role.slice(1),
        lastName: "User",
        email: `${role}@gmail.com`,
        password: hashedPassword,
        role: role,
      });
      users.push(user);
    }
    
    return NextResponse.json(
      {
        message: "All users created successfully",
        data: {
          superAdmin: {
            id: superAdmin._id,
            email: superAdmin.email,
            role: superAdmin.role,
          },
          users: users.map(user => ({
            id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
          })),
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Seeding error:", error);
    // Return a more user-friendly error message
    if (error.code === "ENOTFOUND" || error.code === "ECONNREFUSED") {
      return NextResponse.json(
        { 
          error: "Database connection failed. Please ensure MongoDB is running on localhost:27017", 
          details: "You need to install and start MongoDB server for this application to work."
        }, 
        { status: 500 }
      );
    }
    return NextResponse.json(
      { error: error.message || "Failed to seed users" }, 
      { status: 500 }
    );
  }
}