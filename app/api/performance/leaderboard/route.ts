import { NextRequest, NextResponse } from "next/server";
import { getLeaderboard } from "@/controller/performance";

/**
 * Get performance leaderboard
 * GET /api/performance/leaderboard?limit=10
 */
export async function GET(req: NextRequest) {
  return getLeaderboard(req);
}
