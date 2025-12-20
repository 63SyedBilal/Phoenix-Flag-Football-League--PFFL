import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import Match from "@/modules/match";
import mongoose from "mongoose";

export async function POST(req: NextRequest) {
  try {
    await connectDB();

    // IDs from the provided game structure
    const leagueId = "6945a2fa0405c4c3bea05012";
    const refereeId = "6925f634adba3865ae17dc65";
    const statKeeperId = "6926067dadba3865ae17dcb3";

    // Convert to ObjectIds
    const leagueObjectId = new mongoose.Types.ObjectId(leagueId);
    const refereeObjectId = new mongoose.Types.ObjectId(refereeId);
    const statKeeperObjectId = new mongoose.Types.ObjectId(statKeeperId);

    // Delete existing games for this league with status "upcoming" to avoid duplicates
    await Match.deleteMany({
      leagueId: leagueObjectId,
      status: "upcoming"
    });
    console.log("🗑️ Deleted existing upcoming games for this league");

    // Generate dummy team IDs (since we don't have real team IDs)
    // We'll use the same pattern as the provided game
    const teamAId = new mongoose.Types.ObjectId();
    const teamBId = new mongoose.Types.ObjectId();

    // Create 10 games with different dates/times
    const games = [];
    const baseDate = new Date();
    // Set to tomorrow at midnight to ensure it's in the future
    baseDate.setDate(baseDate.getDate() + 1);
    baseDate.setHours(0, 0, 0, 0);

    const times = [
      "10:00",
      "12:00",
      "14:00",
      "16:00",
      "18:00",
      "20:00",
      "10:30",
      "12:30",
      "14:30",
      "16:30",
    ];

    const teamNames = [
      { teamA: "RC", teamB: "STA" },
      { teamA: "GEO", teamB: "STB" },
      { teamA: "WQ", teamB: "STC" },
      { teamA: "MAN", teamB: "CHE" },
      { teamA: "ARS", teamB: "LIV" },
      { teamA: "BAR", teamB: "MAD" },
      { teamA: "JUV", teamB: "MIL" },
      { teamA: "BAY", teamB: "DOR" },
      { teamA: "PSG", teamB: "LYO" },
      { teamA: "ATM", teamB: "SEV" },
    ];

    for (let i = 0; i < 10; i++) {
      const gameDate = new Date(baseDate);
      gameDate.setDate(baseDate.getDate() + i); // Each game on a different day
      // Ensure date is in the future
      if (gameDate <= new Date()) {
        gameDate.setDate(gameDate.getDate() + 1);
      }

      const gameData = {
        leagueId: leagueObjectId,
        teamA: teamAId,
        teamAName: teamNames[i].teamA,
        teamB: teamBId,
        teamBName: teamNames[i].teamB,
        gameDate: gameDate,
        gameTime: times[i],
        venue: "Main Stadium",
        refereeId: refereeObjectId,
        statKeeperId: statKeeperObjectId,
        roundName: "Group Stage",
        gameNumber: `G${i + 1}`,
        status: "upcoming", // Not completed
      };

      const match = new Match(gameData);
      await match.save();
      games.push(match);
    }

    return NextResponse.json(
      {
        message: "10 games created successfully",
        data: {
          count: games.length,
          games: games.map((game) => ({
            id: game._id,
            leagueId: game.leagueId,
            teamA: game.teamA,
            teamAName: game.teamAName,
            teamB: game.teamB,
            teamBName: game.teamBName,
            gameDate: game.gameDate,
            gameTime: game.gameTime,
            status: game.status,
            roundName: game.roundName,
            venue: game.venue,
          })),
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Seeding games error:", error);
    return NextResponse.json(
      { error: error.message || "Failed to seed games" },
      { status: 500 }
    );
  }
}

