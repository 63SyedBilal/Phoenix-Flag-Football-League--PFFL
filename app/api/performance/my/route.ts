import { NextRequest, NextResponse } from "next/server";
import { getMyPerformance } from "@/controller/performance";

/**
 * Get current user's performance statistics
 * GET /api/performance/my
 */
export async function GET(req: NextRequest) {
  return getMyPerformance(req);
}
