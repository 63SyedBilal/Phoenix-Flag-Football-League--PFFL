import { NextRequest, NextResponse } from "next/server";
import { verifyAccessToken } from "@/lib/jwt";

export async function GET(req: NextRequest) {
    try {
        const authHeader = req.headers.get("authorization");
        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return NextResponse.json(
                { error: "No token provided" },
                { status: 401 }
            );
        }
        
        const token = authHeader.substring(7);
        console.log("🔍 [TOKEN DEBUG] Token received:", token.substring(0, 20) + "...");
        
        const decoded = verifyAccessToken(token);
        console.log("🔍 [TOKEN DEBUG] Decoded token:", decoded);
        
        // Extract user ID using the same logic as notification handlers
        const userId = (decoded as any).id || (decoded as any)._id || (decoded as any).userId;
        console.log("🔍 [TOKEN DEBUG] Extracted user ID:", userId);
        console.log("🔍 [TOKEN DEBUG] User ID type:", typeof userId);
        
        return NextResponse.json({
            success: true,
            decoded: decoded,
            extractedUserId: userId,
            userIdType: typeof userId,
            tokenPayload: {
                id: (decoded as any).id,
                _id: (decoded as any)._id,
                userId: (decoded as any).userId,
                email: (decoded as any).email,
                role: (decoded as any).role
            }
        });
        
    } catch (error: any) {
        console.error("❌ [TOKEN DEBUG] Error:", error);
        return NextResponse.json(
            { error: error.message || "Failed to decode token" },
            { status: 500 }
        );
    }
}