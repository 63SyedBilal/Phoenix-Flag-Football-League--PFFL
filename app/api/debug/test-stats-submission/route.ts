import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Notification from "@/modules/notification";
import SuperAdmin from "@/modules/superadmin";
import User from "@/modules/user";
import mongoose from "mongoose";

export async function POST(req: NextRequest) {
    try {
        await connectDB();
        
        console.log("🔍 [TEST STATS SUBMISSION] Simulating stats submission notification flow...");
        
        // Simulate a stat keeper user ID (dummy)
        const statKeeperUserId = new mongoose.Types.ObjectId("507f1f77bcf86cd799439011");
        
        // Find all admins (same logic as real stats submission)
        console.log("🔍 Looking for SuperAdmin to send notification...");
        let admin = await User.findOne({ role: "superadmin" });
        let allAdmins = [];
        
        // Find SPECIFIC admin for testing: pffl@gmail.com
        admin = await User.findOne({
            email: "pffl@gmail.com",
            role: "superadmin"
        });
        if (!admin) {
            admin = await SuperAdmin.findOne({ email: "pffl@gmail.com" });
        }

        if (admin) {
            allAdmins = [admin];
        }
        
        console.log("🔍 Found admin for match lookup:", admin ? admin._id.toString() : "null");
        console.log("🔍 Will notify admins:", allAdmins.map(a => a._id.toString()));
        
        if (allAdmins.length === 0) {
            return NextResponse.json(
                { error: "No admins found to send notifications to" },
                { status: 404 }
            );
        }
        
        // Create detailed message (same as real implementation)
        let detailedMessage = `League: Test League\n`;
        detailedMessage += `Match: Test Team A vs Test Team B\n\n`;
        detailedMessage += `Submitted Stats:\n`;
        detailedMessage += `- [Test Team A] John Doe: TD: 2, Catches: 5, Pass Yds: 150\n`;
        detailedMessage += `- [Test Team B] Jane Smith: TD: 1, Catches: 3, Pass Yds: 80\n`;
        
        console.log("📧 Creating notifications for all admins...");
        console.log("   - Sender:", statKeeperUserId.toString());
        console.log("   - Type: STATS_APPROVAL_REQUEST");
        console.log("   - Message:", detailedMessage);
        
        // Create notification for each admin (same logic as real implementation)
        const notificationPromises = allAdmins.map(async (adminUser) => {
            try {
                const receiverId = new mongoose.Types.ObjectId(adminUser._id.toString());
                
                console.log(`🔍 Creating notification for admin: ${adminUser.email}`);
                console.log(`🔍 Admin ID: ${adminUser._id.toString()}`);
                console.log(`🔍 Receiver ID (ObjectId): ${receiverId.toString()}`);
                
                const notification = await Notification.create({
                    sender: statKeeperUserId,
                    receiver: receiverId,
                    match: new mongoose.Types.ObjectId("507f1f77bcf86cd799439012"), // Dummy match ID
                    league: new mongoose.Types.ObjectId("507f1f77bcf86cd799439013"), // Dummy league ID
                    type: "STATS_APPROVAL_REQUEST",
                    status: "pending",
                    message: detailedMessage,
                    data: {
                        matchName: "Test Team A vs Test Team B",
                        leagueName: "Test League"
                    }
                });

                console.log(`✅ Notification created successfully!`);
                console.log(`✅ Notification ID: ${notification._id.toString()}`);
                console.log(`✅ Notification receiver: ${notification.receiver.toString()}`);
                console.log(`✅ Notification type: ${notification.type}`);
                console.log(`✅ Admin email: ${adminUser.email}`);
                
                // Verify the notification was saved correctly
                const savedNotification = await Notification.findById(notification._id).lean();
                if (savedNotification) {
                    console.log(`✅ Verification: Notification saved with receiver: ${savedNotification.receiver.toString()}`);
                } else {
                    console.error(`❌ Verification failed: Notification not found after creation`);
                }
                
                return {
                    id: notification._id.toString(),
                    receiver: notification.receiver.toString(),
                    type: notification.type,
                    status: notification.status,
                    message: notification.message,
                    adminEmail: adminUser.email
                };
            } catch (notificationError: any) {
                console.error(`❌ Failed to create notification for admin ${adminUser._id.toString()}:`, notificationError);
                console.error("❌ Notification error details:", notificationError.message);
                return null;
            }
        });
        
        // Wait for all notifications to be created
        const results = await Promise.allSettled(notificationPromises);
        const successfulNotifications = results
            .filter(result => result.status === 'fulfilled' && result.value !== null)
            .map(result => (result as PromiseFulfilledResult<any>).value);
        
        console.log(`✅ Successfully created ${successfulNotifications.length} out of ${allAdmins.length} notifications`);
        
        return NextResponse.json({
            success: true,
            message: `Test stats submission notifications created successfully for ${successfulNotifications.length} admins`,
            notifications: successfulNotifications,
            totalAdmins: allAdmins.length,
            admins: allAdmins.map(admin => ({
                id: admin._id.toString(),
                email: admin.email,
                role: admin.role || "superadmin"
            }))
        });
        
    } catch (error: any) {
        console.error("❌ [TEST STATS SUBMISSION] Error:", error);
        return NextResponse.json(
            { error: error.message || "Failed to test stats submission" },
            { status: 500 }
        );
    }
}