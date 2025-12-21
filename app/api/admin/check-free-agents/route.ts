import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { Team, User } from "@/modules";
import mongoose from "mongoose";

/**
 * Check how many free agents are available
 * GET /api/admin/check-free-agents
 */
export async function GET(req: NextRequest) {
  try {
    await connectDB();

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

    // Count free agents
    const freeAgents = await User.find({
      $or: [
        { role: "free-agent", _id: { $nin: playersInTeamsArray } },
        { role: "player", _id: { $nin: playersInTeamsArray } },
      ],
    });

    // Count by role
    const freeAgentCount = freeAgents.filter((u: any) => u.role === "free-agent").length;
    const playerRoleCount = freeAgents.filter((u: any) => u.role === "player").length;

    return NextResponse.json(
      {
        totalFreeAgents: freeAgents.length,
        freeAgentRole: freeAgentCount,
        playerRole: playerRoleCount,
        playersInTeams: playersInTeamsArray.length,
        freeAgents: freeAgents.slice(0, 20).map((u: any) => ({
          id: u._id.toString(),
          name: `${u.firstName} ${u.lastName}`,
          email: u.email,
          role: u.role,
        })),
      },
      { status: 200 }
    );
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || "Failed to check free agents" },
      { status: 500 }
    );
  }
}
