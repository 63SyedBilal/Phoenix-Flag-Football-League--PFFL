import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { League, Match, Team, User, Notification } from "@/modules";
import { verifyAccessToken } from "@/lib/jwt";
import mongoose from "mongoose";

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

// Helper to convert string ID to ObjectId
function toObjectId(id: string): mongoose.Types.ObjectId {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw new Error("Invalid ID format");
  }
  return new mongoose.Types.ObjectId(id);
}

// Helper to verify admin access
async function verifyAdmin(req: NextRequest) {
  const decoded = await verifyUser(req);
  const userId = (decoded as any).id || (decoded as any)._id || (decoded as any).userId;

  const user = await User.findById(userId);
  if (!user || (user.role !== "superadmin" && user.role !== "admin")) {
    throw new Error("Admin access required");
  }

  return user;
}

/**
 * Get top 4 teams from league leaderboard
 * GET /api/league/:leagueId/top-teams
 */
export async function getTopTeams(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req); // Only admin can trigger tournament progression

    const { id: leagueId } = params;
    const leagueObjectId = toObjectId(leagueId);

    const league = await League.findById(leagueObjectId).populate({
      path: "teams",
      select: "teamName logo captain",
      populate: {
        path: "captain",
        select: "firstName lastName email"
      }
    });

    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Get all completed matches for this league
    const matches = await Match.find({
      leagueId: leagueObjectId,
      status: "completed",
      matchType: "league"
    }).populate("teamA teamB");

    // Calculate team standings
    const teamStats = new Map();

    // Initialize all teams with 0 stats
    for (const teamRef of league.teams) {
      teamStats.set(teamRef._id.toString(), {
        teamId: teamRef._id,
        teamName: teamRef.teamName,
        logo: teamRef.logo,
        captain: teamRef.captain,
        played: 0,
        wins: 0,
        draws: 0,
        losses: 0,
        goalsFor: 0,
        goalsAgainst: 0,
        points: 0
      });
    }

    // Calculate stats from matches
    for (const match of matches) {
      const homeTeamId = match.teamA.toString();
      const awayTeamId = match.teamB.toString();
      const homeScore = match.teamAStats?.score || 0;
      const awayScore = match.teamBStats?.score || 0;

      // Update home team
      if (teamStats.has(homeTeamId)) {
        const homeStats = teamStats.get(homeTeamId);
        homeStats.played += 1;
        homeStats.goalsFor += homeScore;
        homeStats.goalsAgainst += awayScore;

        if (homeScore > awayScore) {
          homeStats.wins += 1;
          homeStats.points += 3;
        } else if (homeScore === awayScore) {
          homeStats.draws += 1;
          homeStats.points += 1;
        } else {
          homeStats.losses += 1;
        }
      }

      // Update away team
      if (teamStats.has(awayTeamId)) {
        const awayStats = teamStats.get(awayTeamId);
        awayStats.played += 1;
        awayStats.goalsFor += awayScore;
        awayStats.goalsAgainst += homeScore;

        if (awayScore > homeScore) {
          awayStats.wins += 1;
          awayStats.points += 3;
        } else if (awayScore === homeScore) {
          awayStats.draws += 1;
          awayStats.points += 1;
        } else {
          awayStats.losses += 1;
        }
      }
    }

    // Convert to array and calculate goal difference
    const standings = Array.from(teamStats.values()).map(team => ({
      ...team,
      goalDifference: team.goalsFor - team.goalsAgainst
    }));

    // Sort by points, then goal difference, then goals for
    standings.sort((a, b) => {
      if (a.points !== b.points) return b.points - a.points;
      if (a.goalDifference !== b.goalDifference) return b.goalDifference - a.goalDifference;
      return b.goalsFor - a.goalsFor;
    });

    // Get top 4 teams
    const topTeams = standings.slice(0, 4).map((team, index) => ({
      teamId: team.teamId,
      teamName: team.teamName,
      logo: team.logo,
      position: index + 1,
      stats: {
        points: team.points,
        goalDifference: team.goalDifference,
        goalsFor: team.goalsFor,
        played: team.played
      }
    }));

    return NextResponse.json({
      success: true,
      data: topTeams,
      totalTeams: standings.length
    }, { status: 200 });

  } catch (error: any) {
    console.error("Error getting top teams:", error);
    return NextResponse.json({
      error: error.message || "Failed to get top teams"
    }, { status: 500 });
  }
}

/**
 * Create semi-final matches for top 4 teams
 * POST /api/league/:leagueId/create-semi-finals
 */
export async function createSemiFinals(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id: leagueId } = params;
    const { matchDate, venue, refereeIds, statKeeperIds } = await req.json();

    const leagueObjectId = toObjectId(leagueId);

    // Get league and check if ready for semi-finals
    const league = await League.findById(leagueObjectId).populate("teams topTeams.teamId");
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    if (league.tournamentStage !== "league") {
      return NextResponse.json({
        error: `Cannot create semi-finals: tournament is in ${league.tournamentStage} stage`
      }, { status: 400 });
    }

    // Get top 4 teams if not already set
    let topTeams = league.topTeams;
    if (!topTeams || topTeams.length < 4) {
      const topTeamsResponse = await getTopTeams(req, { params: { id: leagueId } });
      if (topTeamsResponse.status !== 200) {
        return NextResponse.json({ error: "Failed to get top teams" }, { status: 500 });
      }

      const topTeamsData = await topTeamsResponse.json();
      topTeams = topTeamsData.data.map((team: any, index: number) => ({
        teamId: team.teamId,
        position: index + 1,
        qualifiedAt: new Date()
      }));

      // Update league with top teams
      await League.findByIdAndUpdate(leagueObjectId, {
        topTeams: topTeams,
        tournamentStage: "semi-finals"
      });
    }

    if (topTeams.length < 4) {
      return NextResponse.json({
        error: "Not enough teams qualified for semi-finals (need 4 teams)"
      }, { status: 400 });
    }

    // Create semi-final matches
    const semiFinalMatches = [];

    // Semi-Final 1: Rank 1 vs Rank 4
    const sf1Match = await Match.create({
      leagueId: leagueObjectId,
      teamA: topTeams[0].teamId,
      teamB: topTeams[3].teamId,
      matchType: "semi-final-1",
      tournamentRound: 2,
      isKnockout: true,
      gameDate: new Date(matchDate),
      venue: venue,
      refereeId: refereeIds?.[0] || null,
      statKeeperId: statKeeperIds?.[0] || null,
      status: "upcoming",
      roundName: "Semi-Final 1",
      teamAInitialSide: "offense",
      teamBInitialSide: "defense"
    });
    semiFinalMatches.push(sf1Match);

    // Semi-Final 2: Rank 2 vs Rank 3
    const sf2Match = await Match.create({
      leagueId: leagueObjectId,
      teamA: topTeams[1].teamId,
      teamB: topTeams[2].teamId,
      matchType: "semi-final-2",
      tournamentRound: 2,
      isKnockout: true,
      gameDate: new Date(matchDate),
      venue: venue,
      refereeId: refereeIds?.[1] || null,
      statKeeperId: statKeeperIds?.[1] || null,
      status: "upcoming",
      roundName: "Semi-Final 2",
      teamAInitialSide: "offense",
      teamBInitialSide: "defense"
    });
    semiFinalMatches.push(sf2Match);

    // Send notifications to teams and officials
    await sendTournamentNotifications(leagueObjectId, semiFinalMatches, "semi-finals");

    return NextResponse.json({
      success: true,
      message: "Semi-final matches created successfully",
      data: {
        matches: semiFinalMatches,
        topTeams: topTeams
      }
    }, { status: 201 });

  } catch (error: any) {
    console.error("Error creating semi-finals:", error);
    return NextResponse.json({
      error: error.message || "Failed to create semi-finals"
    }, { status: 500 });
  }
}

/**
 * Create final match from semi-final winners
 * POST /api/league/:leagueId/create-final
 */
export async function createFinal(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id: leagueId } = params;
    const { matchDate, venue, refereeId, statKeeperId } = await req.json();

    const leagueObjectId = toObjectId(leagueId);

    const league = await League.findById(leagueObjectId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    if (league.tournamentStage !== "semi-finals") {
      return NextResponse.json({
        error: `Cannot create final: tournament is in ${league.tournamentStage} stage`
      }, { status: 400 });
    }

    // Check if both semi-finals are completed
    const semiFinals = await Match.find({
      leagueId: leagueObjectId,
      matchType: { $in: ["semi-final-1", "semi-final-2"] },
      status: "completed"
    });

    if (semiFinals.length !== 2) {
      return NextResponse.json({
        error: "Both semi-final matches must be completed before creating final"
      }, { status: 400 });
    }

    // Get winners from semi-finals
    const sf1Winner = semiFinals.find(m => m.matchType === "semi-final-1")?.winner;
    const sf2Winner = semiFinals.find(m => m.matchType === "semi-final-2")?.winner;

    if (!sf1Winner || !sf2Winner) {
      return NextResponse.json({
        error: "Both semi-finals must have winners before creating final"
      }, { status: 400 });
    }

    // Create final match
    const finalMatch = await Match.create({
      leagueId: leagueObjectId,
      teamA: sf1Winner,
      teamB: sf2Winner,
      matchType: "final",
      tournamentRound: 3,
      isKnockout: true,
      gameDate: new Date(matchDate),
      venue: venue,
      refereeId: refereeId,
      statKeeperId: statKeeperId,
      status: "upcoming",
      roundName: "Final",
      teamAInitialSide: "offense",
      teamBInitialSide: "defense"
    });

    // Update league stage
    await League.findByIdAndUpdate(leagueObjectId, {
      tournamentStage: "final"
    });

    // Send notifications
    await sendTournamentNotifications(leagueObjectId, [finalMatch], "final");

    return NextResponse.json({
      success: true,
      message: "Final match created successfully",
      data: {
        match: finalMatch,
        teamA: sf1Winner,
        teamB: sf2Winner
      }
    }, { status: 201 });

  } catch (error: any) {
    console.error("Error creating final:", error);
    return NextResponse.json({
      error: error.message || "Failed to create final"
    }, { status: 500 });
  }
}

/**
 * Complete tournament and set champion
 * POST /api/league/:leagueId/complete-tournament
 */
export async function completeTournament(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id: leagueId } = params;
    const leagueObjectId = toObjectId(leagueId);

    const league = await League.findById(leagueObjectId);
    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    if (league.tournamentStage !== "final") {
      return NextResponse.json({
        error: `Cannot complete tournament: stage is ${league.tournamentStage}`
      }, { status: 400 });
    }

    // Get final match
    const finalMatch = await Match.findOne({
      leagueId: leagueObjectId,
      matchType: "final",
      status: "completed"
    });

    if (!finalMatch) {
      return NextResponse.json({
        error: "Final match not found or not completed"
      }, { status: 400 });
    }

    if (!finalMatch.winner) {
      return NextResponse.json({
        error: "Final match must have a winner"
      }, { status: 400 });
    }

    // Complete tournament
    await League.findByIdAndUpdate(leagueObjectId, {
      tournamentStage: "completed",
      champion: finalMatch.winner,
      tournamentCompletedAt: new Date(),
      status: "completed"
    });

    // Send championship notification
    await sendChampionshipNotification(leagueObjectId, finalMatch.winner);

    return NextResponse.json({
      success: true,
      message: "Tournament completed successfully",
      data: {
        champion: finalMatch.winner,
        completedAt: new Date()
      }
    }, { status: 200 });

  } catch (error: any) {
    console.error("Error completing tournament:", error);
    return NextResponse.json({
      error: error.message || "Failed to complete tournament"
    }, { status: 500 });
  }
}

/**
 * Get tournament bracket data
 * GET /api/league/:leagueId/bracket
 */
export async function getTournamentBracket(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req); // Allow any authenticated user to view bracket

    const { id: leagueId } = params;
    const leagueObjectId = toObjectId(leagueId);

    const league = await League.findById(leagueObjectId)
      .populate("topTeams.teamId", "teamName logo")
      .populate("semiFinal1Winner", "teamName logo")
      .populate("semiFinal2Winner", "teamName logo")
      .populate("champion", "teamName logo");

    if (!league) {
      return NextResponse.json({ error: "League not found" }, { status: 404 });
    }

    // Get all tournament matches
    const matches = await Match.find({
      leagueId: leagueObjectId,
      isKnockout: true
    }).populate("teamA teamB winner", "teamName logo");

    // Organize bracket data
    const bracket = {
      tournamentStage: league.tournamentStage,
      topTeams: league.topTeams,
      semiFinals: matches.filter(m => m.matchType.includes("semi-final")),
      final: matches.find(m => m.matchType === "final"),
      champion: league.champion,
      completedAt: league.tournamentCompletedAt
    };

    return NextResponse.json({
      success: true,
      data: bracket
    }, { status: 200 });

  } catch (error: any) {
    console.error("Error getting tournament bracket:", error);
    return NextResponse.json({
      error: error.message || "Failed to get tournament bracket"
    }, { status: 500 });
  }
}

/**
 * Set match winner (for knockout advancement)
 * PUT /api/matches/:id/winner
 */
export async function setMatchWinner(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyAdmin(req);

    const { id: matchId } = params;
    const { winnerId, tiebreakerUsed, tiebreakerType } = await req.json();

    const matchObjectId = toObjectId(matchId);
    const winnerObjectId = toObjectId(winnerId);

    const match = await Match.findById(matchObjectId).populate("leagueId");
    if (!match) {
      return NextResponse.json({ error: "Match not found" }, { status: 404 });
    }

    if (match.status !== "completed") {
      return NextResponse.json({
        error: "Match must be completed before setting winner"
      }, { status: 400 });
    }

    // Validate winner is one of the teams in the match
    if (match.teamA.toString() !== winnerId && match.teamB.toString() !== winnerId) {
      return NextResponse.json({
        error: "Winner must be one of the teams in the match"
      }, { status: 400 });
    }

    // Update match with winner
    await Match.findByIdAndUpdate(matchObjectId, {
      winner: winnerObjectId,
      tiebreakerUsed: tiebreakerUsed || false,
      tiebreakerType: tiebreakerType || null
    });

    // If this is a semi-final, check if we can advance to final
    if (match.matchType.includes("semi-final")) {
      await checkSemiFinalCompletion(match.leagueId);
    }

    return NextResponse.json({
      success: true,
      message: "Match winner set successfully",
      data: {
        matchId: matchId,
        winner: winnerId,
        tiebreakerUsed: tiebreakerUsed || false
      }
    }, { status: 200 });

  } catch (error: any) {
    console.error("Error setting match winner:", error);
    return NextResponse.json({
      error: error.message || "Failed to set match winner"
    }, { status: 500 });
  }
}

// Helper function to check if both semi-finals are complete and advance to final
async function checkSemiFinalCompletion(leagueId: mongoose.Types.ObjectId) {
  const semiFinals = await Match.find({
    leagueId: leagueId,
    matchType: { $in: ["semi-final-1", "semi-final-2"] },
    status: "completed",
    winner: { $exists: true }
  });

  if (semiFinals.length === 2) {
    // Both semi-finals complete, update winners in league
    const sf1Winner = semiFinals.find(m => m.matchType === "semi-final-1")?.winner;
    const sf2Winner = semiFinals.find(m => m.matchType === "semi-final-2")?.winner;

    await League.findByIdAndUpdate(leagueId, {
      semiFinal1Winner: sf1Winner,
      semiFinal2Winner: sf2Winner
    });

    console.log(`✅ Semi-finals completed for league ${leagueId}. Winners recorded.`);
  }
}

// Helper function to send tournament notifications
async function sendTournamentNotifications(leagueId: mongoose.Types.ObjectId, matches: any[], stage: string) {
  try {
    for (const match of matches) {
      // Get teams and their captains
      const teamA = await Team.findById(match.teamA).populate("captain", "firstName lastName email");
      const teamB = await Team.findById(match.teamB).populate("captain", "firstName lastName email");

      // Notify team captains
      const captains = [teamA?.captain, teamB?.captain].filter(c => c);

      for (const captain of captains) {
        if (captain) {
          const notificationType = match.matchType === "semi-final-1" || match.matchType === "semi-final-2"
            ? "SEMI_FINAL_ASSIGNMENT"
            : match.matchType === "final"
            ? "FINAL_ASSIGNMENT"
            : "TOURNAMENT_ADVANCEMENT";

          const message = match.matchType === "semi-final-1" || match.matchType === "semi-final-2"
            ? `Your team has advanced to the Semi-Finals! Match: ${teamA?.teamName} vs ${teamB?.teamName} on ${match.gameDate?.toDateString()} at ${match.gameTime} at ${match.venue || 'TBD'}`
            : match.matchType === "final"
            ? `Your team has advanced to the Final! Championship match: ${teamA?.teamName} vs ${teamB?.teamName} on ${match.gameDate?.toDateString()} at ${match.gameTime} at ${match.venue || 'TBD'}`
            : `Your team has advanced to the ${stage}! Match scheduled for ${match.gameDate?.toDateString()}.`;

          await Notification.create({
            sender: null, // System notification
            receiver: captain._id,
            league: leagueId,
            match: match._id,
            type: notificationType,
            status: "pending",
            message: message,
            data: {
              stage: stage,
              matchType: match.matchType,
              teamA: teamA?.teamName,
              teamB: teamB?.teamName,
              matchDate: match.gameDate?.toDateString(),
              matchTime: match.gameTime,
              venue: match.venue,
              opponent: match.teamA.toString() === teamA._id.toString() ? teamB?.teamName : teamA?.teamName
            }
          });
        }
      }

      // Notify referee and stat keeper if assigned
      if (match.refereeId) {
        const refereeType = match.matchType === "semi-final-1" || match.matchType === "semi-final-2"
          ? "REFEREE_ASSIGNED"
          : match.matchType === "final"
          ? "REFEREE_ASSIGNED"
          : "GAME_ASSIGNED";

        await Notification.create({
          sender: null,
          receiver: match.refereeId,
          league: leagueId,
          match: match._id,
          type: refereeType,
          status: "pending",
          message: `You have been assigned as referee for: ${teamA?.teamName} vs ${teamB?.teamName} at ${match.venue || 'TBD'} on ${match.gameDate?.toDateString()} at ${match.gameTime}`,
          data: {
            teamA: teamA?.teamName,
            teamB: teamB?.teamName,
            venue: match.venue,
            matchDate: match.gameDate?.toDateString(),
            matchTime: match.gameTime
          }
        });
      }

      if (match.statKeeperId) {
        const statKeeperType = match.matchType === "semi-final-1" || match.matchType === "semi-final-2"
          ? "STATKEEPER_ASSIGNED"
          : match.matchType === "final"
          ? "STATKEEPER_ASSIGNED"
          : "GAME_ASSIGNED";

        await Notification.create({
          sender: null,
          receiver: match.statKeeperId,
          league: leagueId,
          match: match._id,
          type: statKeeperType,
          status: "pending",
          message: `You have been assigned as stat keeper for: ${teamA?.teamName} vs ${teamB?.teamName} at ${match.venue || 'TBD'} on ${match.gameDate?.toDateString()} at ${match.gameTime}`,
          data: {
            teamA: teamA?.teamName,
            teamB: teamB?.teamName,
            venue: match.venue,
            matchDate: match.gameDate?.toDateString(),
            matchTime: match.gameTime
          }
        });
      }
    }
  } catch (error) {
    console.error("Error sending tournament notifications:", error);
  }
}

// Helper function to send championship notification
async function sendChampionshipNotification(leagueId: mongoose.Types.ObjectId, championId: mongoose.Types.ObjectId) {
  try {
    const champion = await Team.findById(championId).populate("captain", "firstName lastName email");
    const league = await League.findById(leagueId);

    // Notify champion captain
    if (champion?.captain) {
      await Notification.create({
        sender: null,
        receiver: champion.captain._id,
        league: leagueId,
        type: "CHAMPIONSHIP_WON",
        status: "pending",
        message: `🎉 Congratulations! ${champion.teamName} has won the ${league?.leagueName} championship! 🏆`,
        data: {
          championship: true,
          leagueName: league?.leagueName
        }
      });
    }

    // Notify all league participants about the winner
    const leagueUsers = await User.find({
      $or: [
        { _id: { $in: await getLeagueCaptainIds(leagueId) } },
        { role: { $in: ["referee", "stat-keeper"] } }
      ]
    });

    for (const user of leagueUsers) {
      if (user._id.toString() !== champion?.captain._id.toString()) {
        await Notification.create({
          sender: null,
          receiver: user._id,
          league: leagueId,
          type: "TOURNAMENT_COMPLETED",
          status: "pending",
          message: `🏆 ${champion?.teamName} has won the ${league?.leagueName} championship!`,
          data: {
            champion: champion?.teamName,
            leagueName: league?.leagueName
          }
        });
      }
    }
  } catch (error) {
    console.error("Error sending championship notification:", error);
  }
}

// Check if all league matches are completed and trigger tournament progression
// This should be called after each match completion
export async function checkTournamentProgression(leagueId: string) {
  try {
    await connectDB();
    const leagueObjectId = toObjectId(leagueId);

    const league = await League.findById(leagueObjectId);
    if (!league) {
      console.error(`League ${leagueId} not found`);
      return;
    }

    // Only check progression if still in league stage
    if (league.tournamentStage !== "league") {
      console.log(`League ${leagueId} already progressed to ${league.tournamentStage} stage`);
      return;
    }

    // Count total league matches and completed ones
    const totalLeagueMatches = await Match.countDocuments({
      leagueId: leagueObjectId,
      matchType: "league"
    });

    const completedLeagueMatches = await Match.countDocuments({
      leagueId: leagueObjectId,
      matchType: "league",
      status: "completed"
    });

    console.log(`League ${leagueId}: ${completedLeagueMatches}/${totalLeagueMatches} league matches completed`);

    // If all league matches are complete, trigger tournament progression
    if (totalLeagueMatches > 0 && completedLeagueMatches === totalLeagueMatches) {
      console.log(`🎯 All league matches completed for league ${leagueId}. Triggering tournament progression...`);

      // Get top 4 teams automatically
      const topTeamsResponse = await getTopTeams({ params: { id: leagueId } } as any, { params: { id: leagueId } });

      if (topTeamsResponse.status === 200) {
        const topTeamsData = await topTeamsResponse.json();

        if (topTeamsData.success && topTeamsData.data && topTeamsData.data.length >= 4) {
          console.log(`✅ Found ${topTeamsData.data.length} qualified teams. Creating semi-finals...`);

          // Create semi-finals automatically
          const semiFinalsResponse = await createSemiFinals(
            {
              json: async () => ({
                matchDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // 1 week from now
                venue: "TBD",
                refereeIds: [], // Will be assigned later
                statKeeperIds: [] // Will be assigned later
              })
            } as any,
            { params: { id: leagueId } }
          );

          if (semiFinalsResponse.status === 201) {
            console.log(`✅ Semi-finals created successfully for league ${leagueId}`);
          } else {
            console.error(`❌ Failed to create semi-finals for league ${leagueId}`);
          }
        } else {
          console.error(`❌ Not enough teams qualified for league ${leagueId} (need 4, got ${topTeamsData.data?.length || 0})`);
        }
      } else {
        console.error(`❌ Failed to get top teams for league ${leagueId}`);
      }
    }
  } catch (error) {
    console.error("Error checking tournament progression:", error);
  }
}

// Helper function to get all captain IDs in a league
async function getLeagueCaptainIds(leagueId: mongoose.Types.ObjectId): Promise<mongoose.Types.ObjectId[]> {
  const teams = await Team.find({ leagueId: leagueId }, "captain");
  return teams.map(team => team.captain).filter(captain => captain);
}
