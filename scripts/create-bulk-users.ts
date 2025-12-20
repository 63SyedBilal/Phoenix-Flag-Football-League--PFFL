/**
 * Script to create bulk users in the database
 * 
 * Usage:
 *   npx tsx scripts/create-bulk-users.ts
 * 
 * Or with ts-node:
 *   npx ts-node scripts/create-bulk-users.ts
 */

import mongoose from "mongoose";
import User from "../modules/user";
import { connectDB } from "../lib/db";

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

async function createBulkUsers() {
  try {
    console.log("🔌 Connecting to database...");
    await connectDB();
    console.log("✅ Connected to database");

    // Generate all email addresses
    const allEmails: string[] = [];
    roleConfigs.forEach((config) => {
      for (let i = 1; i <= config.count; i++) {
        allEmails.push(`${config.emailPrefix}${i}@gmail.com`);
      }
    });

    console.log(`\n📧 Checking for existing users (${allEmails.length} total)...`);

    // Check if any users already exist
    const existingUsers = await User.find({
      email: { $in: allEmails.map((email) => email.toLowerCase()) },
    });

    if (existingUsers.length > 0) {
      console.log(`\n⚠️  Found ${existingUsers.length} existing users:`);
      existingUsers.forEach((user) => {
        console.log(`   - ${user.email} (${user.role})`);
      });
      console.log("\n❌ Please delete existing users first or use the API endpoint.");
      process.exit(1);
    }

    // Common password for all users (will be hashed by pre-save hook)
    const password = "123456";

    console.log("\n🚀 Starting bulk user creation...\n");

    // Create users for each role
    const createdUsers = [];
    const errors = [];

    for (const config of roleConfigs) {
      console.log(`📝 Creating ${config.count} ${config.role} users...`);
      
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

          console.log(`   ✅ Created: ${email} (${config.role})`);
        } catch (error: any) {
          const email = `${config.emailPrefix}${i}@gmail.com`;
          errors.push({
            email,
            role: config.role,
            error: error.message,
          });
          console.error(`   ❌ Error creating ${email}:`, error.message);
        }
      }
      console.log("");
    }

    // Summary
    console.log("=".repeat(60));
    console.log("📊 SUMMARY");
    console.log("=".repeat(60));
    console.log(`✅ Total Created: ${createdUsers.length}`);
    console.log(`❌ Total Errors: ${errors.length}`);

    console.log("\n📋 Created by Role:");
    roleConfigs.forEach((config) => {
      const count = createdUsers.filter((u) => u.role === config.role).length;
      console.log(`   - ${config.role}: ${count}/${config.count}`);
    });

    if (errors.length > 0) {
      console.log("\n❌ Errors:");
      errors.forEach((err) => {
        console.log(`   - ${err.email} (${err.role}): ${err.error}`);
      });
    }

    console.log("\n🔑 Default Password for all users: 123456");
    console.log("\n✅ Bulk user creation completed!");

    // Close database connection
    await mongoose.connection.close();
    console.log("🔌 Database connection closed");
  } catch (error: any) {
    console.error("❌ Fatal error:", error);
    process.exit(1);
  }
}

// Run the script
createBulkUsers();
