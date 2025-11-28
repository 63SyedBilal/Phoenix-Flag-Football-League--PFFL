import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";
import { generateAccessToken, verifyAccessToken } from "@/lib/jwt";

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
 * Create user
 * POST /api/user
 */
export async function createUser(req: NextRequest) {
  try {
    await connectDB();
    const { firstName, lastName, email, phone, password, role } = await req.json();

    if (!email) {
      return NextResponse.json({ error: "Email is required" }, { status: 400 });
    }

    const existing = await User.findOne({ email: email.toLowerCase() });
    
    if (existing) {
      return NextResponse.json({ error: "Email already exists" }, { status: 409 });
    }

    // Check phone uniqueness only if phone is provided and not empty
    if (phone && phone.trim() !== "") {
      const existingPhone = await User.findOne({ phone: phone.trim() });
      if (existingPhone) {
        return NextResponse.json({ error: "Phone already exists" }, { status: 409 });
      }
    }

    // Build user object with defaults
    const userData: {
      email: string;
      role: string;
      firstName: string;
      lastName: string;
      phone?: string;
      password?: string;
    } = {
      email: email.toLowerCase(),
      role: role || "free-agent",
      firstName: firstName || "",
      lastName: lastName || "",
    };

    // Only set phone if provided and not empty
    if (phone && phone.trim() !== "") {
      userData.phone = phone.trim();
    }
    // Otherwise phone will be undefined (not empty string)

    if (password) userData.password = password;

    const user = await User.create(userData);

    const token = generateAccessToken({
      userId: user._id.toString(),
      email: user.email,
      role: user.role,
    });

    return NextResponse.json(
      {
        message: "User created",
        data: { 
          id: user._id, 
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          role: user.role 
        },
        token,
      },
      { status: 201 }
    );
  } catch (error: any) {
    return NextResponse.json({ error: error.message || "Failed to create" }, { status: 500 });
  }
}

/**
 * Get all users (optionally filtered by role)
 * GET /api/user?role=player
 */
export async function getAllUsers(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { searchParams } = new URL(req.url);
    const role = searchParams.get("role");

    let query: any = {};
    if (role) {
      query.role = role;
    }

    const users = await User.find(query)
      .select("-password")
      .sort({ createdAt: -1 });

    return NextResponse.json(
      {
        message: "Users retrieved successfully",
        data: users.map((user) => ({
          _id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          role: user.role,
        })),
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Error in getAllUsers:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ 
      error: error.message || "Failed to get users",
      details: error.stack 
    }, { status: 500 });
  }
}

/**
 * Get user by ID
 * GET /api/user/:id
 */
export async function getUser(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;

    const user = await User.findById(id).select("-password");
    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    return NextResponse.json(
      {
        message: "User retrieved successfully",
        data: {
          _id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          role: user.role,
        },
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get user" }, { status: 500 });
  }
}

/**
 * Update user
 * PUT /api/user/:id
 */
export async function updateUser(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const { firstName, lastName, email, phone, password, role } = await req.json();

    const user = await User.findById(id);
    if (!user) {
      return NextResponse.json({ error: "Not found" }, { status: 404 });
    }

    if (firstName) user.firstName = firstName;
    if (lastName) user.lastName = lastName;
    
    if (email) {
      const existing = await User.findOne({ 
        email: email.toLowerCase(), 
        _id: { $ne: id } 
      });
      if (existing) {
        return NextResponse.json({ error: "Email already taken" }, { status: 409 });
      }
      user.email = email.toLowerCase();
    }

    if (phone !== undefined) {
      // If phone is empty string, set to undefined
      if (phone && phone.trim() !== "") {
        const existing = await User.findOne({ 
          phone: phone.trim(), 
          _id: { $ne: id } 
        });
        if (existing) {
          return NextResponse.json({ error: "Phone already taken" }, { status: 409 });
        }
        user.phone = phone.trim();
      } else {
        // Set to undefined if empty string or null
        user.phone = undefined;
      }
    }

    if (password) {
      user.password = password; // Will be hashed by pre-save hook
    }

    if (role) user.role = role;

    await user.save();

    return NextResponse.json(
      {
        message: "Updated",
        data: { 
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          role: user.role 
        },
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to update" }, { status: 500 });
  }
}

/**
 * Delete user
 * DELETE /api/user/:id
 */
export async function deleteUser(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const user = await User.findByIdAndDelete(id);

    if (!user) {
      return NextResponse.json({ error: "Not found" }, { status: 404 });
    }

    return NextResponse.json({ message: "Deleted" }, { status: 200 });
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to delete" }, { status: 500 });
  }
}

