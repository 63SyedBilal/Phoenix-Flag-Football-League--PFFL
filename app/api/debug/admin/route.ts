import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import User from "@/modules/user";
import SuperAdmin from "@/modules/superadmin";

export async function GET(req: NextRequest) {
    try {
        await connectDB();
        
        console.log("🔍 [DEBUG ADMIN] Searching for admin users...");
        
        // Check User collection for superadmin role
        const userAdmins = await User.find({ role: "superadmin" }).lean();
        console.log("🔍 [DEBUG ADMIN] Users with superadmin role:", userAdmins.length);
        
        if (userAdmins.length > 0) {
            userAdmins.forEach((admin, index) => {
                console.log(`🔍 [DEBUG ADMIN] User Admin ${index + 1}:`, {
                    id: admin._id.toString(),
                    email: admin.email,
                    firstName: admin.firstName,
                    lastName: admin.lastName,
                    role: admin.role
                });
            });
        }
        
        // Check SuperAdmin collection
        const superAdmins = await SuperAdmin.find({}).lean();
        console.log("🔍 [DEBUG ADMIN] SuperAdmin collection count:", superAdmins.length);
        
        if (superAdmins.length > 0) {
            superAdmins.forEach((admin, index) => {
                console.log(`🔍 [DEBUG ADMIN] SuperAdmin ${index + 1}:`, {
                    id: admin._id.toString(),
                    email: admin.email,
                    role: admin.role
                });
            });
        }
        
        // Check if the specific Super Admin ID exists
        const targetAdminId = "693c88f725239d27ad1f4505";
        const targetUser = await User.findById(targetAdminId).lean();
        const targetSuperAdmin = await SuperAdmin.findById(targetAdminId).lean();
        
        console.log(`🔍 [DEBUG ADMIN] Target ID ${targetAdminId}:`);
        console.log("   - Found in User collection:", !!targetUser);
        console.log("   - Found in SuperAdmin collection:", !!targetSuperAdmin);
        
        if (targetUser) {
            console.log("   - User details:", {
                id: targetUser._id.toString(),
                email: targetUser.email,
                role: targetUser.role,
                firstName: targetUser.firstName,
                lastName: targetUser.lastName
            });
        }
        
        if (targetSuperAdmin) {
            console.log("   - SuperAdmin details:", {
                id: targetSuperAdmin._id.toString(),
                email: targetSuperAdmin.email,
                role: targetSuperAdmin.role
            });
        }
        
        return NextResponse.json({
            success: true,
            userAdmins: userAdmins.map(u => ({
                id: u._id.toString(),
                email: u.email,
                role: u.role
            })),
            superAdmins: superAdmins.map(s => ({
                id: s._id.toString(),
                email: s.email,
                role: s.role
            })),
            targetUser: targetUser ? {
                id: targetUser._id.toString(),
                email: targetUser.email,
                role: targetUser.role
            } : null,
            targetSuperAdmin: targetSuperAdmin ? {
                id: targetSuperAdmin._id.toString(),
                email: targetSuperAdmin.email,
                role: targetSuperAdmin.role
            } : null
        });
        
    } catch (error: any) {
        console.error("❌ [DEBUG ADMIN] Error:", error);
        return NextResponse.json(
            { error: error.message || "Failed to debug admin" },
            { status: 500 }
        );
    }
}