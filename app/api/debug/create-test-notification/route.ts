import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import User from "@/modules/user";
import SuperAdmin from "@/modules/superadmin";
import mongoose from "mongoose";

export async function POST(req: NextRequest) {
    try {
        await connectDB();
        
        console.log("🔍 [TEST NOTIFICATION] Creating test STATS_APPROVAL_REQUEST notifications for all admins...");
        
        // Find all admins to send to
        let allAdmins = [];
        const userAdmins = await User.find({ role: "superadmin" });
        const superAdmins = await SuperAdmin.find({});
        
        allAdmins = [...userAdmins, ...superAdmins];
        
        if (allAdmins.length === 0) {
            return NextResponse.json(
                { error: "No admins found to send notifications to" },
                { status: 404 }
            );
        }
        
        console.log("🔍 [TEST NOTIFICATION] Found admins:", allAdmins.length);
        allAdmins.forEach((admin, index) => {
            console.log(`🔍 [TEST NOTIFICATION] Admin ${index + 1}: ${admin._id.toString()} (${admin.email})`);
        });
        
        // Create test notifications for all admins
        const notificationPromises = allAdmins.map(async (admin, index) => {
            try {
                const testNotification = await Notification.create({
                    sender: new mongoose.Types.ObjectId("507f1f77bcf86cd799439011"), // Dummy sender ID
                    receiver: admin._id,
                    type: "STATS_APPROVAL_REQUEST",
                    status: "pending",
                    message: `TEST ${index + 1}: Stats submitted for approval - Test Match in Test League (Admin: ${admin.email})`,
                    data: {
                        matchName: "Test Team A vs Test Team B",
                        leagueName: "Test League"
                    }
                });
                
                console.log(`✅ [TEST NOTIFICATION] Created notification ${index + 1} for admin ${admin.email}:`, testNotification._id.toString());
                return {
                    id: testNotification._id.toString(),
                    receiver: testNotification.receiver.toString(),
                    type: testNotification.type,
                    status: testNotification.status,
                    message: testNotification.message,
                    adminEmail: admin.email
                };
            } catch (error: any) {
                console.error(`❌ [TEST NOTIFICATION] Failed to create notification for admin ${admin.email}:`, error);
                return null;
            }
        });
        
        const results = await Promise.allSettled(notificationPromises);
        const successfulNotifications = results
            .filter(result => result.status === 'fulfilled' && result.value !== null)
            .map(result => (result as PromiseFulfilledResult<any>).value);
        
        console.log(`✅ [TEST NOTIFICATION] Created ${successfulNotifications.length} out of ${allAdmins.length} test notifications`);
        
        return NextResponse.json({
            success: true,
            message: `Test notifications created successfully for ${successfulNotifications.length} admins`,
            notifications: successfulNotifications,
            totalAdmins: allAdmins.length,
            admins: allAdmins.map(admin => ({
                id: admin._id.toString(),
                email: admin.email,
                role: admin.role || "superadmin"
            }))
        });
        
    } catch (error: any) {
        console.error("❌ [TEST NOTIFICATION] Error:", error);
        return NextResponse.json(
            { error: error.message || "Failed to create test notifications" },
            { status: 500 }
        );
    }
}