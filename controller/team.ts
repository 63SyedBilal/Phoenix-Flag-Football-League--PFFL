import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { Team, User } from "@/modules";
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
      .populate("captain", "firstName lastName email role")
      .populate("squad5v5", "firstName lastName email role")
      .populate("squad7v7", "firstName lastName email role")
      .populate("players", "firstName lastName email role");

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
      .populate("captain", "firstName lastName email role")
      .populate("squad5v5", "firstName lastName email role")
      .populate("squad7v7", "firstName lastName email role")
      .populate("players", "firstName lastName email role");

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
      .populate("captain", "firstName lastName email role")
      .populate("squad5v5", "firstName lastName email role")
      .populate("squad7v7", "firstName lastName email role")
      .populate("players", "firstName lastName email role");

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
    const decoded = await verifyUser(req);

    const { searchParams } = new URL(req.url);
    const captainId = searchParams.get("captainId");
    const playerId = searchParams.get("playerId");

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

    const teams = await Team.find(query)
      .populate("captain", "firstName lastName email role")
      .populate("squad5v5", "firstName lastName email role")
      .populate("squad7v7", "firstName lastName email role")
      .populate("players", "firstName lastName email role")
      .sort({ createdAt: -1 })
      .exec();

    // If captainId or playerId was provided, return single team or null
    if (singleTeam) {
      const team = teams.length > 0 ? teams[0] : null;
      return NextResponse.json(
        {
          message: team ? "Team retrieved successfully" : "Team not found",
          data: team,
        },
        { status: team ? 200 : 404 }
      );
    }

    return NextResponse.json(
      {
        message: "Teams retrieved successfully",
        data: teams,
      },
      { status: 200 }
    );
  } catch (error: any) {
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
    await team.populate("captain", "firstName lastName email role");
    await team.populate("players", "firstName lastName email role");

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

    await team.populate("captain", "firstName lastName email role");
    await (team as any).populate("squad5v5", "firstName lastName email role");
    await (team as any).populate("squad7v7", "firstName lastName email role");
    await (team as any).populate("players", "firstName lastName email role");

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

    await team.populate("captain", "firstName lastName email role");
    await (team as any).populate("squad5v5", "firstName lastName email role");
    await (team as any).populate("squad7v7", "firstName lastName email role");
    await (team as any).populate("players", "firstName lastName email role");

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

