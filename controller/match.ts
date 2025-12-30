import { NextRequest, NextResponse } from "next/server";
import mongoose from "mongoose";
import { connectDB } from "@/lib/db";
import Match from "@/modules/match";
import League from "@/modules/league";
import Team from "@/modules/team";
import User from "@/modules/user";
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

function toPlainStringId(value: any): string | null {
  if (!value) return null;
  if (typeof value === "string") return value;
  if (value instanceof mongoose.Types.ObjectId) return value.toString();
  if (typeof value === "object" && value._id) {
    return value._id.toString();
  }
  if (typeof value === "object" && value.toString) {
    return value.toString();
  }
  return null;
}

function toMatchDTO(match: any) {
  if (!match) return match;

  const dto: any = { ...match };

  const teamAData = match.teamA ?? {};
  const teamBData = match.teamB ?? {};
  const teamARef = teamAData.teamId ?? null;
  const teamBRef = teamBData.teamId ?? null;

  const homeTeamId = toPlainStringId(teamARef);
  const awayTeamId = toPlainStringId(teamBRef);

  const resolvedHomeName =
    match.teamAName ??
    (typeof teamARef === "object"
      ? teamARef.teamName ?? teamARef.enterCode
      : null);
  const resolvedAwayName =
    match.teamBName ??
    (typeof teamBRef === "object"
      ? teamBRef.teamName ?? teamBRef.enterCode
      : null);

  const homeTeam = resolvedHomeName && resolvedHomeName.length > 0
    ? resolvedHomeName
    : "Unknown Team";
  const awayTeam = resolvedAwayName && resolvedAwayName.length > 0
    ? resolvedAwayName
    : "Unknown Team";

  const homeTeamLogo =
    (typeof teamARef === "object" && teamARef?.image) ? teamARef.image : "";
  const awayTeamLogo =
    (typeof teamBRef === "object" && teamBRef?.image) ? teamBRef.image : "";

  dto._id = toPlainStringId(match._id) ?? match._id;
  dto.id = dto._id;
  dto.leagueId =
    toPlainStringId(match.leagueId?._id ?? match.leagueId) ?? match.leagueId;
  dto.leagueName =
    match.leagueId?.leagueName ?? match.leagueName ?? "";

  dto.homeTeamId = homeTeamId;
  dto.awayTeamId = awayTeamId;
  dto.homeTeam = homeTeam;
  dto.awayTeam = awayTeam;
  dto.homeTeamLogo = homeTeamLogo;
  dto.awayTeamLogo = awayTeamLogo;
  dto.teamAName = homeTeam;
  dto.teamBName = awayTeam;

  // Ensure scores exist at root for frontend parsing
  dto.homeScore =
    match.teamA?.score ?? match.homeScore ?? 0;
  dto.awayScore =
    match.teamB?.score ?? match.awayScore ?? 0;

  // Merge player actions into a unified timeline
  const actions: any[] = [];
  if (match.teamA?.playerActions) {
    match.teamA.playerActions.forEach((a: any) => {
      actions.push({
        ...a,
        teamId: homeTeamId,
        teamName: homeTeam,
        isHome: true
      });
    });
  }
  if (match.teamB?.playerActions) {
    match.teamB.playerActions.forEach((a: any) => {
      actions.push({
        ...a,
        teamId: awayTeamId,
        teamName: awayTeam,
        isHome: false
      });
    });
  }

  // Sort actions by timestamp
  actions.sort((a, b) => {
    const timeA = new Date(a.timestamp || 0).getTime();
    const timeB = new Date(b.timestamp || 0).getTime();
    return timeA - timeB;
  });

  dto.actions = actions;

  return dto;
}

/**
 * Create a new match
 * POST /api/match
 */
export async function createMatch(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    // Get user ID from token (superadmin who creates the match)
    const userId = (decoded as any).id || (decoded as any)._id || (decoded as any).userId;
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

    // Validate status enum - only allow "upcoming" when creating a match
    if (status && status !== "upcoming") {
      return NextResponse.json(
        { error: "Status must be 'upcoming' when creating a match. Game will start automatically when first action is added." },
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

    // Build team match data - following exact schema structure from modules/match.ts
    const teamAData: any = {
      teamId: teamAObjectId,
      side: teamASide,
      players: [], // Array of { playerId: ObjectId, isActive: Boolean }
      playerActions: [], // Array of { playerId: ObjectId, actionType: String, timestamp: Date }
      playerStats: [], // Array of PlayerStatsSchema
      teamStats: {}, // TeamStatsSchema object with default values
      score: 0,
      win: null // Boolean, default: null (matches schema)
    };

    const teamBData: any = {
      teamId: teamBObjectId,
      side: teamBSide,
      players: [], // Array of { playerId: ObjectId, isActive: Boolean }
      playerActions: [], // Array of { playerId: ObjectId, actionType: String, timestamp: Date }
      playerStats: [], // Array of PlayerStatsSchema
      teamStats: {}, // TeamStatsSchema object with default values
      score: 0,
      win: null // Boolean, default: null (matches schema)
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

    // Get sender ID from token (admin who created the match)
    const senderId = toObjectId(userId);
    const matchObjectId = (match as any)._id;

    // 🎮 LOG GAME CREATION INFORMATION
    console.log("🎮 [GAME CREATED] ================================");
    console.log("🎮 [GAME CREATED] Game successfully created!");
    console.log("🎮 [GAME CREATED] Match ID:", matchObjectId.toString());
    console.log("🎮 [GAME CREATED] League ID:", leagueObjectId.toString());
    console.log("🎮 [GAME CREATED] League Name:", league.leagueName);
    console.log("🎮 [GAME CREATED] Team A ID:", teamAObjectId.toString());
    console.log("🎮 [GAME CREATED] Team B ID:", teamBObjectId.toString());
    console.log("🎮 [GAME CREATED] Format:", format);
    console.log("🎮 [GAME CREATED] Game Date:", gameDateObj.toISOString());
    console.log("🎮 [GAME CREATED] Game Time:", gameTime);
    console.log("🎮 [GAME CREATED] Venue:", venue || "No venue specified");
    console.log("🎮 [GAME CREATED] Round Name:", roundName || "Group Stage");
    console.log("🎮 [GAME CREATED] Status:", status || "upcoming");
    console.log("🎮 [GAME CREATED] Team A Initial Side:", teamASide);
    console.log("🎮 [GAME CREATED] Team B Initial Side:", teamBSide);
    console.log("🎮 [GAME CREATED] Created By (Admin ID):", createdByObjectId.toString());

    if (refereeId) {
      console.log("🎮 [GAME CREATED] Referee Assigned:", refereeId);
    } else {
      console.log("🎮 [GAME CREATED] No referee assigned");
    }

    if (statKeeperId) {
      console.log("🎮 [GAME CREATED] Stat Keeper Assigned:", statKeeperId);
    } else {
      console.log("🎮 [GAME CREATED] No stat keeper assigned");
    }

    console.log("🎮 [GAME CREATED] ================================");

    // Create notifications for assigned referee and stat keeper
    const notifications = [];
    console.log("🔔 [MATCH CREATION] Starting notification creation process...");
    console.log("🔔 [MATCH CREATION] RefereeId:", refereeId);
    console.log("🔔 [MATCH CREATION] StatKeeperId:", statKeeperId);
    console.log("🔔 [MATCH CREATION] MatchId:", matchObjectId.toString());
    console.log("🔔 [MATCH CREATION] LeagueId:", leagueObjectId.toString());
    console.log("🔔 [MATCH CREATION] SenderId:", senderId.toString());

    // Create notification for referee if assigned
    if (refereeId) {
      try {
        const refereeObjectId = toObjectId(refereeId);
        console.log("🔔 [REFEREE NOTIFICATION] Creating notification for referee:", refereeObjectId.toString());

        // Verify the referee user exists
        const refereeUser = await User.findById(refereeObjectId);
        if (!refereeUser) {
          console.error("❌ [REFEREE NOTIFICATION] Referee user not found in database:", refereeObjectId.toString());
          console.error("❌ [REFEREE NOTIFICATION] This means the admin panel passed an invalid user ID");
        } else {
          console.log("✅ [REFEREE NOTIFICATION] Referee user verified:", {
            id: refereeUser._id.toString(),
            email: refereeUser.email,
            role: refereeUser.role,
            firstName: refereeUser.firstName,
            lastName: refereeUser.lastName
          });
        }

        console.log("🔔 [REFEREE NOTIFICATION] Notification data:", {
          sender: senderId.toString(),
          receiver: refereeObjectId.toString(),
          league: leagueObjectId.toString(),
          match: matchObjectId.toString(),
          type: "GAME_ASSIGNED",
          status: "pending"
        });

        const refereeNotification = await Notification.create({
          sender: senderId,
          receiver: refereeObjectId,
          league: leagueObjectId,
          match: matchObjectId,
          type: "GAME_ASSIGNED",
          status: "pending"
        });

        notifications.push(refereeNotification);
        console.log("✅ [REFEREE NOTIFICATION] Notification created successfully:", {
          notificationId: refereeNotification._id.toString(),
          refereeId: refereeId,
          matchId: matchObjectId.toString(),
          leagueId: leagueObjectId.toString(),
          senderId: senderId.toString(),
          type: "GAME_ASSIGNED",
          status: "pending"
        });

        // Verify the notification was saved correctly
        const savedNotification = await Notification.findById(refereeNotification._id);
        if (savedNotification) {
          console.log("✅ [REFEREE NOTIFICATION] Verification - notification exists in database:", {
            id: savedNotification._id.toString(),
            receiver: savedNotification.receiver.toString(),
            match: savedNotification.match?.toString() || "null",
            league: savedNotification.league?.toString() || "null",
            type: savedNotification.type,
            status: savedNotification.status
          });
        } else {
          console.error("❌ [REFEREE NOTIFICATION] Verification failed - notification not found in database");
        }
      } catch (error: any) {
        console.error("❌ [REFEREE NOTIFICATION] Error creating notification for referee:", error);
        console.error("❌ [REFEREE NOTIFICATION] Error details:", {
          refereeId,
          matchId: matchObjectId.toString(),
          leagueId: leagueObjectId.toString(),
          senderId: senderId.toString(),
          errorMessage: error.message,
          errorStack: error.stack
        });
        // Don't fail match creation if notification fails
      }
    } else {
      console.log("⏭️ [REFEREE NOTIFICATION] No referee assigned, skipping notification");
    }

    // Create notification for stat keeper if assigned
    if (statKeeperId) {
      try {
        const statKeeperObjectId = toObjectId(statKeeperId);
        console.log("🔔 [STATKEEPER NOTIFICATION] Creating notification for stat keeper:", statKeeperObjectId.toString());

        // Verify the stat keeper user exists
        const statKeeperUser = await User.findById(statKeeperObjectId);
        if (!statKeeperUser) {
          console.error("❌ [STATKEEPER NOTIFICATION] Stat keeper user not found in database:", statKeeperObjectId.toString());
          console.error("❌ [STATKEEPER NOTIFICATION] This means the admin panel passed an invalid user ID");

          // Try to find the user by email to help debug
          const statKeeperByEmail = await User.findOne({ email: "statkeeper1@gmail.com" });
          if (statKeeperByEmail) {
            console.log("🔍 [STATKEEPER NOTIFICATION] Found statkeeper1@gmail.com in database:", {
              correctId: statKeeperByEmail._id.toString(),
              passedId: statKeeperObjectId.toString(),
              email: statKeeperByEmail.email,
              role: statKeeperByEmail.role
            });
            console.error("❌ [STATKEEPER NOTIFICATION] ID MISMATCH! Admin panel passed wrong ID");
          } else {
            console.error("❌ [STATKEEPER NOTIFICATION] statkeeper1@gmail.com not found in database at all");
          }
        } else {
          console.log("✅ [STATKEEPER NOTIFICATION] Stat keeper user verified:", {
            id: statKeeperUser._id.toString(),
            email: statKeeperUser.email,
            role: statKeeperUser.role,
            firstName: statKeeperUser.firstName,
            lastName: statKeeperUser.lastName
          });
        }

        console.log("🔔 [STATKEEPER NOTIFICATION] Notification data:", {
          sender: senderId.toString(),
          receiver: statKeeperObjectId.toString(),
          league: leagueObjectId.toString(),
          match: matchObjectId.toString(),
          type: "GAME_ASSIGNED",
          status: "pending"
        });

        const statKeeperNotification = await Notification.create({
          sender: senderId,
          receiver: statKeeperObjectId,
          league: leagueObjectId,
          match: matchObjectId,
          type: "GAME_ASSIGNED",
          status: "pending"
        });

        notifications.push(statKeeperNotification);
        console.log("✅ [STATKEEPER NOTIFICATION] Notification created successfully:", {
          notificationId: statKeeperNotification._id.toString(),
          statKeeperId: statKeeperId,
          matchId: matchObjectId.toString(),
          leagueId: leagueObjectId.toString(),
          senderId: senderId.toString(),
          type: "GAME_ASSIGNED",
          status: "pending"
        });

        // Verify the notification was saved correctly
        const savedNotification = await Notification.findById(statKeeperNotification._id);
        if (savedNotification) {
          console.log("✅ [STATKEEPER NOTIFICATION] Verification - notification exists in database:", {
            id: savedNotification._id.toString(),
            receiver: savedNotification.receiver.toString(),
            match: savedNotification.match?.toString() || "null",
            league: savedNotification.league?.toString() || "null",
            type: savedNotification.type,
            status: savedNotification.status
          });
        } else {
          console.error("❌ [STATKEEPER NOTIFICATION] Verification failed - notification not found in database");
        }
      } catch (error: any) {
        console.error("❌ [STATKEEPER NOTIFICATION] Error creating notification for stat keeper:", error);
        console.error("❌ [STATKEEPER NOTIFICATION] Error details:", {
          statKeeperId,
          matchId: matchObjectId.toString(),
          leagueId: leagueObjectId.toString(),
          senderId: senderId.toString(),
          errorMessage: error.message,
          errorStack: error.stack
        });
        // Don't fail match creation if notification fails
      }
    } else {
      console.log("⏭️ [STATKEEPER NOTIFICATION] No stat keeper assigned, skipping notification");
    }

    console.log("🔔 [MATCH CREATION] Notification creation process completed. Created:", notifications.length, "notifications");

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
      if (!["upcoming", "continue", "completed"].includes(status)) {
        return NextResponse.json({ error: "Invalid status filter. Must be: upcoming, continue, or completed" }, { status: 400 });
      }
      query.status = status;
    }

    console.log("🔍 Query:", JSON.stringify(query));

    const matches = await Match.find(query)
      .populate("leagueId", "leagueName format startDate endDate logo")
      .populate("teamA.teamId", "teamName enterCode image")
      .populate("teamB.teamId", "teamName enterCode image")
      .populate("refereeId", "_id")
      .populate("statKeeperId", "_id")
      .sort({ gameDate: 1, gameTime: 1 })
      .lean()
      .exec();
    console.log(`✅ Found ${matches.length} matches`);

    const matchesWithTeamIds = matches.map((match: any) => {
      const dto = toMatchDTO(match);
      if (match.refereeId) {
        dto.refereeIdRaw = toPlainStringId(match.refereeId);
      }
      if (match.statKeeperId) {
        dto.statKeeperIdRaw = toPlainStringId(match.statKeeperId);
      }
      return dto;
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
      .populate("teamA.teamId", "teamName enterCode image")
      .populate("teamB.teamId", "teamName enterCode image")
      .populate("teamA.players.playerId", "firstName lastName email profileImage position")
      .populate("teamB.players.playerId", "firstName lastName email profileImage position")
      .populate("teamA.playerStats.playerId", "firstName lastName email profileImage position")
      .populate("teamB.playerStats.playerId", "firstName lastName email profileImage position")
      .populate("teamA.playerActions.playerId", "firstName lastName email")
      .populate("teamB.playerActions.playerId", "firstName lastName email")
      .populate("refereeId", "_id")
      .populate("statKeeperId", "_id")
      .populate("gameWinnerTeam", "teamName enterCode")
      .lean()
      .exec();

    if (!match) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    return NextResponse.json(
      {
        message: "Match retrieved successfully",
        data: toMatchDTO(match),
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
      timesSwitched,
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

    // Only allow status to be set to "completed" via updateMatch
    // Status changes to "continue" automatically when first action is added
    if (status !== undefined) {
      if (status !== "completed") {
        return NextResponse.json(
          { error: "Status can only be set to 'completed' via this endpoint. Use game actions to start the game." },
          { status: 400 }
        );
      }
      (match as any).status = "completed";

      // Set completedAt when status is completed
      if (!(match as any).completedAt) {
        (match as any).completedAt = new Date();
      }

      // Calculate winner based on scores
      const teamAScore = (match as any).teamA.score || 0;
      const teamBScore = (match as any).teamB.score || 0;
      const teamATeamId = (match as any).teamA.teamId;
      const teamBTeamId = (match as any).teamB.teamId;

      if (teamAScore > teamBScore) {
        // Team A wins
        (match as any).gameWinnerTeam = teamATeamId;
        (match as any).teamA.win = true;
        (match as any).teamB.win = false;
      } else if (teamBScore > teamAScore) {
        // Team B wins
        (match as any).gameWinnerTeam = teamBTeamId;
        (match as any).teamA.win = false;
        (match as any).teamB.win = true;
      } else {
        // Tie game
        (match as any).gameWinnerTeam = null;
        (match as any).teamA.win = null;
        (match as any).teamB.win = null;
      }

      // Mark as modified to ensure changes are saved
      (match as any).markModified("teamA.win");
      (match as any).markModified("teamB.win");
    }

    if (gameWinnerTeam !== undefined) {
      (match as any).gameWinnerTeam = gameWinnerTeam ? toObjectId(gameWinnerTeam) : null;
    }

    if (timesSwitched !== undefined) {
      if (timesSwitched !== null && !["halfTime", "fullTime", "overtime"].includes(timesSwitched)) {
        return NextResponse.json(
          { error: "timesSwitched must be 'halfTime', 'fullTime', 'overtime', or null" },
          { status: 400 }
        );
      }
      (match as any).timesSwitched = timesSwitched;
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
        if (teamA.side !== undefined) {
          if (!["offense", "defense"].includes(teamA.side)) {
            return NextResponse.json(
              { error: "Side must be either 'offense' or 'defense'" },
              { status: 400 }
            );
          }
          (match as any).teamA.side = teamA.side;
        }
        if (teamA.players !== undefined) {
          (match as any).teamA.players = teamA.players.map((p: any) => ({
            playerId: toObjectId(p.playerId),
            isActive: p.isActive !== undefined ? p.isActive : false
          }));
        }
        if (teamA.playerStats !== undefined) {
          (match as any).teamA.playerStats = teamA.playerStats.map((ps: any) => ({
            playerId: toObjectId(ps.playerId),
            catches: ps.catches || 0,
            catchYards: ps.catchYards || 0,
            rushes: ps.rushes || 0,
            rushYards: ps.rushYards || 0,
            touchdowns: ps.touchdowns || 0,
            extraPoints: ps.extraPoints || 0,
            defensiveTDs: ps.defensiveTDs || 0,
            safeties: ps.safeties || 0,
            flags: ps.flags || 0,
            totalPoints: ps.totalPoints || 0
          }));
        }
        if (teamA.teamStats !== undefined) {
          (match as any).teamA.teamStats = teamA.teamStats;
        }
        if (teamA.score !== undefined) {
          (match as any).teamA.score = teamA.score;
        }
        if (teamA.win !== undefined) {
          if (teamA.win !== null && typeof teamA.win !== "boolean") {
            return NextResponse.json(
              { error: "Win must be a boolean (true for win, false for loss) or null" },
              { status: 400 }
            );
          }
          (match as any).teamA.win = teamA.win;
        }
      }
    }

    if (teamB !== undefined) {
      if (typeof teamB === 'object') {
        // Update teamB fields
        if (teamB.teamId !== undefined) {
          (match as any).teamB.teamId = toObjectId(teamB.teamId);
        }
        if (teamB.side !== undefined) {
          if (!["offense", "defense"].includes(teamB.side)) {
            return NextResponse.json(
              { error: "Side must be either 'offense' or 'defense'" },
              { status: 400 }
            );
          }
          (match as any).teamB.side = teamB.side;
        }
        if (teamB.players !== undefined) {
          (match as any).teamB.players = teamB.players.map((p: any) => ({
            playerId: toObjectId(p.playerId),
            isActive: p.isActive !== undefined ? p.isActive : false
          }));
        }
        if (teamB.playerStats !== undefined) {
          (match as any).teamB.playerStats = teamB.playerStats.map((ps: any) => ({
            playerId: toObjectId(ps.playerId),
            catches: ps.catches || 0,
            catchYards: ps.catchYards || 0,
            rushes: ps.rushes || 0,
            rushYards: ps.rushYards || 0,
            touchdowns: ps.touchdowns || 0,
            extraPoints: ps.extraPoints || 0,
            defensiveTDs: ps.defensiveTDs || 0,
            safeties: ps.safeties || 0,
            flags: ps.flags || 0,
            totalPoints: ps.totalPoints || 0
          }));
        }
        if (teamB.teamStats !== undefined) {
          (match as any).teamB.teamStats = teamB.teamStats;
        }
        if (teamB.score !== undefined) {
          (match as any).teamB.score = teamB.score;
        }
        if (teamB.win !== undefined) {
          if (teamB.win !== null && typeof teamB.win !== "boolean") {
            return NextResponse.json(
              { error: "Win must be a boolean (true for win, false for loss) or null" },
              { status: 400 }
            );
          }
          (match as any).teamB.win = teamB.win;
        }
      }
    }

    await match.save();

    // Check tournament progression if this was a league match completion
    if (status === "completed" && (match as any).matchType === "league") {
      try {
        const { checkTournamentProgression } = await import("@/controller/tournament");
        await checkTournamentProgression((match as any).leagueId.toString());
      } catch (progressionError) {
        console.error("Error checking tournament progression:", progressionError);
        // Don't fail the match update if progression check fails
      }
    }

    // Populate references
    await match.populate("leagueId", "leagueName format startDate endDate logo");
    await match.populate("createdBy", "firstName lastName email role");
    await match.populate("teamA.teamId", "teamName enterCode");
    await match.populate("teamB.teamId", "teamName enterCode");
    await match.populate("teamA.players.playerId", "firstName lastName email");
    await match.populate("teamB.players.playerId", "firstName lastName email");
    await match.populate("teamA.playerStats.playerId", "firstName lastName email");
    await match.populate("teamB.playerStats.playerId", "firstName lastName email");
    await match.populate("teamA.playerActions.playerId", "firstName lastName email");
    await match.populate("teamB.playerActions.playerId", "firstName lastName email");
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

/**
 * Add game action
 * POST /api/match/:id/action
 */
const ACTION_SCORES: { [key: string]: number } = {
  "Touchdown": 6,
  "Extra Point from 5-yard line": 1,
  "Extra Point from 12-yard line": 2,
  "Extra Point from 20-yard line": 2,
  "Defensive Touchdown": 6,
  "Extra Point Return only": 4,
  "Safety": 2
};

function getActionScore(actionType: string): number {
  return ACTION_SCORES[actionType] || 0;
}

export async function addGameAction(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const matchId = toObjectId(id);

    const { teamId, playerId, actionType, quarter } = await req.json();

    // Validate required fields
    if (!teamId || !playerId || !actionType) {
      return NextResponse.json(
        { error: "Team ID, Player ID, and Action Type are required" },
        { status: 400 }
      );
    }

    // Validate action type
    const validActionTypes = [
      "Touchdown",
      "Extra Point from 5-yard line",
      "Extra Point from 12-yard line",
      "Extra Point from 20-yard line",
      "Defensive Touchdown",
      "Extra Point Return only",
      "Safety"
    ];

    if (!validActionTypes.includes(actionType)) {
      return NextResponse.json(
        { error: "Invalid action type" },
        { status: 400 }
      );
    }

    // Get match
    const match = await Match.findById(matchId);
    if (!match) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    // Determine which team (A or B)
    const teamAId = (match as any).teamA.teamId.toString();
    const teamBId = (match as any).teamB.teamId.toString();
    const isTeamA = teamId === teamAId;

    if (!isTeamA && teamId !== teamBId) {
      return NextResponse.json(
        { error: "Team ID does not match either team in the match" },
        { status: 400 }
      );
    }

    const team = isTeamA ? (match as any).teamA : (match as any).teamB;
    const playerObjectId = toObjectId(playerId);

    // Calculate score for this action
    const actionScore = getActionScore(actionType);

    // Add action to playerActions array
    const newAction = {
      playerId: playerObjectId,
      actionType: actionType,
      timestamp: new Date(),
      quarter: quarter || "1"
    };

    // Ensure playerActions is an array
    if (!Array.isArray(team.playerActions)) {
      team.playerActions = [];
    }
    team.playerActions.push(newAction);

    // Mark the array as modified for Mongoose
    (match as any).markModified(isTeamA ? "teamA.playerActions" : "teamB.playerActions");

    // Update team score
    team.score = (team.score || 0) + actionScore;

    // Update player stats
    let playerStat = team.playerStats.find((ps: any) =>
      ps.playerId.toString() === playerId
    );

    if (!playerStat) {
      playerStat = {
        playerId: playerObjectId,
        catches: 0,
        catchYards: 0,
        rushes: 0,
        rushYards: 0,
        touchdowns: 0,
        extraPoints: 0,
        defensiveTDs: 0,
        safeties: 0,
        flags: 0,
        totalPoints: 0
      };
      team.playerStats.push(playerStat);
    }

    // Update stats based on action type
    if (actionType === "Touchdown") {
      playerStat.touchdowns = (playerStat.touchdowns || 0) + 1;
      playerStat.totalPoints = (playerStat.totalPoints || 0) + actionScore;
    } else if (actionType === "Defensive Touchdown") {
      playerStat.defensiveTDs = (playerStat.defensiveTDs || 0) + 1;
      playerStat.totalPoints = (playerStat.totalPoints || 0) + actionScore;
    } else if (actionType.includes("Extra Point")) {
      playerStat.extraPoints = (playerStat.extraPoints || 0) + 1;
      playerStat.totalPoints = (playerStat.totalPoints || 0) + actionScore;
    } else if (actionType === "Safety") {
      playerStat.safeties = (playerStat.safeties || 0) + 1;
      playerStat.totalPoints = (playerStat.totalPoints || 0) + actionScore;
    }

    // Update team stats
    if (!team.teamStats) {
      team.teamStats = {};
    }

    if (actionType === "Touchdown") {
      team.teamStats.touchdowns = (team.teamStats.touchdowns || 0) + 1;
    } else if (actionType === "Defensive Touchdown") {
      team.teamStats.defensiveTDs = (team.teamStats.defensiveTDs || 0) + 1;
    } else if (actionType.includes("Extra Point")) {
      team.teamStats.extraPoints = (team.teamStats.extraPoints || 0) + 1;
    } else if (actionType === "Safety") {
      team.teamStats.safeties = (team.teamStats.safeties || 0) + 1;
    }

    team.teamStats.totalPoints = (team.teamStats.totalPoints || 0) + actionScore;

    // Mark as modified
    (match as any).markModified(isTeamA ? "teamA.playerStats" : "teamB.playerStats");
    (match as any).markModified(isTeamA ? "teamA.teamStats" : "teamB.teamStats");

    // Set status to "continue" if it's still "upcoming" (first action)
    if ((match as any).status === "upcoming") {
      (match as any).status = "continue";
    }

    await match.save();

    // Populate and return
    await match.populate("leagueId", "leagueName format startDate endDate logo");
    await match.populate("createdBy", "firstName lastName email role");
    await match.populate("teamA.teamId", "teamName enterCode");
    await match.populate("teamB.teamId", "teamName enterCode");
    await match.populate("teamA.players.playerId", "firstName lastName email");
    await match.populate("teamB.players.playerId", "firstName lastName email");
    await match.populate("teamA.playerStats.playerId", "firstName lastName email");
    await match.populate("teamB.playerStats.playerId", "firstName lastName email");
    await match.populate("teamA.playerActions.playerId", "firstName lastName email");
    await match.populate("teamB.playerActions.playerId", "firstName lastName email");
    await match.populate("refereeId", "firstName lastName email role");
    await match.populate("statKeeperId", "firstName lastName email role");
    await match.populate("gameWinnerTeam", "teamName enterCode");

    return NextResponse.json(
      {
        message: "Action added successfully",
        data: match,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Add game action error:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to add action" },
      { status: 500 }
    );
  }
}

/**
 * Switch half time - swap sides and set timesSwitched to halfTime
 * POST /api/match/:id/halftime
 */
export async function switchHalfTime(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const matchId = toObjectId(id);

    // Get match - use lean() to check structure
    const existingMatch = await Match.findById(matchId).lean();
    if (!existingMatch) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    const teamA = (existingMatch as any).teamA;
    const teamB = (existingMatch as any).teamB;

    // Check if teamA/teamB are ObjectIds (old format) or objects (new format)
    const isTeamAObjectId = teamA && (teamA.buffer !== undefined || (typeof teamA === 'object' && !teamA.teamId && !teamA.teamName && !teamA.side));
    const isTeamBObjectId = teamB && (teamB.buffer !== undefined || (typeof teamB === 'object' && !teamB.teamId && !teamB.teamName && !teamB.side));

    let teamASide: string;
    let teamBSide: string;

    if (isTeamAObjectId || isTeamBObjectId) {
      // Old format - can't swap sides, need to restructure first
      return NextResponse.json(
        { error: "Match structure is invalid. Please complete the toss first to initialize team sides." },
        { status: 400 }
      );
    } else {
      // New format - get current sides
      teamASide = teamA?.side || "offense";
      teamBSide = teamB?.side || "defense";
    }

    const newTeamASide = teamASide === "offense" ? "defense" : "offense";
    const newTeamBSide = teamBSide === "offense" ? "defense" : "offense";

    // Update only the fields we're changing (sides and timesSwitched)
    // Using updateOne to avoid validating the entire document (status might be invalid)
    await Match.updateOne(
      { _id: matchId },
      {
        $set: {
          "teamA.side": newTeamASide,
          "teamB.side": newTeamBSide,
          timesSwitched: "halfTime"
        }
      }
    );

    // Reload the match to get updated data
    const updatedMatch = await Match.findById(matchId);
    if (!updatedMatch) {
      return NextResponse.json({ error: "Match not found after update" }, { status: 404 });
    }

    // Populate and return
    await updatedMatch.populate("leagueId", "leagueName format startDate endDate logo");
    await updatedMatch.populate("createdBy", "firstName lastName email role");
    await updatedMatch.populate("teamA.teamId", "teamName enterCode");
    await updatedMatch.populate("teamB.teamId", "teamName enterCode");
    await updatedMatch.populate("teamA.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("refereeId", "firstName lastName email role");
    await updatedMatch.populate("statKeeperId", "firstName lastName email role");
    await updatedMatch.populate("gameWinnerTeam", "teamName enterCode");

    return NextResponse.json(
      {
        message: "Half time switched successfully",
        data: updatedMatch,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Switch half time error:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to switch half time" },
      { status: 500 }
    );
  }
}

/**
 * Switch full time - swap sides again and set timesSwitched to fullTime
 * POST /api/match/:id/fulltime
 * This swaps the team sides a second time and sets the match to full time
 * Note: This function does NOT modify the match status field
 */
export async function switchFullTime(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const matchId = toObjectId(id);

    // Get match - use lean() to check structure
    const existingMatch = await Match.findById(matchId).lean();
    if (!existingMatch) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    const teamA = (existingMatch as any).teamA;
    const teamB = (existingMatch as any).teamB;

    // Check if teamA/teamB are ObjectIds (old format) or objects (new format)
    const isTeamAObjectId = teamA && (teamA.buffer !== undefined || (typeof teamA === 'object' && !teamA.teamId && !teamA.teamName && !teamA.side));
    const isTeamBObjectId = teamB && (teamB.buffer !== undefined || (typeof teamB === 'object' && !teamB.teamId && !teamB.teamName && !teamB.side));

    let teamASide: string;
    let teamBSide: string;

    if (isTeamAObjectId || isTeamBObjectId) {
      // Old format - can't swap sides, need to restructure first
      return NextResponse.json(
        { error: "Match structure is invalid. Please complete the toss first to initialize team sides." },
        { status: 400 }
      );
    } else {
      // New format - get current sides
      teamASide = teamA?.side || "offense";
      teamBSide = teamB?.side || "defense";
    }

    const newTeamASide = teamASide === "offense" ? "defense" : "offense";
    const newTeamBSide = teamBSide === "offense" ? "defense" : "offense";

    // Update only the fields we're changing (sides and timesSwitched)
    // Using updateOne to avoid validating the entire document (status might be invalid)
    await Match.updateOne(
      { _id: matchId },
      {
        $set: {
          "teamA.side": newTeamASide,
          "teamB.side": newTeamBSide,
          timesSwitched: "fullTime"
        }
      }
    );

    // Reload the match to get updated data
    const updatedMatch = await Match.findById(matchId);
    if (!updatedMatch) {
      return NextResponse.json({ error: "Match not found after update" }, { status: 404 });
    }

    // Populate and return
    await updatedMatch.populate("leagueId", "leagueName format startDate endDate logo");
    await updatedMatch.populate("createdBy", "firstName lastName email role");
    await updatedMatch.populate("teamA.teamId", "teamName enterCode");
    await updatedMatch.populate("teamB.teamId", "teamName enterCode");
    await updatedMatch.populate("teamA.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("refereeId", "firstName lastName email role");
    await updatedMatch.populate("statKeeperId", "firstName lastName email role");
    await updatedMatch.populate("gameWinnerTeam", "teamName enterCode");

    return NextResponse.json(
      {
        message: "Full time switched successfully",
        data: updatedMatch,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Switch full time error:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to switch full time" },
      { status: 500 }
    );
  }
}

/**
 * Complete toss - set team sides based on toss winner and decision
 * POST /api/match/:id/toss
 * Body: { winnerTeamId: string, winnerSide: "offense" | "defense" }
 * Sets the winner team's side and opposite side for the other team
 * Updates status from "upcoming" to "continue"
 */
export async function completeToss(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const matchId = toObjectId(id);

    // Get request body
    const { winnerTeamId, winnerSide } = await req.json();

    // Validate required fields
    if (!winnerTeamId || !winnerSide) {
      return NextResponse.json(
        { error: "winnerTeamId and winnerSide are required" },
        { status: 400 }
      );
    }

    // Validate winnerSide
    if (!["offense", "defense"].includes(winnerSide)) {
      return NextResponse.json(
        { error: "winnerSide must be either 'offense' or 'defense'" },
        { status: 400 }
      );
    }

    // Get match - use lean() to get plain object with raw ObjectIds (not populated)
    const existingMatch = await Match.findById(matchId).lean();

    if (!existingMatch) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    // Use the lean object directly
    const matchObj = existingMatch;

    // Safely get team IDs - handle both ObjectId and object formats
    const teamA = (matchObj as any).teamA;
    const teamB = (matchObj as any).teamB;

    if (!teamA || !teamB) {
      console.error("❌ Match team data missing:", {
        hasTeamA: !!teamA,
        hasTeamB: !!teamB,
        matchId: matchId.toString(),
        matchKeys: Object.keys(matchObj)
      });
      return NextResponse.json(
        { error: "Match team data is missing" },
        { status: 400 }
      );
    }

    // Check if teamA/teamB are ObjectIds (old format) or objects (new format)
    const isTeamAObjectId = teamA.buffer !== undefined || (typeof teamA === 'object' && !teamA.teamId && !teamA.teamName);
    const isTeamBObjectId = teamB.buffer !== undefined || (typeof teamB === 'object' && !teamB.teamId && !teamB.teamName);

    let teamAIdValue: any;
    let teamBIdValue: any;

    if (isTeamAObjectId) {
      // Old format: teamA is directly an ObjectId
      teamAIdValue = teamA;
    } else {
      // New format: teamA is an object with teamId
      teamAIdValue = teamA.teamId;
      // If teamId is a populated object, extract the _id
      if (teamAIdValue && typeof teamAIdValue === 'object' && teamAIdValue._id) {
        teamAIdValue = teamAIdValue._id;
      }
    }

    if (isTeamBObjectId) {
      // Old format: teamB is directly an ObjectId
      teamBIdValue = teamB;
    } else {
      // New format: teamB is an object with teamId
      teamBIdValue = teamB.teamId;
      // If teamId is a populated object, extract the _id
      if (teamBIdValue && typeof teamBIdValue === 'object' && teamBIdValue._id) {
        teamBIdValue = teamBIdValue._id;
      }
    }

    if (!teamAIdValue || !teamBIdValue) {
      console.error("❌ Match team IDs missing:", {
        teamAIdValue: teamAIdValue,
        teamBIdValue: teamBIdValue,
        teamAKeys: Object.keys(teamA),
        teamBKeys: Object.keys(teamB),
        isTeamAObjectId,
        isTeamBObjectId,
        matchId: matchId.toString()
      });
      return NextResponse.json(
        { error: "Match team IDs are missing. The match may not have been created properly. Please recreate the match." },
        { status: 400 }
      );
    }

    // Convert to string - handle both ObjectId and string
    const teamAId = teamAIdValue.toString ? teamAIdValue.toString() : String(teamAIdValue);
    const teamBId = teamBIdValue.toString ? teamBIdValue.toString() : String(teamBIdValue);
    const isTeamAWinner = winnerTeamId === teamAId;

    if (!isTeamAWinner && winnerTeamId !== teamBId) {
      return NextResponse.json(
        { error: "winnerTeamId does not match either team in the match" },
        { status: 400 }
      );
    }

    // Determine sides: winner gets selected side, loser gets opposite
    const loserSide = winnerSide === "offense" ? "defense" : "offense";
    const teamASide = isTeamAWinner ? winnerSide : loserSide;
    const teamBSide = isTeamAWinner ? loserSide : winnerSide;

    // Check if teamA/teamB are ObjectIds (old format) - need to restructure
    const needsRestructure = isTeamAObjectId || isTeamBObjectId;

    if (needsRestructure) {
      // Old format: teamA/teamB are ObjectIds, need to convert to proper structure
      const updateData: any = {
        status: "continue",
      };

      if (isTeamAObjectId) {
        // Restructure teamA from ObjectId to proper object
        updateData.teamA = {
          teamId: teamAIdValue,
          side: teamASide,
          players: [],
          playerActions: [],
          playerStats: [],
          teamStats: {},
          score: 0,
          win: null
        };
      } else {
        // Just update the side
        updateData["teamA.side"] = teamASide;
      }

      if (isTeamBObjectId) {
        // Restructure teamB from ObjectId to proper object
        updateData.teamB = {
          teamId: teamBIdValue,
          side: teamBSide,
          players: [],
          playerActions: [],
          playerStats: [],
          teamStats: {},
          score: 0,
          win: null
        };
      } else {
        // Just update the side
        updateData["teamB.side"] = teamBSide;
      }

      await Match.updateOne(
        { _id: matchId },
        { $set: updateData }
      );
    } else {
      // New format: teamA/teamB are already objects, just update sides
      await Match.updateOne(
        { _id: matchId },
        {
          $set: {
            "teamA.side": teamASide,
            "teamB.side": teamBSide,
            status: "continue", // Update status from upcoming to continue
          }
        }
      );
    }

    // Reload the match to get updated data
    const updatedMatch = await Match.findById(matchId);
    if (!updatedMatch) {
      return NextResponse.json({ error: "Match not found after update" }, { status: 404 });
    }

    // Populate and return
    await updatedMatch.populate("leagueId", "leagueName format startDate endDate logo");
    await updatedMatch.populate("createdBy", "firstName lastName email role");
    await updatedMatch.populate("teamA.teamId", "teamName enterCode");
    await updatedMatch.populate("teamB.teamId", "teamName enterCode");
    await updatedMatch.populate("teamA.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("refereeId", "firstName lastName email role");
    await updatedMatch.populate("statKeeperId", "firstName lastName email role");
    await updatedMatch.populate("gameWinnerTeam", "teamName enterCode");

    return NextResponse.json(
      {
        message: "Toss completed successfully",
        data: updatedMatch,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Complete toss error:", error);
    return NextResponse.json(
      { error: error.message || "Failed to complete toss" },
      { status: 500 }
    );
  }
}

/**
 * Switch overtime - set timesSwitched to overtime (no side swapping)
 * POST /api/match/:id/overtime
 * This only updates timesSwitched to "overtime" without swapping team sides
 * Note: This function does NOT modify the match status field
 */
export async function switchOvertime(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;
    const matchId = toObjectId(id);

    // Get match
    const existingMatch = await Match.findById(matchId);
    if (!existingMatch) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    // Update only timesSwitched to overtime (no side swapping)
    // Using updateOne to avoid validating the entire document (status might be invalid)
    await Match.updateOne(
      { _id: matchId },
      {
        $set: {
          timesSwitched: "overtime"
        }
      }
    );

    // Reload the match to get updated data
    const updatedMatch = await Match.findById(matchId);
    if (!updatedMatch) {
      return NextResponse.json({ error: "Match not found after update" }, { status: 404 });
    }

    // Populate and return
    await updatedMatch.populate("leagueId", "leagueName format startDate endDate logo");
    await updatedMatch.populate("createdBy", "firstName lastName email role");
    await updatedMatch.populate("teamA.teamId", "teamName enterCode");
    await updatedMatch.populate("teamB.teamId", "teamName enterCode");
    await updatedMatch.populate("teamA.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.players.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerStats.playerId", "firstName lastName email");
    await updatedMatch.populate("teamA.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("teamB.playerActions.playerId", "firstName lastName email");
    await updatedMatch.populate("refereeId", "firstName lastName email role");
    await updatedMatch.populate("statKeeperId", "firstName lastName email role");
    await updatedMatch.populate("gameWinnerTeam", "teamName enterCode");

    return NextResponse.json(
      {
        message: "Overtime switched successfully",
        data: updatedMatch,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Switch overtime error:", error);
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json(
      { error: error.message || "Failed to switch overtime" },
      { status: 500 }
    );
  }
}

