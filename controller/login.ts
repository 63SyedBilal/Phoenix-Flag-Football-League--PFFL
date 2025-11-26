import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { SuperAdmin, User, Profile, Team } from "@/modules";
import { verifyPassword } from "@/lib/auth";
import { generateAccessToken } from "@/lib/jwt";

/**
 * Login - automatically determines role from database
 * POST /api/login
 */
export async function login(req: NextRequest) {
  try {
    await connectDB();
    const { email, password } = await req.json();

    console.log("🔐 Login attempt for email:", email);

    if (!email || !password) {
      return NextResponse.json({ error: "Email and password required" }, { status: 400 });
    }

    const emailLower = email.toLowerCase().trim();

    // First, try to find superadmin
    const superAdmin = await SuperAdmin.findOne({ 
      email: emailLower 
    }).select("+password");
    
    if (superAdmin) {
      console.log("✅ SuperAdmin found:", superAdmin.email);
      console.log("🔑 Password field exists:", !!superAdmin.password);
      
      if (!superAdmin.password) {
        console.log("❌ Password field is missing for superadmin:", superAdmin.email);
        return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
      }

      const isPasswordValid = await verifyPassword(password, superAdmin.password);
      console.log("🔐 Password verification result:", isPasswordValid);
      
      if (!isPasswordValid) {
        console.log("❌ Password verification failed for superadmin:", superAdmin.email);
        return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
      }

      const token = generateAccessToken({
        userId: superAdmin._id.toString(),
        email: superAdmin.email,
        role: superAdmin.role,
      });

      console.log("✅ SuperAdmin login successful");
      return NextResponse.json(
        {
          message: "Login successful",
          data: {
            id: superAdmin._id,
            email: superAdmin.email,
            role: superAdmin.role,
          },
          token,
        },
        { status: 200 }
      );
    }

    // If not superadmin, try to find regular user
    console.log("🔍 Searching for user with email:", emailLower);
    const user = await User.findOne({ 
      email: emailLower
    }).select("+password");
    
    if (!user) {
      console.log("❌ User not found for email:", emailLower);
      // Check if any users exist
      const userCount = await User.countDocuments({});
      console.log("📊 Total users in database:", userCount);
      return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
    }

    console.log("✅ User found:", user.email);
    console.log("👤 User role:", user.role);
    console.log("🔑 Password field exists:", !!user.password);
    console.log("🔑 Password hash preview:", user.password ? user.password.substring(0, 20) + "..." : "null");

    if (!user.password) {
      console.log("❌ Password field is missing for user:", user.email);
      return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
    }

    console.log("🔐 Verifying password...");
    console.log("🔑 Input password:", password);
    console.log("🔑 Input password length:", password.length);
    console.log("🔑 Stored hash starts with $2:", user.password.startsWith("$2"));
    console.log("🔑 Stored hash length:", user.password.length);
    console.log("🔑 Stored hash preview:", user.password.substring(0, 30) + "...");
    
    const isPasswordValid = await verifyPassword(password, user.password);
    console.log("🔐 Password verification result:", isPasswordValid);
    
    if (!isPasswordValid) {
      console.log("❌ Password verification failed for user:", user.email);
      console.log("🔍 Debugging info:");
      console.log("  - Input password:", password);
      console.log("  - Stored hash type:", user.password.startsWith("$2a$") ? "bcrypt" : "unknown");
      console.log("  - Hash length:", user.password.length);
      
      // Try to verify if password might be stored as plain text (shouldn't happen, but check)
      if (user.password === password) {
        console.log("⚠️ WARNING: Password appears to be stored as plain text!");
        console.log("⚠️ This is a security issue. Password should be hashed.");
      }
      
      return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
    }

    const token = generateAccessToken({
      userId: user._id.toString(),
      email: user.email,
      role: user.role,
    });

    // Check if profile needs completion (firstName or lastName is empty)
    const needsProfileCompletion = !user.firstName || !user.lastName || user.firstName === "" || user.lastName === "";

    // For captains, check if profile and team exist
    let needsProfileForm = false;
    let needsTeamForm = false;

    if (user.role === "captain") {
      // Check if profile exists
      const profile = await Profile.findOne({ userId: user._id });
      needsProfileForm = !profile;

      // Check if team exists
      const team = await Team.findOne({ captain: user._id });
      needsTeamForm = !team;
    }

    console.log("✅ User login successful:", user.email);
    console.log("👤 Profile completion needed:", needsProfileCompletion);
    console.log("👤 Profile form needed (captain):", needsProfileForm);
    console.log("👤 Team form needed (captain):", needsTeamForm);

    return NextResponse.json(
      {
        message: "Login successful",
        data: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          role: user.role,
          needsProfileCompletion,
          needsProfileForm,
          needsTeamForm,
        },
        token,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("❌ Login error:", error);
    console.error("❌ Error stack:", error.stack);
    return NextResponse.json({ error: error.message || "Login failed" }, { status: 500 });
  }
}

