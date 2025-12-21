import { NextRequest, NextResponse } from "next/server";
import { fixTeamPlayersData } from "@/scripts/fix-team-players";

/**
 * Admin endpoint to fix team player counts
 * POST /api/admin/fix-teams
 * 
 * Ensures Phoenix and USHZ teams have exactly 15 unique players each.
 * Removes duplicates and maintains data consistency.
 * Adds free-agent players if needed.
 * 
 * Can be called without auth for direct execution
 */
export async function POST(req: NextRequest) {
  try {
    // Run the fix directly
    console.log("🚀 Starting team players fix...");
    const result = await fixTeamPlayersData();
    console.log("✅ Team players fix completed:", JSON.stringify(result, null, 2));

    if (!result.success) {
      return NextResponse.json(
        { error: result.message, results: result.results },
        { status: 400 }
      );
    }

    // Include debug info in response
    const debugInfo = result.results.map((r: any) => ({
      teamName: r.teamName,
      before: r.before,
      after: r.after,
      playersAdded: r.playersAdded,
      playersRemoved: r.playersRemoved,
      status: r.after.totalUnique === 15 ? '✅ Complete' : `⚠️ Needs ${15 - r.after.totalUnique} more`,
    }));

    return NextResponse.json(
      {
        message: result.message,
        results: result.results,
        debug: debugInfo,
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("❌ Error in fix-teams endpoint:", error);
    return NextResponse.json(
      { error: error.message || "Failed to fix teams" },
      { status: 500 }
    );
  }
}
