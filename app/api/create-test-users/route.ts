import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";
import { hashPassword } from "@/lib/auth";

export async function POST(req: NextRequest) {
  try {
    await connectDB();
    
    // Check if these specific test users already exist
    const testEmails = [
      "freeagent@gmail.com",
      "statkeeper@gmail.com", 
      "referee@gmail.com",
      "captain@gmail.com"
    ];
    
    const existingUsers = await User.find({
      email: { $in: testEmails.map(email => email.toLowerCase()) }
    });
    
    if (existingUsers.length > 0) {
      return NextResponse.json(
        { 
          message: "Some test users already exist",
          existingUsers: existingUsers.map(user => ({
            email: user.email,
            role: user.role
          }))
        },
        { status: 409 }
      );
    }
    
    // Hash the common password
    const password = "123456";
    const hashedPassword = await hashPassword(password);
    
    // Create users for all roles with the specified emails
    const usersToCreate = [
      {
        firstName: "Free",
        lastName: "Agent",
        email: "freeagent@gmail.com",
        password: hashedPassword,
        role: "free-agent",
      },
      {
        firstName: "Stat",
        lastName: "Keeper",
        email: "statkeeper@gmail.com",
        password: hashedPassword,
        role: "stat-keeper",
      },
      {
        firstName: "Referee",
        lastName: "User",
        email: "referee@gmail.com",
        password: hashedPassword,
        role: "referee",
      },
      {
        firstName: "Captain",
        lastName: "User",
        email: "captain@gmail.com",
        password: hashedPassword,
        role: "captain",
      }
    ];
    
    const createdUsers = [];
    
    for (const userData of usersToCreate) {
      const user = await User.create({
        ...userData,
        email: userData.email.toLowerCase()
      });
      
      createdUsers.push({
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        role: user.role,
      });
    }
    
    return NextResponse.json(
      {
        message: "Test users created successfully",
        users: createdUsers
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error creating test users:", error);
    return NextResponse.json(
      { error: error.message || "Failed to create test users" }, 
      { status: 500 }
    );
  }
}