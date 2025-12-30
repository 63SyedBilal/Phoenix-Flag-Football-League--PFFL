import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { Team, User } from "@/modules";
import { verifyAccessToken } from "@/lib/jwt";
import { toObjectId } from "@/lib/db";
import Payment from "@/modules/payment";

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
 * Create team (only captains can create)
 * POST /api/team
 */
export async function createTeam(req: NextRequest) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);
    
    const { teamName, enterCode, location, skillLevel, image, squad5v5, squad7v7 } = await req.json();

    // Verify user is a captain
    const user = await User.findById(decoded.userId);
    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    if (user.role !== "captain") {
      return NextResponse.json({ error: "Only captains can create teams" }, { status: 403 });
    }

    // Check if team already exists for this captain
    const existingTeam = await Team.findOne({ captain: decoded.userId });
    if (existingTeam) {
      return NextResponse.json({ error: "Team already exists for this captain" }, { status: 409 });
    }

    // Auto-generate enterCode if not provided
    let finalEnterCode = enterCode?.trim();
    if (!finalEnterCode || finalEnterCode === '') {
      // Generate a unique code based on team name and timestamp
      const timestamp = Date.now().toString().slice(-6); // Last 6 digits
      const teamNameCode = teamName.trim().substring(0, Math.min(3, teamName.length)).toUpperCase().replace(/[^A-Z0-9]/g, '');
      finalEnterCode = `${teamNameCode}${timestamp}`;
    }

    // Check if enterCode already exists, regenerate if needed
    let codeExists = true;
    let attempts = 0;
    while (codeExists && attempts < 10) {
      const existingCode = await Team.findOne({ enterCode: finalEnterCode });
      if (!existingCode) {
        codeExists = false;
      } else {
        // If code exists, generate a new one
        const timestamp = Date.now().toString().slice(-6);
        const teamNameCode = teamName.trim().substring(0, Math.min(3, teamName.length)).toUpperCase().replace(/[^A-Z0-9]/g, '');
        finalEnterCode = `${teamNameCode}${timestamp}${attempts}`;
        attempts++;
      }
    }

    // Validate squad5v5 if provided
    if (squad5v5 && Array.isArray(squad5v5) && squad5v5.length > 0) {
      const validPlayers = await User.find({ 
        _id: { $in: squad5v5 },
        role: "player"
      });
      
      if (validPlayers.length !== squad5v5.length) {
        return NextResponse.json({ error: "Some player IDs in squad5v5 are invalid" }, { status: 400 });
      }
    }

    // Validate squad7v7 if provided
    if (squad7v7 && Array.isArray(squad7v7) && squad7v7.length > 0) {
      const validPlayers = await User.find({ 
        _id: { $in: squad7v7 },
        role: "player"
      });
      
      if (validPlayers.length !== squad7v7.length) {
        return NextResponse.json({ error: "Some player IDs in squad7v7 are invalid" }, { status: 400 });
      }
    }

    if (!teamName || !location) {
      return NextResponse.json({ error: "Team name and location are required" }, { status: 400 });
    }

    const teamData: any = {
      teamName: teamName.trim(),
      enterCode: finalEnterCode,
      location: location.trim(),
      skillLevel: skillLevel || "beginner",
      image: image || "",
      captain: decoded.userId,
      squad5v5: squad5v5 && Array.isArray(squad5v5) ? squad5v5 : [],
      squad7v7: squad7v7 && Array.isArray(squad7v7) ? squad7v7 : [],
    };

    const team = await Team.create(teamData);

    // Populate captain and squads
    const populatedTeam = await Team.findById((team as any)._id)
      .populate("captain", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad5v5", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad7v7", "firstName lastName email role profileImage jerseyNumber position");

    return NextResponse.json(
      {
        message: "Team created successfully",
        data: populatedTeam,
      },
      { status: 201 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    if (error.code === 11000) {
      if (error.keyPattern?.enterCode) {
        return NextResponse.json({ error: "Enter code already exists" }, { status: 409 });
      }
      if (error.keyPattern?.captain) {
        return NextResponse.json({ error: "Team already exists for this captain" }, { status: 409 });
      }
    }
    return NextResponse.json({ error: error.message || "Failed to create team" }, { status: 500 });
  }
}

/**
 * Get team by ID
 * GET /api/team/:id
 */
export async function getTeam(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { id } = params;

    const team = await Team.findById(id)
      .populate("captain", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad5v5", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad7v7", "firstName lastName email role profileImage jerseyNumber position");

    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    return NextResponse.json(
      {
        message: "Team retrieved successfully",
        data: team,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get team" }, { status: 500 });
  }
}

/**
 * Get team by enter code
 * GET /api/team/code/:code
 */
export async function getTeamByCode(req: NextRequest, { params }: { params: { code: string } }) {
  try {
    await connectDB();
    await verifyUser(req);

    const { code } = params;

    const team = await Team.findOne({ enterCode: code })
      .populate("captain", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad5v5", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad7v7", "firstName lastName email role profileImage jerseyNumber position");

    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    return NextResponse.json(
      {
        message: "Team retrieved successfully",
        data: team,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get team" }, { status: 500 });
  }
}

/**
 * Get all teams or team by captain/player
 * GET /api/team?captainId=xxx or GET /api/team?playerId=xxx
 */
export async function getAllTeams(req: NextRequest) {
  try {
    await connectDB();
    // Log the incoming request for debugging
    console.log("🔵 getAllTeams called");
    console.log("🔵 Request URL:", req.url);
    
    // Try to verify user but handle errors gracefully
    let decoded = null;
    try {
      decoded = await verifyUser(req);
      console.log("✅ User verified:", decoded);
    } catch (verifyError: any) {
      console.log("⚠️ User verification failed:", verifyError?.message || verifyError);
      // Continue without user verification for now
    }

    const { searchParams } = new URL(req.url);
    const captainId = searchParams.get("captainId");
    const playerId = searchParams.get("playerId");

    console.log("🔍 Query parameters - captainId:", captainId, "playerId:", playerId);

    let query: any = {};
    let singleTeam = false;
    
    // If captainId is provided, get team for that captain
    if (captainId) {
      query.captain = captainId;
      singleTeam = true;
    }
    
    // If playerId is provided, get team where player is in either squad
    if (playerId) {
      query.$or = [
        { squad5v5: playerId },
        { squad7v7: playerId }
      ];
      singleTeam = true;
    }

    console.log("🔍 Query:", query);
    console.log("🔍 Fetching teams from database...");

    const teams = await Team.find(query)
      .populate("captain", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad5v5", "firstName lastName email role profileImage jerseyNumber position")
      .populate("squad7v7", "firstName lastName email role profileImage jerseyNumber position")
      .sort({ createdAt: -1 })
      .exec();

    console.log("✅ Found", teams.length, "teams");

    // If captainId or playerId was provided, return single team or null
    if (singleTeam) {
      const team = teams.length > 0 ? teams[0] : null;
      console.log("📤 Returning single team response");
      return NextResponse.json(
        {
          message: team ? "Team retrieved successfully" : "Team not found",
          data: team,
        },
        { status: team ? 200 : 404 }
      );
    }

    console.log("📤 Returning all teams response");
    return NextResponse.json(
      {
        message: "Teams retrieved successfully",
        data: teams,
      },
      { status: 200 }
      );
  } catch (error: any) {
    console.error("❌ getAllTeams error:", error);
    console.error("❌ Error stack:", error.stack);
    
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to get teams" }, { status: 500 });
  }
}

/**
 * Update team
 * PUT /api/team/:id
 */
export async function updateTeam(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id } = params;
    const { teamName, enterCode, location, skillLevel, image, squad5v5, squad7v7 } = await req.json();

    const team = await Team.findById(id);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    // Verify user is the captain of this team
    if (team.captain.toString() !== decoded.userId) {
      return NextResponse.json({ error: "Unauthorized to update this team" }, { status: 403 });
    }

    if (teamName !== undefined) {
      team.teamName = teamName.trim();
    }

    if (enterCode !== undefined) {
      // Check if enterCode already exists (excluding current team)
      const existingCode = await Team.findOne({ 
        enterCode: enterCode.trim(), 
        _id: { $ne: id } 
      });
      if (existingCode) {
        return NextResponse.json({ error: "Enter code already exists" }, { status: 409 });
      }
      team.enterCode = enterCode.trim();
    }

    if (location !== undefined) {
      team.location = location.trim();
    }

    if (skillLevel !== undefined) {
      if (!["beginner", "intermediate", "advanced", "professional"].includes(skillLevel)) {
        return NextResponse.json({ error: "Invalid skill level" }, { status: 400 });
      }
      team.skillLevel = skillLevel;
    }

    if (image !== undefined) {
      team.image = image;
    }

    if (squad5v5 !== undefined) {
      if (Array.isArray(squad5v5)) {
        // Validate all players exist and have player role
        const validPlayers = await User.find({ 
          _id: { $in: squad5v5 },
          role: "player"
        });
        
        if (validPlayers.length !== squad5v5.length) {
          return NextResponse.json({ error: "Some player IDs in squad5v5 are invalid" }, { status: 400 });
        }
        
        (team as any).squad5v5 = squad5v5;
      }
    }

    if (squad7v7 !== undefined) {
      if (Array.isArray(squad7v7)) {
        // Validate all players exist and have player role
        const validPlayers = await User.find({ 
          _id: { $in: squad7v7 },
          role: "player"
        });
        
        if (validPlayers.length !== squad7v7.length) {
          return NextResponse.json({ error: "Some player IDs in squad7v7 are invalid" }, { status: 400 });
        }
        
        (team as any).squad7v7 = squad7v7;
      }
    }

    await team.save();

    // Populate before returning
    await team.populate("captain", "firstName lastName email role profileImage jerseyNumber position");
    await team.populate("squad5v5", "firstName lastName email role profileImage jerseyNumber position");
    await team.populate("squad7v7", "firstName lastName email role profileImage jerseyNumber position");

    return NextResponse.json(
      {
        message: "Team updated successfully",
        data: team,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    if (error.code === 11000) {
      if (error.keyPattern?.enterCode) {
        return NextResponse.json({ error: "Enter code already exists" }, { status: 409 });
      }
    }
    return NextResponse.json({ error: error.message || "Failed to update team" }, { status: 500 });
  }
}

/**
 * Delete team
 * DELETE /api/team/:id
 */
export async function deleteTeam(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id } = params;

    const team = await Team.findById(id);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    // Verify user is the captain of this team
    if (team.captain.toString() !== decoded.userId) {
      return NextResponse.json({ error: "Unauthorized to delete this team" }, { status: 403 });
    }

    await Team.findByIdAndDelete(id);

    return NextResponse.json({ message: "Team deleted successfully" }, { status: 200 });
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to delete team" }, { status: 500 });
  }
}

/**
 * Add player to team squad
 * POST /api/team/:id/players
 * Body: { playerId: string, format: "5v5" | "7v7" }
 */
export async function addPlayer(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id } = params;
    const { playerId, format } = await req.json();

    if (!playerId || !format) {
      return NextResponse.json({ error: "Player ID and format are required" }, { status: 400 });
    }

    if (!["5v5", "7v7"].includes(format)) {
      return NextResponse.json({ error: "Format must be either '5v5' or '7v7'" }, { status: 400 });
    }

    const team = await Team.findById(id);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    // Verify user is the captain of this team
    if (team.captain.toString() !== decoded.userId) {
      return NextResponse.json({ error: "Unauthorized to modify this team" }, { status: 403 });
    }

    // Check if player exists and has player role
    const player = await User.findById(playerId);
    if (!player) {
      return NextResponse.json({ error: "Player not found" }, { status: 404 });
    }

    if (player.role !== "player") {
      return NextResponse.json({ error: "User is not a player" }, { status: 400 });
    }

    const squadField = format === "5v5" ? "squad5v5" : "squad7v7";
    const squad = (team as any)[squadField];

    // Check if player is already in the squad
    if (squad.includes(playerId)) {
      return NextResponse.json({ error: `Player already in ${format} squad` }, { status: 409 });
    }

    squad.push(playerId);
    await team.save();

    await team.populate("captain", "firstName lastName email role profileImage jerseyNumber position");
    await team.populate("squad5v5", "firstName lastName email role profileImage jerseyNumber position");
    await team.populate("squad7v7", "firstName lastName email role profileImage jerseyNumber position");

    return NextResponse.json(
      {
        message: `Player added to ${format} squad successfully`,
        data: team,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to add player" }, { status: 500 });
  }
}

/**
 * Remove player from team
 * DELETE /api/team/:id/players/:playerId
 */
export async function removePlayer(req: NextRequest, { params }: { params: { id: string; playerId: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id, playerId } = params;

    const team = await Team.findById(id);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    // Verify user is the captain of this team
    if (team.captain.toString() !== decoded.userId) {
      return NextResponse.json({ error: "Unauthorized to modify this team" }, { status: 403 });
    }

    const { searchParams } = new URL(req.url);
    const format = searchParams.get("format");

    if (!format || !["5v5", "7v7"].includes(format)) {
      return NextResponse.json({ error: "Format query parameter is required and must be '5v5' or '7v7'" }, { status: 400 });
    }

    const squadField = format === "5v5" ? "squad5v5" : "squad7v7";
    const squad = (team as any)[squadField];

    // Check if player is in the squad
    if (!squad.includes(playerId)) {
      return NextResponse.json({ error: `Player not in ${format} squad` }, { status: 404 });
    }

    // Remove player from squad
    (team as any)[squadField] = squad.filter(
      (p: any) => p.toString() !== playerId
    );
    
    await team.save();

    await team.populate("captain", "firstName lastName email role profileImage jerseyNumber position");
    await team.populate("squad5v5", "firstName lastName email role profileImage jerseyNumber position");
    await team.populate("squad7v7", "firstName lastName email role profileImage jerseyNumber position");

    return NextResponse.json(
      {
        message: "Player removed successfully",
        data: team,
      },
      { status: 200 }
    );
  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to remove player" }, { status: 500 });
  }
}

/**
 * Transfer team leadership to another player
 * PUT /api/team/:id/transfer-leadership
 */
export async function transferLeadership(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const teamId = params.id;
    const { newCaptainId } = await req.json();

    // Validate input
    if (!newCaptainId) {
      return NextResponse.json({ error: "newCaptainId is required" }, { status: 400 });
    }

    // Find the team
    const team = await Team.findById(teamId);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    // Verify current user is the captain
    if (team.captain.toString() !== decoded.userId) {
      return NextResponse.json({ error: "Only the current captain can transfer leadership" }, { status: 403 });
    }

    // Verify new captain is a member of the team
    if (!team.players.includes(newCaptainId)) {
      return NextResponse.json({ error: "New captain must be a current team member" }, { status: 400 });
    }

    // Get user details for notifications
    const currentCaptain = await User.findById(decoded.userId);
    const newCaptain = await User.findById(newCaptainId);

    if (!currentCaptain || !newCaptain) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Update team captain
    team.captain = newCaptainId;
    await team.save();

    // Create notification for the new captain
    await Notification.create({
      sender: decoded.userId,
      receiver: newCaptainId,
      team: teamId,
      league: team.league,
      type: "LEADERSHIP_RECEIVED",
      status: "pending",
      message: `You are now the captain of ${team.teamName}. Leadership transferred from ${currentCaptain.firstName} ${currentCaptain.lastName}`,
      data: {
        teamName: team.teamName,
        oldCaptainName: `${currentCaptain.firstName} ${currentCaptain.lastName}`,
        captainName: `${newCaptain.firstName} ${newCaptain.lastName}`
      }
    });

    // Create notification for the old captain
    await Notification.create({
      sender: decoded.userId,
      receiver: decoded.userId,
      team: teamId,
      league: team.league,
      type: "LEADERSHIP_TRANSFERRED",
      status: "pending",
      message: `Team leadership of ${team.teamName} has been transferred to ${newCaptain.firstName} ${newCaptain.lastName}`,
      data: {
        teamName: team.teamName,
        captainName: `${newCaptain.firstName} ${newCaptain.lastName}`,
        oldCaptainName: `${currentCaptain.firstName} ${currentCaptain.lastName}`
      }
    });

    console.log(`👑 Leadership transferred from ${currentCaptain.firstName} ${currentCaptain.lastName} to ${newCaptain.firstName} ${newCaptain.lastName} for team ${team.teamName}`);

    return NextResponse.json({
      success: true,
      message: "Leadership transferred successfully",
      data: {
        teamId: team._id,
        oldCaptain: {
          id: currentCaptain._id,
          name: `${currentCaptain.firstName} ${currentCaptain.lastName}`
        },
        newCaptain: {
          id: newCaptain._id,
          name: `${newCaptain.firstName} ${newCaptain.lastName}`
        }
      }
    });

  } catch (error: any) {
    if (error.message === "No token provided" || error.message === "Invalid token") {
      return NextResponse.json({ error: error.message }, { status: 401 });
    }
    return NextResponse.json({ error: error.message || "Failed to transfer leadership" }, { status: 500 });
  }
}

/**
 * Remove a player from team
 * DELETE /api/team/:id/remove-player/:playerId
 */
export async function removePlayerFromTeam(req: NextRequest, { params }: { params: { id: string, playerId: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id: teamId, playerId } = params;

    // Find the team
    const team = await Team.findById(teamId);
    if (!team) {
      return NextResponse.json({ error: "Team not found" }, { status: 404 });
    }

    // Verify current user is the captain
    if (team.captain.toString() !== decoded.userId) {
      return NextResponse.json({ error: "Only the captain can remove players" }, { status: 403 });
    }

    // Cannot remove the captain
    if (team.captain.toString() === playerId) {
      return NextResponse.json({ error: "Cannot remove the captain from the team" }, { status: 400 });
    }

    // Check if player is in the team
    const isPlayerInTeam = team.players.includes(playerId);
    if (!isPlayerInTeam) {
      return NextResponse.json({ error: "Player is not a member of this team" }, { status: 400 });
    }

    // Get player details for notification
    const playerToRemove = await User.findById(playerId);
    const captain = await User.findById(decoded.userId);

    if (!playerToRemove || !captain) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Remove player from team
    team.players = team.players.filter((player: any) => player.toString() !== playerId);
    await team.save();

    // Update user's role back to free agent if they were a player
    await User.findByIdAndUpdate(playerId, { role: "freeagent" });

    // Create notification for the removed player
    await Notification.create({
      sender: decoded.userId,
      receiver: playerId,
      team: teamId,
      league: team.league,
      type: "REMOVED_FROM_TEAM",
      status: "pending",
      message: `You have been removed from ${team.teamName}`,
      data: {
        teamName: team.teamName,
        captainName: `${captain.firstName} ${captain.lastName}`,
        playerName: `${playerToRemove.firstName} ${playerToRemove.lastName}`
      }
    });

    console.log(`👤 Player ${playerToRemove.firstName} ${playerToRemove.lastName} removed from team ${team.teamName}`);

    return NextResponse.json({
      success: true,
      message: "Player removed successfully",
      data: {
        teamId: team._id,
        removedPlayer: {
          id: playerToRemove._id,
          name: `${playerToRemove.firstName} ${playerToRemove.lastName}`
        }
      }
    });
  } catch (error: any) {
    console.error("Error removing player from team:", error);
    return NextResponse.json({ error: error.message || "Failed to remove player" }, { status: 500 });
  }
}

/**
 * Get player payment statuses for a captain's team
 * GET /api/team/:teamId/player-payments
 */
export async function getTeamPlayerPayments(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const decoded = await verifyUser(req);

    const { id: teamId } = params;
    console.log("Getting player payments for team:", teamId);

    const teamObjectId = toObjectId(teamId);
    console.log("Team ObjectId:", teamObjectId);

    // Find the team and ensure the user is the captain
    const team = await Team.findById(teamObjectId);
    console.log("Found team:", team ? "yes" : "no");

    if (!team) {
      console.log("Team not found for ID:", teamId);
      // For now, return empty payment status instead of error
      return NextResponse.json({
        success: true,
        data: {
          teamId: teamId,
          paymentStatuses: {},
          totalPlayers: 0,
          paidPlayers: 0,
        }
      }, { status: 200 });
    }

    console.log("Team captain:", team.captain?.toString());
    console.log("Requesting user:", decoded.userId);

    if (team.captain.toString() !== decoded.userId) {
      console.log("User is not the captain of this team");
      return NextResponse.json({ error: "Only the team captain can view payment statuses" }, { status: 403 });
    }

    // Get all player IDs from the team
    const playerIds = [];
    if (team.squad5v5 && Array.isArray(team.squad5v5)) {
      playerIds.push(...team.squad5v5);
    }
    if (team.squad7v7 && Array.isArray(team.squad7v7)) {
      playerIds.push(...team.squad7v7);
    }
    // Add captain
    playerIds.push(team.captain);

    // Remove duplicates
    const uniquePlayerIds = [...new Set(playerIds.map(id => id.toString()))];
    console.log("Player IDs found:", uniquePlayerIds);

    // Get payment statuses for all players in the team
    const payments = await Payment.find({
      userId: { $in: uniquePlayerIds },
      status: "completed" // Only completed payments count
    });

    console.log("Found payments:", payments.length);

    // Create payment status map
    const paymentStatusMap: { [key: string]: boolean } = {};
    for (const playerId of uniquePlayerIds) {
      const hasPayment = payments.some(payment =>
        payment.userId.toString() === playerId
      );
      paymentStatusMap[playerId] = hasPayment;
      console.log(`Player ${playerId}: paid = ${hasPayment}`);
    }

    return NextResponse.json({
      success: true,
      data: {
        teamId: teamId,
        paymentStatuses: paymentStatusMap,
        totalPlayers: uniquePlayerIds.length,
        paidPlayers: Object.values(paymentStatusMap).filter(status => status).length,
      }
    }, { status: 200 });

  } catch (error: any) {
    console.error("Error getting team player payments:", error);
    console.error("Error stack:", error.stack);
    return NextResponse.json({
      error: error.message || "Failed to get team player payments"
    }, { status: 500 });
  }
}

