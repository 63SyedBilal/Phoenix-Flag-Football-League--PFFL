import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";

export async function POST(req: NextRequest) {
  try {
    await connectDB();

    // Define roles and their email patterns
    const roleConfigs = [
      {
        role: "captain",
        emailPrefix: "captain",
        count: 10,
        firstName: "Captain",
        lastName: "User",
      },
      {
        role: "referee",
        emailPrefix: "referee",
        count: 10,
        firstName: "Referee",
        lastName: "User",
      },
      {
        role: "player",
        emailPrefix: "player",
        count: 10,
        firstName: "Player",
        lastName: "User",
      },
      {
        role: "stat-keeper", // Note: role is "stat-keeper" not "statkeeper"
        emailPrefix: "statkeeper",
        count: 10,
        firstName: "Stat",
        lastName: "Keeper",
      },
    ];

    // Generate all email addresses
    const allEmails: string[] = [];
    roleConfigs.forEach((config) => {
      for (let i = 1; i <= config.count; i++) {
        allEmails.push(`${config.emailPrefix}${i}@gmail.com`);
      }
    });

    // Check if any users already exist
    const existingUsers = await User.find({
      email: { $in: allEmails.map((email) => email.toLowerCase()) },
    });

    if (existingUsers.length > 0) {
      return NextResponse.json(
        {
          message: "Some users already exist",
          existingUsers: existingUsers.map((user) => ({
            email: user.email,
            role: user.role,
          })),
          totalExisting: existingUsers.length,
        },
        { status: 409 }
      );
    }

    // Common password for all users (will be hashed by pre-save hook)
    const password = "123456";

    // Create users for each role
    const createdUsers = [];
    const errors = [];

    for (const config of roleConfigs) {
      for (let i = 1; i <= config.count; i++) {
        try {
          const email = `${config.emailPrefix}${i}@gmail.com`;
          const userData = {
            firstName: `${config.firstName} ${i}`,
            lastName: config.lastName,
            email: email.toLowerCase(),
            password: password, // Will be hashed by pre-save hook
            role: config.role,
          };

          const user = await User.create(userData);

          createdUsers.push({
            id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
          });

          console.log(`✅ Created: ${email} (${config.role})`);
        } catch (error: any) {
          const email = `${config.emailPrefix}${i}@gmail.com`;
          errors.push({
            email,
            role: config.role,
            error: error.message,
          });
          console.error(`❌ Error creating ${email}:`, error.message);
        }
      }
    }

    return NextResponse.json(
      {
        message: "Bulk users creation completed",
        summary: {
          totalCreated: createdUsers.length,
          totalErrors: errors.length,
          byRole: roleConfigs.map((config) => ({
            role: config.role,
            count: createdUsers.filter((u) => u.role === config.role).length,
          })),
        },
        createdUsers: createdUsers,
        errors: errors.length > 0 ? errors : undefined,
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error creating bulk users:", error);
    return NextResponse.json(
      { error: error.message || "Failed to create bulk users" },
      { status: 500 }
    );
  }
}
