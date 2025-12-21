/**
 * Fix Team Players Script
 * 
 * Adds exactly 15 players to Phoenix and USHZ teams.
 * Removes duplicates and maintains data consistency.
 * 
 * Usage: Run this script via API endpoint or directly
 */

import { connectDB } from "@/lib/db";
import { Team, User } from "@/modules";
import mongoose from "mongoose";

interface TeamFixResult {
  teamName: string;
  teamId: string;
  before: {
    squad5v5: number;
    squad7v7: number;
    totalUnique: number;
    duplicates: number;
  };
  after: {
    squad5v5: number;
    squad7v7: number;
    totalUnique: number;
  };
  playersAdded: number;
  playersRemoved: number;
}

/**
 * Get unique players from both squads
 */
function getUniquePlayers(squad5v5: any[], squad7v7: any[]): string[] {
  const allIds = [
    ...squad5v5.map((id: any) => id.toString()),
    ...squad7v7.map((id: any) => id.toString()),
  ];
  return [...new Set(allIds)];
}

/**
 * Fix a single team to have exactly 15 unique players
 */
async function fixTeamPlayers(
  team: any,
  targetCount: number = 15,
  availableFreeAgents: any[] = []
): Promise<TeamFixResult> {
  const teamName = team.teamName;
  const teamId = team._id.toString();

  // Get current state
  const squad5v5 = (team.squad5v5 || []).map((id: any) => id.toString());
  const squad7v7 = (team.squad7v7 || []).map((id: any) => id.toString());
  const uniquePlayers = getUniquePlayers(squad5v5, squad7v7);
  
  // Count duplicates
  const allIds = [...squad5v5, ...squad7v7];
  const duplicates = allIds.length - uniquePlayers.length;

  const before = {
    squad5v5: squad5v5.length,
    squad7v7: squad7v7.length,
    totalUnique: uniquePlayers.length,
    duplicates,
  };

  // Remove duplicates first
  const uniqueSquad5v5 = [...new Set(squad5v5)];
  const uniqueSquad7v7 = [...new Set(squad7v7)];
  
  // Check if already has exactly targetCount unique players and no duplicates
  const currentUniqueAfterDedup = getUniquePlayers(uniqueSquad5v5, uniqueSquad7v7).length;
  if (currentUniqueAfterDedup === targetCount && duplicates === 0) {
    // Still need to ensure proper distribution (7 in 5v5, 8 in 7v7)
    const current5v5 = uniqueSquad5v5.length;
    const current7v7 = uniqueSquad7v7.length;
    
    // If distribution is correct, return
    if (current5v5 <= 7 && current7v7 <= 8 && (current5v5 + current7v7) === targetCount) {
      return {
        teamName,
        teamId,
        before,
        after: {
          squad5v5: uniqueSquad5v5.length,
          squad7v7: uniqueSquad7v7.length,
          totalUnique: currentUniqueAfterDedup,
        },
        playersAdded: 0,
        playersRemoved: 0,
      };
    }
    // Otherwise continue to fix distribution
  }
  
  // Remove players that appear in both squads (keep only in one)
  const playersInBoth = uniqueSquad5v5.filter((id) => uniqueSquad7v7.includes(id));
  // Keep in squad7v7, remove from squad5v5
  const cleanedSquad5v5 = uniqueSquad5v5.filter((id) => !playersInBoth.includes(id));
  const cleanedSquad7v7 = uniqueSquad7v7;

  // Get current unique count after deduplication
  let currentUnique = getUniquePlayers(cleanedSquad5v5, cleanedSquad7v7).length;
  
  console.log(`🔍 ${teamName}: After deduplication - 5v5: ${cleanedSquad5v5.length}, 7v7: ${cleanedSquad7v7.length}, Total unique: ${currentUnique}, Target: ${targetCount}`);

  let playersToAdd: string[] = [];
  let playersToRemove: string[] = [];

  // Calculate how many players we need to reach exactly 15
  const needed = targetCount - currentUnique;
  
  if (needed > 0) {
    // Find free-agent players (players not in any team)
    const allTeams = await Team.find({});
    const playersInTeams = new Set<string>();
    
    allTeams.forEach((t: any) => {
      const squad5v5Ids = (t.squad5v5 || []).map((id: any) => id.toString());
      const squad7v7Ids = (t.squad7v7 || []).map((id: any) => id.toString());
      [...squad5v5Ids, ...squad7v7Ids].forEach((id: string) => playersInTeams.add(id));
    });
    
    console.log(`📊 ${teamName}: Current unique players: ${currentUnique}, Need: ${needed}`);
    console.log(`📊 ${teamName}: Players already in teams: ${playersInTeams.size}`);
    
    // Find available free-agent players (get more than needed to ensure we have enough)
    const playersInTeamsArray = Array.from(playersInTeams)
      .filter((id: string) => mongoose.Types.ObjectId.isValid(id))
      .map((id: string) => new mongoose.Types.ObjectId(id));
    
    console.log(`🔍 ${teamName}: Searching for free agents (excluding ${playersInTeamsArray.length} players already in teams)...`);
    
    // Use provided free agents if available, otherwise find them
    let freeAgents = availableFreeAgents;
    
    if (freeAgents.length === 0 || freeAgents.length < needed) {
      // Try to find players with role "player" OR "free-agent" (not in any team)
      // First try "free-agent" role (most likely to be available)
      let foundFreeAgents = await User.find({
        role: "free-agent",
        _id: { $nin: playersInTeamsArray },
      }).limit(needed + 10);
      
      // If not enough, also get "player" role users
      if (foundFreeAgents.length < needed) {
        const additionalNeeded = needed - foundFreeAgents.length;
        const playerRoleUsers = await User.find({
          role: "player",
          _id: { $nin: playersInTeamsArray },
        }).limit(additionalNeeded + 5);
        
        // Combine both
        foundFreeAgents = [...foundFreeAgents, ...playerRoleUsers];
      }
      
      // Combine with provided free agents
      const providedIds = new Set(freeAgents.map((p: any) => p._id.toString()));
      const newAgents = foundFreeAgents.filter((p: any) => !providedIds.has(p._id.toString()));
      freeAgents = [...freeAgents, ...newAgents];
    }
    
    console.log(`✅ ${teamName}: Found ${freeAgents.length} free agents (needed: ${needed})`);
    
    if (freeAgents.length === 0) {
      console.log(`❌ ${teamName}: No free agents available! Cannot add players.`);
      // Return with current state
      return {
        teamName,
        teamId,
        before,
        after: {
          squad5v5: cleanedSquad5v5.length,
          squad7v7: cleanedSquad7v7.length,
          totalUnique: currentUnique,
        },
        playersAdded: 0,
        playersRemoved: duplicates,
      };
    }
    
    if (freeAgents.length < needed) {
      console.log(`⚠️ ${teamName} needs ${needed} players, but only ${freeAgents.length} free agents available. Will add ${freeAgents.length} players.`);
    }
    
    // Add free agents - distribute between squads to reach exactly 15
    const freeAgentIds = freeAgents.map((p: any) => p._id.toString()).slice(0, needed);
    playersToAdd = [...freeAgentIds];
    console.log(`➕ ${teamName}: Adding ${freeAgentIds.length} players...`);
    
    // Current counts
    const current5v5Count = cleanedSquad5v5.length;
    const current7v7Count = cleanedSquad7v7.length;
    
    // Target distribution: 7 in squad5v5, 8 in squad7v7 (total 15)
    const target5v5 = 7;
    const target7v7 = 8;
    
    // Calculate how many to add to each squad
    const needed5v5 = Math.max(0, target5v5 - current5v5Count);
    const needed7v7 = Math.max(0, target7v7 - current7v7Count);
    
    // Add to squad5v5 first (up to 7 total)
    const addTo5v5 = freeAgentIds.slice(0, Math.min(needed5v5, freeAgentIds.length));
    cleanedSquad5v5.push(...addTo5v5);
    
    // Add remaining to squad7v7 (up to 8 total, but ensure total unique is 15)
    const remaining = freeAgentIds.slice(addTo5v5.length);
    const addTo7v7 = remaining.slice(0, Math.min(needed7v7, remaining.length));
    cleanedSquad7v7.push(...addTo7v7);
    
    // Check if we've reached 15 unique players
    currentUnique = getUniquePlayers(cleanedSquad5v5, cleanedSquad7v7).length;
    
    // If still need more to reach exactly 15, add to squad7v7
    if (currentUnique < targetCount) {
      const stillNeeded = targetCount - currentUnique;
      const extraAvailable = remaining.slice(addTo7v7.length);
      const extra = extraAvailable.slice(0, stillNeeded);
      if (extra.length > 0) {
        cleanedSquad7v7.push(...extra);
        playersToAdd = [...playersToAdd, ...extra];
        console.log(`➕ ${teamName}: Added ${extra.length} extra players to reach 15`);
      }
      currentUnique = getUniquePlayers(cleanedSquad5v5, cleanedSquad7v7).length;
    }
    
    console.log(`✅ ${teamName}: Final count - 5v5: ${cleanedSquad5v5.length}, 7v7: ${cleanedSquad7v7.length}, Total: ${currentUnique}`);
  } else if (currentUnique > targetCount) {
    // If we have more than targetCount, remove excess
    const excess = currentUnique - targetCount;
    // Remove from squad7v7 first (keep squad5v5 priority)
    const toRemove = cleanedSquad7v7.slice(-excess);
    playersToRemove = toRemove;
    cleanedSquad7v7.splice(-excess);
    currentUnique = targetCount;
  }

  // Update team
  team.squad5v5 = cleanedSquad5v5
    .filter((id: string) => mongoose.Types.ObjectId.isValid(id))
    .map((id: string) => new mongoose.Types.ObjectId(id));
  
  team.squad7v7 = cleanedSquad7v7
    .filter((id: string) => mongoose.Types.ObjectId.isValid(id))
    .map((id: string) => new mongoose.Types.ObjectId(id));

  await team.save();

  const afterUnique = getUniquePlayers(
    team.squad5v5.map((id: any) => id.toString()),
    team.squad7v7.map((id: any) => id.toString())
  );

  return {
    teamName,
    teamId,
    before,
    after: {
      squad5v5: team.squad5v5.length,
      squad7v7: team.squad7v7.length,
      totalUnique: afterUnique.length,
    },
    playersAdded: playersToAdd.length,
    playersRemoved: playersToRemove.length + duplicates,
  };
}

/**
 * Create test players if needed
 */
async function createTestPlayers(count: number): Promise<string[]> {
  const createdIds: string[] = [];
  
  for (let i = 0; i < count; i++) {
    const testPlayer = await User.create({
      firstName: `Test`,
      lastName: `Player${i + 1}`,
      email: `testplayer${Date.now()}-${i}@test.com`,
      role: "player",
      profileCompleted: false,
    });
    createdIds.push(testPlayer._id.toString());
    console.log(`✅ Created test player: ${testPlayer.firstName} ${testPlayer.lastName} (${testPlayer._id})`);
  }
  
  return createdIds;
}

/**
 * Main function to fix Phoenix and USHZ teams
 */
export async function fixTeamPlayersData(): Promise<{
  success: boolean;
  results: TeamFixResult[];
  message: string;
  playersCreated?: number;
}> {
  try {
    await connectDB();

    // Find Phoenix and USHZ teams (case-insensitive, flexible matching)
    const teams = await Team.find({
      $or: [
        { teamName: { $regex: /phoenix/i } },
        { teamName: { $regex: /pheonix/i } }, // Handle typo
        { teamName: { $regex: /^ushz$/i } },
      ],
    });

    if (teams.length === 0) {
      return {
        success: false,
        results: [],
        message: "Phoenix or USHZ teams not found",
      };
    }

    // Calculate total players needed
    let totalNeeded = 0;
    for (const team of teams) {
      const squad5v5 = (team.squad5v5 || []).map((id: any) => id.toString());
      const squad7v7 = (team.squad7v7 || []).map((id: any) => id.toString());
      const uniquePlayers = getUniquePlayers(squad5v5, squad7v7);
      const needed = 15 - uniquePlayers.length;
      if (needed > 0) totalNeeded += needed;
    }

    console.log(`📊 Total players needed: ${totalNeeded}`);

    // Get all teams and their players
    const allTeams = await Team.find({});
    const playersInTeams = new Set<string>();
    
    allTeams.forEach((t: any) => {
      const squad5v5Ids = (t.squad5v5 || []).map((id: any) => id.toString());
      const squad7v7Ids = (t.squad7v7 || []).map((id: any) => id.toString());
      [...squad5v5Ids, ...squad7v7Ids].forEach((id: string) => playersInTeams.add(id));
    });

    const playersInTeamsArray = Array.from(playersInTeams)
      .filter((id: string) => mongoose.Types.ObjectId.isValid(id))
      .map((id: string) => new mongoose.Types.ObjectId(id));

    // Find available free agents
    let freeAgents = await User.find({
      role: "free-agent",
      _id: { $nin: playersInTeamsArray },
    }).limit(totalNeeded + 10);
    
    if (freeAgents.length < totalNeeded) {
      const playerRoleUsers = await User.find({
        role: "player",
        _id: { $nin: playersInTeamsArray },
      }).limit(totalNeeded - freeAgents.length + 5);
      freeAgents = [...freeAgents, ...playerRoleUsers];
    }

    console.log(`📊 Available free agents: ${freeAgents.length}, Needed: ${totalNeeded}`);

    // If still not enough, create test players
    let playersCreated = 0;
    if (freeAgents.length < totalNeeded) {
      const toCreate = totalNeeded - freeAgents.length;
      console.log(`⚠️ Not enough free agents. Creating ${toCreate} test players...`);
      const createdIds = await createTestPlayers(toCreate);
      const createdUsers = await User.find({
        _id: { $in: createdIds.map((id: string) => new mongoose.Types.ObjectId(id)) },
      });
      freeAgents = [...freeAgents, ...createdUsers];
      playersCreated = toCreate;
      console.log(`✅ Created ${playersCreated} test players`);
    }

    const results: TeamFixResult[] = [];
    let freeAgentIndex = 0;

    for (const team of teams) {
      // Calculate how many players this team needs
      const squad5v5 = (team.squad5v5 || []).map((id: any) => id.toString());
      const squad7v7 = (team.squad7v7 || []).map((id: any) => id.toString());
      const uniquePlayers = getUniquePlayers(squad5v5, squad7v7);
      const needed = 15 - uniquePlayers.length;

      // Pass available free agents to the fix function
      const availableFreeAgents = freeAgents.slice(freeAgentIndex, freeAgentIndex + needed + 5);
      freeAgentIndex += needed;

      const result = await fixTeamPlayers(team, 15, availableFreeAgents);
      results.push(result);
    }

    return {
      success: true,
      results,
      message: `Fixed ${results.length} team(s)${playersCreated > 0 ? `, created ${playersCreated} test players` : ''}`,
      playersCreated,
    };
  } catch (error: any) {
    console.error("Error fixing team players:", error);
    return {
      success: false,
      results: [],
      message: error.message || "Failed to fix team players",
    };
  }
}

// If running directly (not imported)
if (require.main === module) {
  fixTeamPlayersData()
    .then((result) => {
      console.log(JSON.stringify(result, null, 2));
      process.exit(result.success ? 0 : 1);
    })
    .catch((error) => {
      console.error("Fatal error:", error);
      process.exit(1);
    });
}
