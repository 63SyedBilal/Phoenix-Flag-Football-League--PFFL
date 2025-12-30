import { NextRequest, NextResponse } from "next/server";
import { getAvailableStatKeepers } from "@/controller/league";

/**
 * Get available stat keepers for a league on a specific date
 * GET /api/league/:leagueId/available-statkeepers?date=2024-01-01
 */
export async function GET(req: NextRequest, { params }: { params: Promise<{ id: string }> | { id: string } }) {
  try {
    const resolvedParams = await Promise.resolve(params);
    const result = await getAvailableStatKeepers(req, { params: { leagueId: resolvedParams.id } });
    return result;
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || "Internal server error" },
      { status: 500 }
    );
  }
}
