import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import SuperAdmin from "@/modules/superadmin";
import User from "@/modules/user";
import { verifyAccessToken } from "@/lib/jwt";
import mongoose from "mongoose";

// Helper to get token from request
function getToken(req: NextRequest): string | null {
    const authHeader = req.headers.get("authorization");
    return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

// Helper to verify user from token
async function verifyUserToken(req: NextRequest) {
    const token = getToken(req);
    if (!token) throw new Error("No token provided");

    const decoded = verifyAccessToken(token);
    return decoded;
}

export async function POST(req: NextRequest) {
    try {
        await connectDB();
        const decoded = await verifyUserToken(req);
        const userId = decoded.userId;

        const body = await req.json();
        const { type, message, isAdmin, receiverId } = body;

        let receiverObjectId;

        if (isAdmin) {
            // Find a SuperAdmin to send to
            // First check User collection for role "superadmin", then SuperAdmin collection
            let admin = await User.findOne({ role: "superadmin" });
            if (!admin) {
                admin = await SuperAdmin.findOne();
            }
            if (!admin) {
                return NextResponse.json(
                    { error: "No Admin found to receive notification" },
                    { status: 404 }
                );
            }
            receiverObjectId = admin._id;
        } else if (receiverId) {
            receiverObjectId = new mongoose.Types.ObjectId(receiverId);
        } else {
            return NextResponse.json(
                { error: "Receiver is required" },
                { status: 400 }
            );
        }

        const notification = await Notification.create({
            sender: new mongoose.Types.ObjectId(userId),
            receiver: receiverObjectId,
            type: type || 'STATS_APPROVAL_REQUEST',
            status: 'pending',
            message: message || '',
        });

        return NextResponse.json(
            { message: "Notification sent successfully", data: notification },
            { status: 201 }
        );
    } catch (error: any) {
        console.error("Error sending notification:", error);
        return NextResponse.json(
            { error: error.message || "Failed to send notification" },
            { status: 500 }
        );
    }
}
