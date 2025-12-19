import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import League from "@/modules/league";
import User from "@/modules/user";
import Payment from "@/modules/payment";
import Team from "@/modules/team";
import Match from "@/modules/match";
import { verifyAccessToken } from "@/lib/jwt";

function getToken(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  return authHeader?.startsWith("Bearer ") ? authHeader.substring(7) : null;
}

async function verifyUser(req: NextRequest) {
  const token = getToken(req);
  if (!token) throw new Error("No token provided");
  const decoded = verifyAccessToken(token);
  
  // Verify user is superadmin - check token role first, then database
  if (decoded.role !== "superadmin") {
    // Also check database in case role is not in token
    const user = await User.findById(decoded.userId);
    if (!user || user.role !== "superadmin") {
      throw new Error("Unauthorized - Superadmin access required");
    }
  }
  
  return decoded;
}

export async function GET(req: NextRequest) {
  try {
    await connectDB();
    console.log("✅ Database connected");
    
    await verifyUser(req);
    console.log("✅ User verified as superadmin");

    // Get total leagues count
    const totalLeagues = await League.countDocuments();
    console.log("📊 Total leagues:", totalLeagues);
    
    // Get active leagues count (based on start date)
    const currentDate = new Date();
    const allLeagues = await League.find({}).lean(); // Use lean() for better performance
    const activeLeaguesCount = allLeagues.filter((league: any) => {
      const startDate = new Date(league.startDate);
      return startDate <= currentDate;
    }).length;
    console.log("📊 Active leagues:", activeLeaguesCount);
    console.log("📊 Sample league teams:", allLeagues[0]?.teams?.length || 0);

    // Get leagues created this month
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);
    const leaguesThisMonth = await League.countDocuments({
      createdAt: { $gte: startOfMonth }
    });
    console.log("📊 Leagues this month:", leaguesThisMonth);

    // Get total users count
    const totalUsers = await User.countDocuments();
    console.log("📊 Total users:", totalUsers);
    
    // Get users by role
    const usersByRole = await User.aggregate([
      {
        $group: {
          _id: "$role",
          count: { $sum: 1 }
        }
      }
    ]);
    console.log("📊 Users by role:", usersByRole);

    // Get users created this week
    const startOfWeek = new Date();
    startOfWeek.setDate(startOfWeek.getDate() - 7);
    const usersThisWeek = await User.countDocuments({
      createdAt: { $gte: startOfWeek }
    });
    console.log("📊 Users this week:", usersThisWeek);

    // Get all unpaid payments
    const unpaidPayments = await Payment.find({ status: "unpaid" });
    const totalPendingAmount = unpaidPayments.reduce((sum, payment) => sum + (payment.amount || 0), 0);
    const pendingPaymentsCount = unpaidPayments.length;
    console.log("📊 Pending payments:", pendingPaymentsCount, "Total amount:", totalPendingAmount);

    // Get total matches/games count from Match collection
    const totalMatches = await Match.countDocuments();
    console.log("📊 Total matches/games:", totalMatches);

    // Calculate active games - count teams in active leagues only
    const totalTeamsCount = await Team.countDocuments();
    console.log("📊 Total teams:", totalTeamsCount);
    
    // Count teams in active leagues
    const activeLeagues = allLeagues.filter((league: any) => {
      const startDate = new Date(league.startDate);
      return startDate <= currentDate;
    });
    
    // Get all team IDs from active leagues (teams array contains ObjectIds)
    let activeGamesCount = 0;
    for (const league of activeLeagues) {
      if (league.teams && Array.isArray(league.teams)) {
        activeGamesCount += league.teams.length;
      }
    }
    
    console.log("📊 Active games count (teams in active leagues):", activeGamesCount);

    // Get games/teams for today (teams in leagues that started today)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const leaguesStartingToday = await League.find({
      startDate: { $gte: today, $lt: tomorrow }
    });
    
    let gamesToday = 0;
    for (const league of leaguesStartingToday) {
      if (league.teams && Array.isArray(league.teams)) {
        gamesToday += league.teams.length;
      }
    }
    
    console.log("📊 Games today:", gamesToday);

    const statsData = {
      leagues: {
        total: totalLeagues,
        active: activeLeaguesCount,
        thisMonth: leaguesThisMonth
      },
      games: {
        total: totalMatches,
        active: activeGamesCount,
        today: gamesToday
      },
      users: {
        total: totalUsers,
        thisWeek: usersThisWeek,
        byRole: usersByRole.reduce((acc: any, item: any) => {
          acc[item._id] = item.count;
          return acc;
        }, {})
      },
      payments: {
        totalAmount: totalPendingAmount,
        count: pendingPaymentsCount
      }
    };

    console.log("✅ Returning stats data:", JSON.stringify(statsData, null, 2));

    return NextResponse.json(
      {
        success: true,
        data: statsData
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("❌ Error fetching stats:", error);
    console.error("Error stack:", error.stack);
    if (error.message === "No token provided" || error.message === "Invalid token" || error.message.includes("Unauthorized")) {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to get stats" },
      { status: 500 }
    );
  }
}

