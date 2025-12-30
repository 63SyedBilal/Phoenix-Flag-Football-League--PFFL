import { NextRequest, NextResponse } from "next/server";
import { bulkAssignOfficials } from "@/controller/league";

/**
 * Bulk assign officials to multiple matches
 * POST /api/league/:leagueId/assign-officials
 */
export async function POST(req: NextRequest, { params }: { params: Promise<{ id: string }> | { id: string } }) {
  try {
    const resolvedParams = await Promise.resolve(params);
    const result = await bulkAssignOfficials(req, { params: { leagueId: resolvedParams.id } });
    return result;
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || "Internal server error" },
      { status: 500 }
    );
  }
}
