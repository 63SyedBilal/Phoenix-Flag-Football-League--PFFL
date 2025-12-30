import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { Stat, User, Match, Team, League } from "@/modules";
import { verifyAccessToken } from "@/lib/jwt";

interface PlayerPerformance {
  playerId: string;
  playerName: string;
  gamesPlayed: number;
  wins: number;
  losses: number;
  touchdowns: number;
  catches: number;
  rushes: number;
  flagPulls: number;
  yardsGained: number;
  yardsLost: number;
  completions: number;
  passAttempts: number;
  completionPercentage: number;
  safety: number;
  conversionPoints: number;
  averagePointsPerGame: number;
  bestPosition: string;
  ranking: number;
}

/**
 * Get current user's performance statistics
 * GET /api/performance/my
 */
export async function getMyPerformance(req: NextRequest) {
  try {
    await connectDB();

    // Verify user token
    const authHeader = req.headers.get("authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return NextResponse.json({ error: "No token provided" }, { status: 401 });
    }

    const token = authHeader.substring(7);
    const decoded = verifyAccessToken(token);
    const userId = decoded.userId;

    // Get all approved stats for this user
    const playerStats = await Stat.find({
      playerId: userId,
      status: "APPROVED"
    }).populate('matchId', 'status winner homeTeam awayTeam');

    if (!playerStats || playerStats.length === 0) {
      return NextResponse.json({
        success: false,
        message: "No performance data found",
        data: null
      });
    }

    // Calculate performance metrics
    let totalGamesPlayed = 0;
    let wins = 0;
    let losses = 0;
    let touchdowns = 0;
    let catches = 0;
    let rushes = 0;
    let flagPulls = 0;
    let yardsGained = 0;
    let yardsLost = 0;
    let completions = 0;
    let passAttempts = 0;
    let safeties = 0;
    let conversionPoints = 0;

    // Track unique matches to count games played
    const uniqueMatches = new Set();

    playerStats.forEach(stat => {
      if (stat.matchId && stat.matchId.status === 'completed') {
        uniqueMatches.add(stat.matchId._id.toString());

        // Count wins/losses based on team performance
        const isHomeTeam = stat.teamId.toString() === stat.matchId.homeTeam?.toString();
        const isAwayTeam = stat.teamId.toString() === stat.matchId.awayTeam?.toString();

        if (isHomeTeam && stat.matchId.winner === 'home') wins++;
        else if (isAwayTeam && stat.matchId.winner === 'away') wins++;
        else if (stat.matchId.winner !== 'draw') losses++;

        // Aggregate stats
        const stats = stat.stats || {};
        touchdowns += stats.touchdowns || 0;
        catches += stats.catches || 0;
        rushes += stats.rushes || 0;
        flagPulls += stats.flagPull || 0;
        yardsGained += (stats.catchYards || 0) + (stats.rushYards || 0) + (stats.passYards || 0);
        yardsLost += stats.sack || 0; // Approximate yards lost
        completions += stats.completions || 0;
        passAttempts += stats.passAttempts || 0;
        safeties += stats.safeties || 0;
        conversionPoints += stats.extraPoints || 0;
      }
    });

    totalGamesPlayed = uniqueMatches.size;

    // Calculate derived metrics
    const completionPercentage = passAttempts > 0 ? (completions / passAttempts) * 100 : 0;
    const totalPoints = (touchdowns * 6) + (conversionPoints * 2) + (safeties * 2);
    const averagePointsPerGame = totalGamesPlayed > 0 ? totalPoints / totalGamesPlayed : 0;

    // Determine best position based on stats
    let bestPosition = "Player";
    if (catches > rushes && catches > passAttempts) {
      bestPosition = "Wide Receiver";
    } else if (rushes > catches && rushes > passAttempts) {
      bestPosition = "Running Back";
    } else if (passAttempts > rushes && passAttempts > catches) {
      bestPosition = "Quarterback";
    }

    // Get user details
    const user = await User.findById(userId);
    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    const performance: PlayerPerformance = {
      playerId: userId,
      playerName: `${user.firstName} ${user.lastName}`,
      gamesPlayed: totalGamesPlayed,
      wins,
      losses,
      touchdowns,
      catches,
      rushes,
      flagPulls,
      yardsGained,
      yardsLost,
      completions,
      passAttempts,
      completionPercentage: Math.round(completionPercentage * 100) / 100,
      safety: safeties,
      conversionPoints,
      averagePointsPerGame: Math.round(averagePointsPerGame * 100) / 100,
      bestPosition,
      ranking: 0 // Will be calculated in leaderboard
    };

    return NextResponse.json({
      success: true,
      data: performance,
      message: "Performance data retrieved successfully"
    });

  } catch (error: any) {
    console.error("Error in getMyPerformance:", error);
    return NextResponse.json(
      { error: error.message || "Failed to get performance data" },
      { status: 500 }
    );
  }
}

/**
 * Get performance leaderboard
 * GET /api/performance/leaderboard?limit=10
 */
export async function getLeaderboard(req: NextRequest) {
  try {
    await connectDB();

    const { searchParams } = new URL(req.url);
    const limit = Math.min(parseInt(searchParams.get('limit') || '10'), 50); // Max 50

    // Get all approved stats
    const allStats = await Stat.find({ status: "APPROVED" })
      .populate('matchId', 'status winner homeTeam awayTeam')
      .populate('playerId', 'firstName lastName');

    // Group stats by player and calculate performance
    const playerPerformances = new Map<string, PlayerPerformance>();

    allStats.forEach(stat => {
      if (!stat.matchId || stat.matchId.status !== 'completed') return;

      const playerId = stat.playerId._id.toString();
      const playerName = stat.playerId ? `${stat.playerId.firstName} ${stat.playerId.lastName}` : 'Unknown Player';

      if (!playerPerformances.has(playerId)) {
        playerPerformances.set(playerId, {
          playerId,
          playerName,
          gamesPlayed: 0,
          wins: 0,
          losses: 0,
          touchdowns: 0,
          catches: 0,
          rushes: 0,
          flagPulls: 0,
          yardsGained: 0,
          yardsLost: 0,
          completions: 0,
          passAttempts: 0,
          completionPercentage: 0,
          safety: 0,
          conversionPoints: 0,
          averagePointsPerGame: 0,
          bestPosition: "Player",
          ranking: 0
        });
      }

      const performance = playerPerformances.get(playerId)!;

      // Count unique matches for games played
      const matchId = stat.matchId._id.toString();
      if (!performance.gamesPlayed || typeof performance.gamesPlayed === 'number') {
        // This is a simplified approach - in production you'd track unique matches per player
        performance.gamesPlayed = (performance.gamesPlayed || 0) + 1;
      }

      // Count wins/losses
      const isHomeTeam = stat.teamId.toString() === stat.matchId.homeTeam?.toString();
      const isAwayTeam = stat.teamId.toString() === stat.matchId.awayTeam?.toString();

      if (isHomeTeam && stat.matchId.winner === 'home') performance.wins++;
      else if (isAwayTeam && stat.matchId.winner === 'away') performance.wins++;
      else if (stat.matchId.winner !== 'draw') performance.losses++;

      // Aggregate stats
      const stats = stat.stats || {};
      performance.touchdowns += stats.touchdowns || 0;
      performance.catches += stats.catches || 0;
      performance.rushes += stats.rushes || 0;
      performance.flagPulls += stats.flagPull || 0;
      performance.yardsGained += (stats.catchYards || 0) + (stats.rushYards || 0) + (stats.passYards || 0);
      performance.yardsLost += stats.sack || 0;
      performance.completions += stats.completions || 0;
      performance.passAttempts += stats.passAttempts || 0;
      performance.safety += stats.safeties || 0;
      performance.conversionPoints += stats.extraPoints || 0;
    });

    // Calculate derived metrics and determine best positions
    const performances = Array.from(playerPerformances.values()).map(performance => {
      const completionPercentage = performance.passAttempts > 0
        ? (performance.completions / performance.passAttempts) * 100
        : 0;

      const totalPoints = (performance.touchdowns * 6) + (performance.conversionPoints * 2) + (performance.safety * 2);
      const averagePointsPerGame = performance.gamesPlayed > 0 ? totalPoints / performance.gamesPlayed : 0;

      // Determine best position
      let bestPosition = "Player";
      if (performance.catches > performance.rushes && performance.catches > performance.passAttempts) {
        bestPosition = "Wide Receiver";
      } else if (performance.rushes > performance.catches && performance.rushes > performance.passAttempts) {
        bestPosition = "Running Back";
      } else if (performance.passAttempts > performance.rushes && performance.passAttempts > performance.catches) {
        bestPosition = "Quarterback";
      }

      return {
        ...performance,
        completionPercentage: Math.round(completionPercentage * 100) / 100,
        averagePointsPerGame: Math.round(averagePointsPerGame * 100) / 100,
        bestPosition
      };
    });

    // Sort by touchdowns (primary), then by total points, then by games played
    performances.sort((a, b) => {
      if (a.touchdowns !== b.touchdowns) return b.touchdowns - a.touchdowns;
      const aPoints = (a.touchdowns * 6) + (a.conversionPoints * 2) + (a.safety * 2);
      const bPoints = (b.touchdowns * 6) + (b.conversionPoints * 2) + (b.safety * 2);
      if (aPoints !== bPoints) return bPoints - aPoints;
      return b.gamesPlayed - a.gamesPlayed;
    });

    // Assign rankings
    performances.forEach((performance, index) => {
      performance.ranking = index + 1;
    });

    // Return top performers
    const topPerformers = performances.slice(0, limit);

    return NextResponse.json({
      success: true,
      data: topPerformers,
      message: `Retrieved top ${topPerformers.length} performers`
    });

  } catch (error: any) {
    console.error("Error in getLeaderboard:", error);
    return NextResponse.json(
      { error: error.message || "Failed to get leaderboard" },
      { status: 500 }
    );
  }
}
