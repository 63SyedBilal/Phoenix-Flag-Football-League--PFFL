import { NextRequest, NextResponse } from "next/server";
import mongoose from "mongoose";
import { connectDB } from "@/lib/db";
import Match from "@/modules/match";
import League from "@/modules/league";
import Team from "@/modules/team";
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
    const user = await verifyUser(req);

    // Get user ID from token (superadmin who creates the match)
    const userId = (user as any).id || (user as any)._id || (user as any).userId;
    if (!userId) {
      return NextResponse.json(
        { error: "User ID not found in token" },
        { status: 401 }
      );
    }

    const {
      leagueId,
      teamA,
      teamB,
      format,
      gameDate,
      gameTime,
      venue,
      refereeId,
      statKeeperId,
      roundName,
      gameNumber,
      status,
      teamAInitialSide,
      teamBInitialSide,
    } = await req.json();

    // Validate required fields
    if (!leagueId || !teamA || !teamB || !gameDate || !gameTime || !format) {
      return NextResponse.json(
        { error: "League ID, Team A, Team B, Game Date, Game Time, and Format are required" },
        { status: 400 }
      );
    }

    // Validate format
    if (!["5v5", "7v7"].includes(format)) {
      return NextResponse.json(
        { error: "Format must be either '5v5' or '7v7'" },
        { status: 400 }
      );
    }

    // Convert IDs to ObjectId format
    let leagueObjectId: mongoose.Types.ObjectId;
    let teamAObjectId: mongoose.Types.ObjectId;
    let teamBObjectId: mongoose.Types.ObjectId;
    let createdByObjectId: mongoose.Types.ObjectId;

    try {
      leagueObjectId = toObjectId(leagueId);
      teamAObjectId = toObjectId(teamA);
      teamBObjectId = toObjectId(teamB);
      createdByObjectId = toObjectId(userId);
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
    if (status && !["upcoming", "live", "halfTime", "completed", "cancelled"].includes(status)) {
      return NextResponse.json(
        { error: "Invalid status. Must be: upcoming, live, halfTime, completed, or cancelled" },
        { status: 400 }
      );
    }

    // Validate initial sides
    const validSides = ["offense", "defense"];
    const teamASide = teamAInitialSide || "offense";
    const teamBSide = teamBInitialSide || "defense";

    if (!validSides.includes(teamASide) || !validSides.includes(teamBSide)) {
      return NextResponse.json(
        { error: "Initial side must be either 'offense' or 'defense'" },
        { status: 400 }
      );
    }

    // Build team match data
    const teamAData: any = {
      teamId: teamAObjectId,
      initialSide: teamASide,
      attendance: [],
      activePlayers: [],
      score: 0,
      playerPoints: [],
      result: null
    };

    const teamBData: any = {
      teamId: teamBObjectId,
      initialSide: teamBSide,
      attendance: [],
      activePlayers: [],
      score: 0,
      playerPoints: [],
      result: null
    };

    const matchData: any = {
      leagueId: leagueObjectId,
      createdBy: createdByObjectId,
      format: format,
      gameDate: gameDateObj,
      gameTime: gameTime.trim(),
      venue: venue || "",
      roundName: roundName || "Group Stage",
      gameNumber: gameNumber || "",
      status: status || "upcoming",
      teamA: teamAData,
      teamB: teamBData,
    };

    // Add optional referee and stat keeper
    if (refereeId) {
      matchData.refereeId = toObjectId(refereeId);
    }

    if (statKeeperId) {
      matchData.statKeeperId = toObjectId(statKeeperId);
    }

    const match = new Match(matchData);
    await match.save();

    // Populate references
    await match.populate("leagueId", "leagueName format startDate endDate");
    await match.populate("createdBy", "firstName lastName email role");
    await match.populate("teamA.teamId", "teamName enterCode");
    await match.populate("teamB.teamId", "teamName enterCode");
    if (match.refereeId) {
      await match.populate("refereeId", "firstName lastName email");
    }
    if (match.statKeeperId) {
      await match.populate("statKeeperId", "firstName lastName email");
    }
    if (match.gameWinnerTeam) {
      await match.populate("gameWinnerTeam", "teamName enterCode");
    }

    // Convert to plain object
    const matchObj = match.toObject();

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
      if (!["upcoming", "live", "halfTime", "completed", "cancelled"].includes(status)) {
        return NextResponse.json({ error: "Invalid status filter" }, { status: 400 });
      }
      query.status = status;
    }
    
    console.log("🔍 Query:", JSON.stringify(query));

    let matches;
    try {
      console.log("🔍 Fetching matches from database...");
      // Try with full populate, but catch errors gracefully
      matches = await Match.find(query)
        .populate("leagueId", "leagueName format startDate endDate logo")
        .populate("createdBy", "firstName lastName email role")
        .populate("teamA.teamId", "teamName enterCode image")
        .populate("teamB.teamId", "teamName enterCode image")
        .populate("teamA.attendance.playerId", "firstName lastName email")
        .populate("teamB.attendance.playerId", "firstName lastName email")
        .populate("teamA.activePlayers", "firstName lastName email")
        .populate("teamB.activePlayers", "firstName lastName email")
        .populate("teamA.playerPoints.playerId", "firstName lastName email")
        .populate("teamB.playerPoints.playerId", "firstName lastName email")
        .populate("refereeId", "firstName lastName email role")
        .populate("statKeeperId", "firstName lastName email role")
        .populate("gameWinnerTeam", "teamName enterCode")
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
        console.log("🔄 Retrying without populate (references might not exist)...");
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

    return NextResponse.json(
      {
        message: "Matches retrieved successfully",
        data: matches,
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
      .populate("createdBy", "firstName lastName email role")
      .populate("teamA.teamId", "teamName enterCode")
      .populate("teamB.teamId", "teamName enterCode")
      .populate("teamA.attendance.playerId", "firstName lastName email")
      .populate("teamB.attendance.playerId", "firstName lastName email")
      .populate("teamA.activePlayers", "firstName lastName email")
      .populate("teamB.activePlayers", "firstName lastName email")
      .populate("teamA.playerPoints.playerId", "firstName lastName email")
      .populate("teamB.playerPoints.playerId", "firstName lastName email")
      .populate("refereeId", "firstName lastName email role")
      .populate("statKeeperId", "firstName lastName email role")
      .populate("gameWinnerTeam", "teamName enterCode")
      .lean()
      .exec();

    if (!match) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    return NextResponse.json(
      {
        message: "Match retrieved successfully",
        data: match,
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
      format,
      gameDate,
      gameTime,
      venue,
      refereeId,
      statKeeperId,
      roundName,
      gameNumber,
      status,
      teamA,
      teamB,
      gameWinnerTeam,
      halfTimeSwitched,
      completedAt,
    } = await req.json();

    // Get league to validate date range
    const league = await League.findById((match as any).leagueId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Update fields
    if (format !== undefined) {
      if (!["5v5", "7v7"].includes(format)) {
        return NextResponse.json(
          { error: "Format must be either '5v5' or '7v7'" },
          { status: 400 }
        );
      }
      (match as any).format = format;
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
      if (!["upcoming", "live", "halfTime", "completed", "cancelled"].includes(status)) {
        return NextResponse.json(
          { error: "Invalid status. Must be: upcoming, live, halfTime, completed, or cancelled" },
          { status: 400 }
        );
      }
      (match as any).status = status;
      
      // Set completedAt when status is completed
      if (status === "completed" && !(match as any).completedAt) {
        (match as any).completedAt = new Date();
      }
    }

    if (gameWinnerTeam !== undefined) {
      (match as any).gameWinnerTeam = gameWinnerTeam ? toObjectId(gameWinnerTeam) : null;
    }

    if (halfTimeSwitched !== undefined) {
      (match as any).halfTimeSwitched = halfTimeSwitched;
    }

    if (completedAt !== undefined) {
      (match as any).completedAt = completedAt ? new Date(completedAt) : null;
    }

    // Update team data if provided
    if (teamA !== undefined) {
      if (typeof teamA === 'object') {
        // Update teamA fields
        if (teamA.teamId !== undefined) {
          (match as any).teamA.teamId = toObjectId(teamA.teamId);
        }
        if (teamA.initialSide !== undefined) {
          if (!["offense", "defense"].includes(teamA.initialSide)) {
            return NextResponse.json(
              { error: "Initial side must be either 'offense' or 'defense'" },
              { status: 400 }
            );
          }
          (match as any).teamA.initialSide = teamA.initialSide;
        }
        if (teamA.attendance !== undefined) {
          (match as any).teamA.attendance = teamA.attendance.map((att: any) => ({
            playerId: toObjectId(att.playerId),
            present: att.present !== undefined ? att.present : false
          }));
        }
        if (teamA.activePlayers !== undefined) {
          (match as any).teamA.activePlayers = teamA.activePlayers.map((id: string) => toObjectId(id));
        }
        if (teamA.score !== undefined) {
          (match as any).teamA.score = teamA.score;
        }
        if (teamA.playerPoints !== undefined) {
          (match as any).teamA.playerPoints = teamA.playerPoints.map((pp: any) => ({
            playerId: toObjectId(pp.playerId),
            points: pp.points || 0
          }));
        }
        if (teamA.result !== undefined) {
          if (teamA.result !== null && !["win", "loss", "draw"].includes(teamA.result)) {
            return NextResponse.json(
              { error: "Result must be 'win', 'loss', 'draw', or null" },
              { status: 400 }
            );
          }
          (match as any).teamA.result = teamA.result;
        }
      }
    }

    if (teamB !== undefined) {
      if (typeof teamB === 'object') {
        // Update teamB fields
        if (teamB.teamId !== undefined) {
          (match as any).teamB.teamId = toObjectId(teamB.teamId);
        }
        if (teamB.initialSide !== undefined) {
          if (!["offense", "defense"].includes(teamB.initialSide)) {
            return NextResponse.json(
              { error: "Initial side must be either 'offense' or 'defense'" },
              { status: 400 }
            );
          }
          (match as any).teamB.initialSide = teamB.initialSide;
        }
        if (teamB.attendance !== undefined) {
          (match as any).teamB.attendance = teamB.attendance.map((att: any) => ({
            playerId: toObjectId(att.playerId),
            present: att.present !== undefined ? att.present : false
          }));
        }
        if (teamB.activePlayers !== undefined) {
          (match as any).teamB.activePlayers = teamB.activePlayers.map((id: string) => toObjectId(id));
        }
        if (teamB.score !== undefined) {
          (match as any).teamB.score = teamB.score;
        }
        if (teamB.playerPoints !== undefined) {
          (match as any).teamB.playerPoints = teamB.playerPoints.map((pp: any) => ({
            playerId: toObjectId(pp.playerId),
            points: pp.points || 0
          }));
        }
        if (teamB.result !== undefined) {
          if (teamB.result !== null && !["win", "loss", "draw"].includes(teamB.result)) {
            return NextResponse.json(
              { error: "Result must be 'win', 'loss', 'draw', or null" },
              { status: 400 }
            );
          }
          (match as any).teamB.result = teamB.result;
        }
      }
    }

    await match.save();

    // Populate references
    await match.populate("leagueId", "leagueName format startDate endDate logo");
    await match.populate("createdBy", "firstName lastName email role");
    await match.populate("teamA.teamId", "teamName enterCode");
    await match.populate("teamB.teamId", "teamName enterCode");
    await match.populate("teamA.attendance.playerId", "firstName lastName email");
    await match.populate("teamB.attendance.playerId", "firstName lastName email");
    await match.populate("teamA.activePlayers", "firstName lastName email");
    await match.populate("teamB.activePlayers", "firstName lastName email");
    await match.populate("teamA.playerPoints.playerId", "firstName lastName email");
    await match.populate("teamB.playerPoints.playerId", "firstName lastName email");
    if ((match as any).refereeId) {
      await match.populate("refereeId", "firstName lastName email role");
    }
    if ((match as any).statKeeperId) {
      await match.populate("statKeeperId", "firstName lastName email role");
    }
    if ((match as any).gameWinnerTeam) {
      await match.populate("gameWinnerTeam", "teamName enterCode");
    }

    // Convert to plain object
    const matchObj = match.toObject();

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

