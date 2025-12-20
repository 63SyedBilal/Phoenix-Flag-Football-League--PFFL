import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";

export async function POST(req: NextRequest) {
  try {
    await connectDB();
    
    // Common password for all users
    const password = "123123";
    
    // Define all users to create with their roles
    const usersToCreate = [
      {
        firstName: "Referee",
        lastName: "User",
        email: "referee@gmail.com",
        password: password,
        role: "referee",
      },
      {
        firstName: "Captain",
        lastName: "User",
        email: "captain@gmail.com",
        password: password,
        role: "captain",
      },
      {
        firstName: "Free",
        lastName: "Agent",
        email: "freeagent@gmail.com",
        password: password,
        role: "free-agent",
      },
      {
        firstName: "Stat",
        lastName: "Keeper",
        email: "statkeeper@gmail.com",
        password: password,
        role: "stat-keeper",
      },
      {
        firstName: "Player",
        lastName: "User",
        email: "player@gmail.com",
        password: password,
        role: "player",
      }
    ];
    
    const createdUsers = [];
    const skippedUsers = [];
    
    for (const userData of usersToCreate) {
      const emailLower = userData.email.toLowerCase();
      
      // Check if user already exists
      const existingUser = await User.findOne({ email: emailLower });
      
      if (existingUser) {
        skippedUsers.push({
          email: existingUser.email,
          role: existingUser.role,
          message: "User already exists"
        });
        continue;
      }
      
      // Create user (password will be hashed by pre-save hook in User model)
      try {
        const user = await User.create({
          firstName: userData.firstName,
          lastName: userData.lastName,
          email: emailLower,
          password: password, // Plain password - will be hashed by pre-save hook
          role: userData.role,
        });
        
        createdUsers.push({
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          role: user.role,
        });
      } catch (error: any) {
        console.error(`Error creating user ${emailLower}:`, error);
        skippedUsers.push({
          email: emailLower,
          role: userData.role,
          message: error.message || "Failed to create"
        });
      }
    }
    
    return NextResponse.json(
      {
        message: "Users processed successfully",
        created: createdUsers,
        skipped: skippedUsers.length > 0 ? skippedUsers : undefined,
        summary: {
          total: usersToCreate.length,
          created: createdUsers.length,
          skipped: skippedUsers.length
        }
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error processing users:", error);
    return NextResponse.json(
      { error: error.message || "Failed to create users" }, 
      { status: 500 }
    );
  }
}