import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import mongoose from "mongoose";

export async function GET(req: NextRequest) {
    try {
        await connectDB();
        
        const { searchParams } = new URL(req.url);
        const userId = searchParams.get("userId");
        
        if (!userId) {
            return NextResponse.json(
                { error: "userId parameter is required" },
                { status: 400 }
            );
        }
        
        console.log("🔍 [USER NOTIFICATIONS DEBUG] Searching for notifications for user:", userId);
        
        // Try different query formats
        const receiverObjectId = new mongoose.Types.ObjectId(userId);
        const receiverString = userId;
        
        console.log("🔍 [USER NOTIFICATIONS DEBUG] ObjectId format:", receiverObjectId.toString());
        console.log("🔍 [USER NOTIFICATIONS DEBUG] String format:", receiverString);
        
        // Query 1: Exact ObjectId match
        const objectIdMatches = await Notification.find({
            receiver: receiverObjectId
        }).lean();
        
        // Query 2: Exact String match
        const stringMatches = await Notification.find({
            receiver: receiverString
        }).lean();
        
        // Query 3: OR query (both formats)
        const orMatches = await Notification.find({
            $or: [
                { receiver: receiverObjectId },
                { receiver: receiverString }
            ]
        }).lean();
        
        // Query 4: All notifications (for comparison)
        const allNotifications = await Notification.find({}).lean();
        
        // Query 5: STATS_APPROVAL_REQUEST notifications specifically
        const statsNotifications = await Notification.find({
            type: "STATS_APPROVAL_REQUEST"
        }).lean();
        
        console.log("🔍 [USER NOTIFICATIONS DEBUG] Results:");
        console.log("   - ObjectId matches:", objectIdMatches.length);
        console.log("   - String matches:", stringMatches.length);
        console.log("   - OR matches:", orMatches.length);
        console.log("   - Total notifications in system:", allNotifications.length);
        console.log("   - STATS_APPROVAL_REQUEST notifications:", statsNotifications.length);
        
        // Log details of matching notifications
        if (orMatches.length > 0) {
            console.log("🔍 [USER NOTIFICATIONS DEBUG] Matching notifications:");
            orMatches.forEach((notif, index) => {
                console.log(`   ${index + 1}. ID: ${notif._id.toString()}`);
                console.log(`      Type: ${notif.type}`);
                console.log(`      Receiver: ${notif.receiver.toString()}`);
                console.log(`      Receiver Type: ${typeof notif.receiver}`);
                console.log(`      Status: ${notif.status}`);
                console.log(`      Created: ${notif.createdAt}`);
            });
        }
        
        // Log STATS_APPROVAL_REQUEST notifications for this user
        const userStatsNotifications = statsNotifications.filter(n => 
            n.receiver.toString() === userId || 
            n.receiver.toString() === receiverObjectId.toString()
        );
        
        console.log("🔍 [USER NOTIFICATIONS DEBUG] STATS_APPROVAL_REQUEST for this user:", userStatsNotifications.length);
        
        return NextResponse.json({
            success: true,
            userId: userId,
            queries: {
                objectIdMatches: objectIdMatches.length,
                stringMatches: stringMatches.length,
                orMatches: orMatches.length,
                totalNotifications: allNotifications.length,
                statsNotifications: statsNotifications.length,
                userStatsNotifications: userStatsNotifications.length
            },
            notifications: {
                objectIdMatches: objectIdMatches.map(n => ({
                    id: n._id.toString(),
                    type: n.type,
                    receiver: n.receiver.toString(),
                    receiverType: typeof n.receiver,
                    status: n.status,
                    createdAt: n.createdAt
                })),
                stringMatches: stringMatches.map(n => ({
                    id: n._id.toString(),
                    type: n.type,
                    receiver: n.receiver.toString(),
                    receiverType: typeof n.receiver,
                    status: n.status,
                    createdAt: n.createdAt
                })),
                orMatches: orMatches.map(n => ({
                    id: n._id.toString(),
                    type: n.type,
                    receiver: n.receiver.toString(),
                    receiverType: typeof n.receiver,
                    status: n.status,
                    createdAt: n.createdAt
                }))
            },
            allStatsNotifications: statsNotifications.map(n => ({
                id: n._id.toString(),
                type: n.type,
                receiver: n.receiver.toString(),
                receiverType: typeof n.receiver,
                status: n.status,
                createdAt: n.createdAt
            }))
        });
        
    } catch (error: any) {
        console.error("❌ [USER NOTIFICATIONS DEBUG] Error:", error);
        return NextResponse.json(
            { error: error.message || "Failed to debug user notifications" },
            { status: 500 }
        );
    }
}