import { NextRequest, NextResponse } from "next/server";
import { logApplicationLog } from "@/controller/error-reporting";

/**
 * Log application logs from mobile app
 * POST /api/error-log
 */
export async function POST(req: NextRequest) {
  return logApplicationLog(req);
}
