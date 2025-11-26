import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { Profile } from "@/modules";
import { verifyAccessToken } from "@/lib/jwt";

// Helper to get token from request
function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

// Helper to verify user from token
async function verifyUser(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  return decoded;
}

/**
 * Create profile
 * POST /api/profile
 */
export async function createProfile(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);
    
    const { yearOfExperience, position, jerseyNumber, emergencyNumber, emergencyPhoneNumber, image, paymentStatus } = await req.json();

    if (!emergencyNumber || !emergencyPhoneNumber) {
      return NextResponse.json({ error: "Emergency number and phone number are required" }, { status: 400 });
    }

    // Check if profile already exists
    const existingProfile = await Profile.findOne({ userId: decoded.userId });
    if (existingProfile) {
      return NextResponse.json({ error: "Profile already exists" }, { status: 409 });
    }

    const profileData: any = {
      userId: decoded.userId,
      yearOfExperience: yearOfExperience || 0,
      position: position || "",
      jerseyNumber: jerseyNumber || null,
      emergencyNumber: emergencyNumber,
      emergencyPhoneNumber: emergencyPhoneNumber,
      image: image || "",
      paymentStatus: paymentStatus || "unpaid",
    };

    const profile = await Profile.create(profileData);

    return NextResponse.json(
      {
        message: "Profile created successfully",
        data: profile,
      },
      { status: 201 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to create profile" }, { status: 500 });
  }
}

/**
 * Get profile by ID or userId
 * GET /api/profile/:id
 */
export async function getProfile(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id } = params;

    // Try to find by profile ID first
    let profile = await Profile.findById(id);

    // If not found, try to find by userId
    if (!profile) {
      profile = await Profile.findOne({ userId: id });
    }

    // If still not found and id matches current user, try with current user's ID
    if (!profile && id === decoded.userId) {
      profile = await Profile.findOne({ userId: decoded.userId });
    }

    if (!profile) {
      return NextResponse.json({ error: "Profile not found" }, { status: 404 });
    }

    return NextResponse.json(
      {
        message: "Profile retrieved successfully",
        data: profile,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get profile" }, { status: 500 });
  }
}

/**
 * Get all profiles
 * GET /api/profile
 */
export async function getAllProfiles(req: NextRequest) {
  try {
    await connectDB();
    await verifyUser(req);

    const profiles = await Profile.find()
      .sort({ createdAt: -1 });

    return NextResponse.json(
      {
        message: "Profiles retrieved successfully",
        data: profiles,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get profiles" }, { status: 500 });
  }
}

/**
 * Update profile
 * PUT /api/profile/:id
 */
export async function updateProfile(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const { yearOfExperience, position, jerseyNumber, emergencyNumber, emergencyPhoneNumber, image, paymentStatus } = await req.json();

    const profile = await Profile.findById(id);
    if (!profile) {
      return NextResponse.json({ error: "Profile not found" }, { status: 404 });
    }

    if (yearOfExperience !== undefined) {
      profile.yearOfExperience = yearOfExperience;
    }

    if (position !== undefined) {
      profile.position = position;
    }

    if (jerseyNumber !== undefined) {
      profile.jerseyNumber = jerseyNumber;
    }

    if (emergencyNumber !== undefined) {
      profile.emergencyNumber = emergencyNumber;
    }

    if (emergencyPhoneNumber !== undefined) {
      profile.emergencyPhoneNumber = emergencyPhoneNumber;
    }

    if (image !== undefined) {
      profile.image = image;
    }

    if (paymentStatus !== undefined) {
      if (!["paid", "unpaid", "pending"].includes(paymentStatus)) {
        return NextResponse.json({ error: "Invalid payment status" }, { status: 400 });
      }
      profile.paymentStatus = paymentStatus;
    }

    await profile.save();

    return NextResponse.json(
      {
        message: "Profile updated successfully",
        data: profile,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to update profile" }, { status: 500 });
  }
}

/**
 * Delete profile
 * DELETE /api/profile/:id
 */
export async function deleteProfile(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;

    const profile = await Profile.findById(id);
    if (!profile) {
      return NextResponse.json({ error: "Profile not found" }, { status: 404 });
    }

    await Profile.findByIdAndDelete(id);

    return NextResponse.json({ message: "Profile deleted successfully" }, { status: 200 });
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to delete profile" }, { status: 500 });
  }
}

