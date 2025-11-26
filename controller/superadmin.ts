import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { SuperAdmin } from "@/modules";
import { hashPassword } from "@/lib/auth";
import { generateAccessToken, verifyAccessToken } from "@/lib/jwt";

// Helper to get token from request
function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

// Helper to verify admin from token
async function verifyAdmin(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  
  const decoded = verifyAccessToken(token);
  if (decoded.role !== "superadmin") throw new Error("Unauthorized");
  
  return decoded;
}

/**
 * Create superadmin
 * POST /api/superadmin
 */
export async function createSuperAdmin(req: NextRequest) {
  try {
    await connectDB();
    const { email, password } = await req.json();

    if (!email || !password) {
      return NextResponse.json({ error: "Email and password required" }, { status: 400 });
    }

    const existing = await SuperAdmin.findOne({ email: email.toLowerCase() });
    if (existing) {
      return NextResponse.json({ error: "Email already exists" }, { status: 409 });
    }

    const hashedPassword = await hashPassword(password);
    const superAdmin = await SuperAdmin.create({
      email: email.toLowerCase(),
      password: hashedPassword,
    });

    const token = generateAccessToken({
      userId: superAdmin._id.toString(),
      email: superAdmin.email,
      role: superAdmin.role,
    });

    return NextResponse.json(
      {
        message: "SuperAdmin created",
        data: { id: superAdmin._id, email: superAdmin.email, role: superAdmin.role },
        token,
      },
      { status: 201 }
    );
  } catch (error: any) {
    return NextResponse.json({ error: error.message || "Failed to create" }, { status: 500 });
  }
}

/**
 * Update superadmin
 * PUT /api/superadmin/:id
 */
export async function updateSuperAdmin(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id } = params;
    
    if (!id) {
      return NextResponse.json({ error: "ID is required" }, { status: 400 });
    }

    const { email, password } = await req.json();

    const superAdmin = await SuperAdmin.findById(id);
    if (!superAdmin) {
      return NextResponse.json({ error: `SuperAdmin with ID ${id} not found` }, { status: 404 });
    }

    if (email) {
      const existing = await SuperAdmin.findOne({ email: email.toLowerCase(), _id: { $ne: id } });
      if (existing) {
        return NextResponse.json({ error: "Email already taken" }, { status: 409 });
      }
      superAdmin.email = email.toLowerCase();
    }

    if (password) {
      superAdmin.password = await hashPassword(password);
    }

    await superAdmin.save();

    return NextResponse.json(
      {
        message: "Updated",
        data: { id: superAdmin._id, email: superAdmin.email, role: superAdmin.role },
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to update" }, { status: 500 });
  }
}

/**
 * Delete superadmin
 * DELETE /api/superadmin/:id
 */
export async function deleteSuperAdmin(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id } = params;
    const superAdmin = await SuperAdmin.findByIdAndDelete(id);

    if (!superAdmin) {
      return NextResponse.json({ error: "Not found" }, { status: 404 });
    }

    return NextResponse.json({ message: "Deleted" }, { status: 200 });
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Unauthorized") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to delete" }, { status: 500 });
  }
}
