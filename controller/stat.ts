import { NextRequest, NextResponse } from "next/server";
import mongoose from "mongoose";
import { connectDB } from "@/lib/db";
import Stat from "@/modules/stat";
import Match from "@/modules/match";
import Notification from "@/modules/notification";
import SuperAdmin from "@/modules/superadmin";
import User from "@/modules/user";
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
 * Helper to convert string ID to ObjectId
 */
function toObjectId(id: string): mongoose.Types.ObjectId {
    if (!mongoose.Types.ObjectId.isValid(id)) {
        throw new Error("Invalid ID format");
    }
    return new mongoose.Types.ObjectId(id);
}

/**
 * Create or Update a Stat record
 * POST /api/stats
 */
export async function createOrUpdateStat(req: NextRequest) {
    try {
        await connectDB();
        const decoded = await verifyUser(req);
        const userId = (decoded as any).id || (decoded as any)._id || (decoded as any).userId;

        const body = await req.json();
        const { leagueId, matchId, teamId, playerId, stats } = body;

        if (!leagueId || !matchId || !teamId || !playerId) {
            return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
        }

        // Check if a DRAFT record exists for this keeper/match/player
        let stat = await Stat.findOne({
            matchId: toObjectId(matchId),
            playerId: toObjectId(playerId),
            createdBy: toObjectId(userId),
            status: "DRAFT"
        });

        if (stat) {
            // Apply cumulative updates: sum existing numeric stats with new ones
            const existingStats = (stat as any).stats || {};
            const updatedStats = { ...existingStats };

            Object.keys(stats).forEach(key => {
                if (typeof stats[key] === 'number') {
                    updatedStats[key] = (existingStats[key] || 0) + stats[key];
                } else {
                    updatedStats[key] = stats[key];
                }
            });

            stat.stats = updatedStats;
            (stat as any).markModified("stats");
            await stat.save();
        } else {
            stat = new Stat({
                leagueId: toObjectId(leagueId),
                matchId: toObjectId(matchId),
                teamId: toObjectId(teamId),
                playerId: toObjectId(playerId),
                stats,
                createdBy: toObjectId(userId),
                status: "DRAFT"
            });
            await stat.save();
        }

        return NextResponse.json({ message: "Stat saved successfully", data: stat }, { status: 200 });
    } catch (error: any) {
        console.error("Create/Update stat error:", error);
        return NextResponse.json({ error: error.message || "Failed to save stat" }, { status: 500 });
    }
}

/**
 * Get Stats
 * GET /api/stats?matchId=...&status=...&createdBy=...
 */
export async function getStats(req: NextRequest) {
    try {
        await connectDB();
        await verifyUser(req);

        const { searchParams } = new URL(req.url);
        const matchId = searchParams.get("matchId");
        const status = searchParams.get("status");
        const createdBy = searchParams.get("createdBy");

        const query: any = {};
        if (matchId && mongoose.Types.ObjectId.isValid(matchId)) query.matchId = toObjectId(matchId);
        if (status) query.status = status;
        if (createdBy && mongoose.Types.ObjectId.isValid(createdBy)) query.createdBy = toObjectId(createdBy);

        if (Object.keys(query).length === 0) {
            return NextResponse.json({ data: [] }, { status: 200 });
        }

        const stats = await Stat.find(query)
            .populate("playerId", "firstName lastName")
            .populate("teamId", "teamName")
            .populate("leagueId", "leagueName")
            .lean();

        return NextResponse.json({ data: stats }, { status: 200 });
    } catch (error: any) {
        console.error("Get stats error:", error);
        return NextResponse.json({ error: error.message || "Failed to fetch stats" }, { status: 500 });
    }
}

/**
 * Submit stats for approval
 * POST /api/stats/submit
 */
export async function submitStatsForApproval(req: NextRequest) {
    try {
        await connectDB();
        const decoded = await verifyUser(req);
        const userId = (decoded as any).id || (decoded as any)._id || (decoded as any).userId;

        const { matchId } = await req.json();
        if (!matchId) return NextResponse.json({ error: "Match ID is required" }, { status: 400 });

        console.log("🔍 [SUBMIT STATS DEBUG] Starting submission process...");
        console.log("🔍 [SUBMIT STATS DEBUG] User ID:", userId);
        console.log("🔍 [SUBMIT STATS DEBUG] Match ID:", matchId);

        // Check if there are any DRAFT stats for this user and match
        const draftStats = await Stat.find({
            matchId: toObjectId(matchId),
            createdBy: toObjectId(userId),
            status: "DRAFT"
        });
        console.log("🔍 [SUBMIT STATS DEBUG] Found DRAFT stats count:", draftStats.length);

        if (draftStats.length === 0) {
            console.log("⚠️ [SUBMIT STATS DEBUG] No DRAFT stats found to submit");
            return NextResponse.json({ message: "No draft stats found to submit", count: 0 }, { status: 200 });
        }

        // Update all DRAFT stats for this match by this user to PENDING_APPROVAL
        const result = await Stat.updateMany(
            { matchId: toObjectId(matchId), createdBy: toObjectId(userId), status: "DRAFT" },
            { $set: { status: "PENDING_APPROVAL" } }
        );

        console.log("🔍 [SUBMIT STATS DEBUG] Update result:", result);

        if (result.matchedCount > 0) {
            // Create notification for SPECIFIC Admin: pffl@gmail.com
            console.log("🔍 Looking for specific admin: pffl@gmail.com...");

            // Find the specific admin account
            let admin = await User.findOne({
                email: "pffl@gmail.com",
                role: "superadmin"
            });

            if (!admin) {
                console.log("🔍 Admin pffl@gmail.com not found in User collection, checking SuperAdmin collection...");
                admin = await SuperAdmin.findOne({ email: "pffl@gmail.com" });
            }

            if (!admin) {
                console.log("❌ ERROR: Specific admin pffl@gmail.com not found!");
                return NextResponse.json({
                    message: "Stats submitted but admin notification failed - admin account not found",
                    count: result.matchedCount
                }, { status: 200 });
            }

            const allAdmins = [admin]; // Only this specific admin
            console.log("🔍 Found specific admin:", admin._id.toString(), admin.email);
            
            const match = await Match.findById(toObjectId(matchId)).populate("leagueId");
            console.log("🔍 Found match:", match ? `${(match as any).teamAName} vs ${(match as any).teamBName}` : "null");

            if (admin && match && allAdmins.length > 0) {
                // Construct a detailed message for Requirement #4
                const statsToSubmit = await Stat.find({
                    matchId: toObjectId(matchId),
                    createdBy: toObjectId(userId),
                    status: "PENDING_APPROVAL"
                }).populate("playerId", "firstName lastName").populate("teamId", "teamName");

                console.log("🔍 Stats to submit count:", statsToSubmit.length);

                let detailedMessage = `League: ${(match as any).leagueId?.leagueName || "N/A"}\n`;
                detailedMessage += `Match: ${(match as any).teamAName} vs ${(match as any).teamBName}\n\n`;
                detailedMessage += `Submitted Stats:\n`;

                statsToSubmit.forEach(s => {
                    const pName = `${(s as any).playerId?.firstName || ""} ${(s as any).playerId?.lastName || ""}`.trim() || "Team Stat";
                    const tName = (s as any).teamId?.teamName || "Team";
                    const st = (s as any).stats || {};
                    detailedMessage += `- [${tName}] ${pName}: TD: ${st.touchdowns || 0}, Catches: ${st.catches || 0}, Pass Yds: ${st.passYards || 0}\n`;
                });

                console.log("📧 Creating notifications for all admins...");
                console.log("   - Sender:", userId);
                console.log("   - Type: STATS_APPROVAL_REQUEST");
                console.log("   - Match:", matchId);
                console.log("   - League:", (match as any).leagueId?._id?.toString());
                console.log("   - Message:", detailedMessage);

                // Create notification for each admin
                const notificationPromises = allAdmins.map(async (adminUser) => {
                    try {
                        // Ensure receiver ID is properly formatted as ObjectId
                        const receiverId = toObjectId(adminUser._id.toString());
                        
                        console.log(`🔍 Creating notification for admin: ${adminUser.email}`);
                        console.log(`🔍 Admin ID: ${adminUser._id.toString()}`);
                        console.log(`🔍 Receiver ID (ObjectId): ${receiverId.toString()}`);
                        console.log(`🔍 Sender ID: ${userId}`);
                        console.log(`🔍 Match ID: ${matchId}`);
                        console.log(`🔍 League ID: ${(match as any).leagueId?._id?.toString()}`);
                        
                        const notification = await Notification.create({
                            sender: toObjectId(userId),
                            receiver: receiverId,
                            match: toObjectId(matchId),
                            league: (match as any).leagueId?._id ? toObjectId((match as any).leagueId._id.toString()) : null,
                            type: "STATS_APPROVAL_REQUEST",
                            status: "pending",
                            message: detailedMessage,
                            data: {
                                matchName: `${(match as any).teamAName} vs ${(match as any).teamBName}`,
                                leagueName: (match as any).leagueId?.leagueName
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
                        
                        return notification;
                    } catch (notificationError: any) {
                        console.error(`❌ Failed to create notification for admin ${adminUser._id.toString()}:`, notificationError);
                        console.error("❌ Notification error details:", notificationError.message);
                        console.error("❌ Notification error stack:", notificationError.stack);
                        return null;
                    }
                });

                // Wait for all notifications to be created
                const createdNotifications = await Promise.allSettled(notificationPromises);
                const successCount = createdNotifications.filter(result => result.status === 'fulfilled' && result.value !== null).length;
                console.log(`✅ Successfully created ${successCount} out of ${allAdmins.length} notifications`);
            } else {
                console.log("❌ Failed to create notification - missing admin or match");
                console.log("   - Admin found:", !!admin);
                console.log("   - Match found:", !!match);
                console.log("   - Admins to notify:", allAdmins.length);
                if (admin) {
                    console.log("   - Admin ID:", admin._id.toString());
                    console.log("   - Admin email:", admin.email);
                }
            }
        }

        return NextResponse.json({ message: "Stats submitted for approval", count: result.matchedCount }, { status: 200 });
    } catch (error: any) {
        console.error("Submit stats error:", error);
        return NextResponse.json({ error: error.message || "Failed to submit stats" }, { status: 500 });
    }
}

/**
 * Approve stats
 * POST /api/stats/approve
 */
export async function approveStats(req: NextRequest) {
    try {
        await connectDB();
        const decoded = await verifyUser(req);
        const isAdmin = (decoded as any).role === "superadmin";

        if (!isAdmin) {
            return NextResponse.json({ error: "Unauthorized. Admins only." }, { status: 403 });
        }

        const { matchId, statkeeperId } = await req.json();
        if (!matchId || !statkeeperId) {
            return NextResponse.json({ error: "Match ID and Statkeeper ID are required" }, { status: 400 });
        }

        // 1. Mark stats as APPROVED
        await Stat.updateMany(
            { matchId: toObjectId(matchId), createdBy: toObjectId(statkeeperId), status: "PENDING_APPROVAL" },
            { $set: { status: "APPROVED" } }
        );

        // 2. Aggregate stats and sync to Match document
        // This is the "final views" sync
        const approvedStats = await Stat.find({
            matchId: toObjectId(matchId),
            status: "APPROVED"
        }).lean();

        const match = await Match.findById(toObjectId(matchId));
        if (!match) return NextResponse.json({ error: "Match not found" }, { status: 404 });

        // Helper to aggregate stats into the match format
        const updateTeamStats = (teamData: any, statsList: any[]) => {
            const teamStats = {
                catches: 0, catchYards: 0, rushes: 0, rushYards: 0,
                passAttempts: 0, passYards: 0, completions: 0,
                touchdowns: 0, flagPull: 0, sack: 0,
                interceptions: 0, safeties: 0, extraPoints: 0,
                totalPoints: 0
            };

            const playerStatsMap = new Map();

            statsList.forEach(s => {
                // Aggregate team stats
                teamStats.catches += s.stats.catches || 0;
                teamStats.catchYards += s.stats.catchYards || 0;
                teamStats.rushes += s.stats.rushes || 0;
                teamStats.rushYards += s.stats.rushYards || 0;
                teamStats.passAttempts += s.stats.passAttempts || 0;
                teamStats.passYards += s.stats.passYards || 0;
                teamStats.completions += s.stats.completions || 0;
                teamStats.touchdowns += s.stats.touchdowns || 0;
                teamStats.flagPull += s.stats.flagPull || 0;
                teamStats.sack += s.stats.sack || 0;
                teamStats.interceptions += s.stats.interceptions || 0;
                teamStats.safeties += s.stats.safeties || 0;
                teamStats.extraPoints += s.stats.extraPoints || 0;

                // Aggregate player stats
                const pId = s.playerId.toString();
                if (!playerStatsMap.has(pId)) {
                    playerStatsMap.set(pId, { playerId: s.playerId, ...s.stats });
                } else {
                    const existing = playerStatsMap.get(pId);
                    Object.keys(s.stats).forEach(key => {
                        existing[key] = (existing[key] || 0) + (s.stats[key] || 0);
                    });
                }
            });

            // Calculate total points (proxy logic)
            teamStats.totalPoints = (teamStats.touchdowns * 6) + teamStats.extraPoints + (teamStats.safeties * 2);

            teamData.teamStats = teamStats;
            teamData.score = teamStats.totalPoints;
            teamData.playerStats = Array.from(playerStatsMap.values());
        };

        const teamAId = (match as any).teamA.teamId.toString();
        const statsA = approvedStats.filter(s => s.teamId.toString() === teamAId);
        const statsB = approvedStats.filter(s => s.teamId.toString() !== teamAId);

        updateTeamStats((match as any).teamA, statsA);
        updateTeamStats((match as any).teamB, statsB);

        (match as any).markModified("teamA");
        (match as any).markModified("teamB");
        await match.save();

        return NextResponse.json({ message: "Stats approved and synced successfully" }, { status: 200 });
    } catch (error: any) {
        console.error("Approve stats error:", error);
        return NextResponse.json({ error: error.message || "Failed to approve stats" }, { status: 500 });
    }
}
