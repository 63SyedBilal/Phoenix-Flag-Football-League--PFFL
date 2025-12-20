import { NextRequest, NextResponse } from "next/server";
import mongoose from "mongoose";
import { connectDB } from "@/lib/db";
import Match from "@/modules/match";
import League from "@/modules/league";
import Team from "@/modules/team";
import Notification from "@/modules/notification";
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
 * Create a new match
 * POST /api/match
 */
export async function createMatch(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const {
      leagueId,
      teamA,
      teamB,
      teamAName,
      teamBName,
      gameDate,
      gameTime,
      venue,
      refereeId,
      statKeeperId,
      roundName,
      gameNumber,
      status,
    } = await req.json();

    // Validate required fields
    if (!leagueId || !teamA || !teamB || !gameDate || !gameTime) {
      return NextResponse.json(
        { error: "League ID, Team A, Team B, Game Date, and Game Time are required" },
        { status: 400 }
      );
    }

    // Convert IDs to ObjectId format
    let leagueObjectId: mongoose.Types.ObjectId;
    let teamAObjectId: mongoose.Types.ObjectId;
    let teamBObjectId: mongoose.Types.ObjectId;

    try {
      leagueObjectId = toObjectId(leagueId);
      teamAObjectId = toObjectId(teamA);
      teamBObjectId = toObjectId(teamB);
    } catch (error: any) {
      return NextResponse.json(
        { error: `Invalid ID format: ${error.message}` },
        { status: 400 }
      );
    }

    // Verify league exists and get date range
    const league = await League.findById(leagueObjectId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // TODO: TEMPORARY - Team existence check disabled for development
    // In the future, teams will be created by captains and fetched from backend
    // For now, allowing matches to be created even if teams don't exist in database
    // This allows the flow to continue with dummy teams
    // Once real teams are implemented, uncomment the validation below
    /*
    // Verify teams exist
    const teamAExists = await Team.findById(teamAObjectId);
    const teamBExists = await Team.findById(teamBObjectId);
    
    if (!teamAExists) {
      return NextResponse.json(
        { error: `Team A not found. Team ID: ${teamA}` },
        { status: 404 }
      );
    }
    
    if (!teamBExists) {
      return NextResponse.json(
        { error: `Team B not found. Team ID: ${teamB}` },
        { status: 404 }
      );
    }
    */

    // Validate game date is within league date range
    const gameDateObj = new Date(gameDate);
    const leagueStart = new Date((league as any).startDate);
    const leagueEnd = new Date((league as any).endDate);

    if (gameDateObj < leagueStart || gameDateObj > leagueEnd) {
      return NextResponse.json(
        { error: "Game date must be within the league date range" },
        { status: 400 }
      );
    }

    // Validate status enum
    if (status && !["upcoming", "live", "completed", "cancelled"].includes(status)) {
      return NextResponse.json(
        { error: "Invalid status. Must be: upcoming, live, completed, or cancelled" },
        { status: 400 }
      );
    }

    const matchData: any = {
      leagueId: leagueObjectId,
      teamA: teamAObjectId,
      teamAName: teamAName || "",
      teamB: teamBObjectId,
      teamBName: teamBName || "",
      gameDate: gameDateObj,
      gameTime: gameTime.trim(),
      venue: venue || "",
      roundName: roundName || "Group Stage",
      gameNumber: gameNumber || "",
      status: status || "upcoming",
    };

    if (refereeId) {
      matchData.refereeId = toObjectId(refereeId);
    }

    if (statKeeperId) {
      matchData.statKeeperId = toObjectId(statKeeperId);
    }

    const match = new Match(matchData);
    await match.save();

    // Get sender ID from token (admin who created the match)
    const senderId = toObjectId(decoded.userId);
    const matchObjectId = (match as any)._id;

    // Create notifications for assigned referee and stat keeper
    const notifications = [];

    // Create notification for referee if assigned
    if (refereeId) {
      try {
        const refereeObjectId = toObjectId(refereeId);
        const refereeNotification = await Notification.create({
          sender: senderId,
          receiver: refereeObjectId,
          league: leagueObjectId,
          match: matchObjectId,
          type: "GAME_ASSIGNED",
          status: "pending"
        });
        notifications.push(refereeNotification);
        console.log("✅ Notification created for referee:", {
          notificationId: refereeNotification._id.toString(),
          refereeId: refereeId,
          matchId: matchObjectId.toString()
        });
      } catch (error: any) {
        console.error("❌ Error creating notification for referee:", error);
        // Don't fail match creation if notification fails
      }
    }

    // Create notification for stat keeper if assigned
    if (statKeeperId) {
      try {
        const statKeeperObjectId = toObjectId(statKeeperId);
        const statKeeperNotification = await Notification.create({
          sender: senderId,
          receiver: statKeeperObjectId,
          league: leagueObjectId,
          match: matchObjectId,
          type: "GAME_ASSIGNED",
          status: "pending"
        });
        notifications.push(statKeeperNotification);
        console.log("✅ Notification created for stat keeper:", {
          notificationId: statKeeperNotification._id.toString(),
          statKeeperId: statKeeperId,
          matchId: matchObjectId.toString()
        });
      } catch (error: any) {
        console.error("❌ Error creating notification for stat keeper:", error);
        // Don't fail match creation if notification fails
      }
    }

    // Populate references
    await match.populate("leagueId", "leagueName format startDate endDate");
    await match.populate("teamA", "teamName enterCode");
    await match.populate("teamB", "teamName enterCode");
    if (match.refereeId) {
      await match.populate("refereeId", "firstName lastName email");
    }
    if (match.statKeeperId) {
      await match.populate("statKeeperId", "firstName lastName email");
    }

    // Convert to plain object and handle failed populates
    const matchObj = match.toObject();
    if (!matchObj.teamA || (matchObj.teamA && !matchObj.teamA.teamName)) {
      // Team populate failed, use original ObjectId
      matchObj.teamA = matchObj.teamA?._id?.toString() || matchObj.teamA?.toString() || teamA;
    }
    if (!matchObj.teamB || (matchObj.teamB && !matchObj.teamB.teamName)) {
      // Team populate failed, use original ObjectId
      matchObj.teamB = matchObj.teamB?._id?.toString() || matchObj.teamB?.toString() || teamB;
    }

    return NextResponse.json(
      {
        message: "Match created successfully",
        data: matchObj,
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Create match error:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to create match" },
      { status: 500 }
    );
  }
}

/**
 * Get all matches (with optional filters)
 * GET /api/match?leagueId=:id&status=upcoming
 */
export async function getAllMatches(req: NextRequest) {
  try {
    console.log("🔵 getAllMatches called");
    await connectDB();
    console.log("✅ Database connected");
    
    try {
      await verifyUser(req);
      console.log("✅ User verified");
    } catch (authError: any) {
      console.error("❌ Auth error:", authError);
      return NextResponse.json({ error: authError.message || "Authentication failed" }, { status: 401 });
    }

    const { searchParams } = new URL(req.url);
    const leagueId = searchParams.get("leagueId");
    const status = searchParams.get("status");

    let query: any = {};

    if (leagueId) {
      try {
        query.leagueId = toObjectId(leagueId);
      } catch (e: any) {
        console.error("❌ Invalid leagueId:", e);
        return NextResponse.json({ error: "Invalid league ID format" }, { status: 400 });
      }
    }

    if (status) {
      if (!["upcoming", "live", "completed", "cancelled"].includes(status)) {
        return NextResponse.json({ error: "Invalid status filter" }, { status: 400 });
      }
      query.status = status;
    }
    
    console.log("🔍 Query:", JSON.stringify(query));

    let matches;
    try {
      console.log("🔍 Fetching matches from database...");
      // First try with populate, but catch errors gracefully
      matches = await Match.find(query)
        .populate("leagueId", "leagueName format startDate endDate logo")
        .populate("teamA", "teamName enterCode image")
        .populate("teamB", "teamName enterCode image")
        .populate("refereeId", "firstName lastName email role")
        .populate("statKeeperId", "firstName lastName email role")
        .sort({ gameDate: 1, gameTime: 1 })
        .lean()
        .exec();
      console.log(`✅ Found ${matches.length} matches`);
    } catch (populateError: any) {
      console.error("❌ Error in populate:", populateError);
      console.error("Error message:", populateError.message);
      console.error("Error stack:", populateError.stack);
      // If populate fails, try without populate - this is safe for missing references
      try {
        console.log("🔄 Retrying without populate (teams might not exist)...");
        matches = await Match.find(query)
          .sort({ gameDate: 1, gameTime: 1 })
          .lean()
          .exec();
        console.log(`✅ Found ${matches.length} matches (without populate)`);
      } catch (findError: any) {
        console.error("❌ Error in find:", findError);
        console.error("Find error stack:", findError.stack);
        throw findError;
      }
    }

    // If team populate failed (team doesn't exist), include the original ObjectId
    const matchesWithTeamIds = matches.map((match: any) => {
      // Handle teamA
      if (!match.teamA || (match.teamA && typeof match.teamA === 'object' && !match.teamA.teamName)) {
        // Team populate failed, use original ObjectId
        const teamAId = match.teamA?._id?.toString() || match.teamA?.toString() || match.teamA;
        match.teamA = teamAId;
      }
      
      // Handle teamB
      if (!match.teamB || (match.teamB && typeof match.teamB === 'object' && !match.teamB.teamName)) {
        // Team populate failed, use original ObjectId
        const teamBId = match.teamB?._id?.toString() || match.teamB?.toString() || match.teamB;
        match.teamB = teamBId;
      }
      
      return match;
    });

    return NextResponse.json(
      {
        message: "Matches retrieved successfully",
        data: matchesWithTeamIds,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("❌ Get matches error:", error);
    console.error("Error message:", error.message);
    console.error("Error stack:", error.stack);
    
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    
    return NextResponse.json(
      { 
        error: error.message || "Failed to get matches",
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      },
      { status: 500 }
    );
  }
}

/**
 * Get match by ID
 * GET /api/match/:id
 */
export async function getMatch(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const matchId = toObjectId(id);

    const match = await Match.findById(matchId)
      .populate("leagueId", "leagueName format startDate endDate logo")
      .populate("teamA", "teamName enterCode")
      .populate("teamB", "teamName enterCode")
      .populate("refereeId", "firstName lastName email role")
      .populate("statKeeperId", "firstName lastName email role")
      .lean()
      .exec();

    if (!match) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    // If team populate failed (team doesn't exist), include the original ObjectId
    const matchObj: any = match;
    if (!matchObj.teamA || (matchObj.teamA && !matchObj.teamA.teamName)) {
      // Team populate failed, use original ObjectId
      matchObj.teamA = matchObj.teamA?._id?.toString() || matchObj.teamA?.toString() || matchObj.teamA;
    }
    if (!matchObj.teamB || (matchObj.teamB && !matchObj.teamB.teamName)) {
      // Team populate failed, use original ObjectId
      matchObj.teamB = matchObj.teamB?._id?.toString() || matchObj.teamB?.toString() || matchObj.teamB;
    }

    return NextResponse.json(
      {
        message: "Match retrieved successfully",
        data: matchObj,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Get match error:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to get match" },
      { status: 500 }
    );
  }
}

/**
 * Update match
 * PUT /api/match/:id
 */
export async function updateMatch(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const matchId = toObjectId(id);

    const match = await Match.findById(matchId);
    if (!match) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    const {
      teamA,
      teamB,
      teamAName,
      teamBName,
      gameDate,
      gameTime,
      venue,
      refereeId,
      statKeeperId,
      roundName,
      gameNumber,
      status,
      homeScore,
      awayScore,
    } = await req.json();

    // Get league to validate date range
    const league = await League.findById((match as any).leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Update fields
    if (teamA !== undefined) {
      (match as any).teamA = toObjectId(teamA);
    }

    if (teamAName !== undefined) {
      (match as any).teamAName = teamAName || "";
    }

    if (teamB !== undefined) {
      (match as any).teamB = toObjectId(teamB);
    }

    if (teamBName !== undefined) {
      (match as any).teamBName = teamBName || "";
    }

    if (gameDate !== undefined) {
      const gameDateObj = new Date(gameDate);
      const leagueStart = new Date((league as any).startDate);
      const leagueEnd = new Date((league as any).endDate);

      if (gameDateObj < leagueStart || gameDateObj > leagueEnd) {
        return NextResponse.json(
          { error: "Game date must be within the league date range" },
          { status: 400 }
        );
      }
      (match as any).gameDate = gameDateObj;
    }

    if (gameTime !== undefined) {
      (match as any).gameTime = gameTime.trim();
    }

    if (venue !== undefined) {
      (match as any).venue = venue;
    }

    if (refereeId !== undefined) {
      (match as any).refereeId = refereeId ? toObjectId(refereeId) : null;
    }

    if (statKeeperId !== undefined) {
      (match as any).statKeeperId = statKeeperId ? toObjectId(statKeeperId) : null;
    }

    if (roundName !== undefined) {
      (match as any).roundName = roundName;
    }

    if (gameNumber !== undefined) {
      (match as any).gameNumber = gameNumber;
    }

    if (status !== undefined) {
      if (!["upcoming", "live", "completed", "cancelled"].includes(status)) {
        return NextResponse.json(
          { error: "Invalid status. Must be: upcoming, live, completed, or cancelled" },
          { status: 400 }
        );
      }
      (match as any).status = status;
    }

    if (homeScore !== undefined) {
      (match as any).homeScore = homeScore;
    }

    if (awayScore !== undefined) {
      (match as any).awayScore = awayScore;
    }

    await match.save();

    // Populate references
    await match.populate("leagueId", "leagueName format startDate endDate logo");
    await match.populate("teamA", "teamName enterCode");
    await match.populate("teamB", "teamName enterCode");
    if ((match as any).refereeId) {
      await match.populate("refereeId", "firstName lastName email role");
    }
    if ((match as any).statKeeperId) {
      await match.populate("statKeeperId", "firstName lastName email role");
    }

    // Convert to plain object and handle failed populates
    const matchObj = match.toObject();
    // Get original team IDs before populate
    const originalTeamA = (match as any).teamA?.toString();
    const originalTeamB = (match as any).teamB?.toString();
    
    if (!matchObj.teamA || (matchObj.teamA && !matchObj.teamA.teamName)) {
      // Team populate failed, use original ObjectId
      matchObj.teamA = matchObj.teamA?._id?.toString() || matchObj.teamA?.toString() || originalTeamA || teamA;
    }
    if (!matchObj.teamB || (matchObj.teamB && !matchObj.teamB.teamName)) {
      // Team populate failed, use original ObjectId
      matchObj.teamB = matchObj.teamB?._id?.toString() || matchObj.teamB?.toString() || originalTeamB || teamB;
    }

    return NextResponse.json(
      {
        message: "Match updated successfully",
        data: matchObj,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Update match error:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to update match" },
      { status: 500 }
    );
  }
}

