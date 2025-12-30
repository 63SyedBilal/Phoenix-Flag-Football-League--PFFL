import { NextRequest, NextResponse } from "next/server";
import { logErrorReport } from "@/controller/error-reporting";

/**
 * Log error report from mobile app
 * POST /api/error-report
 */
export async function POST(req: NextRequest) {
  return logErrorReport(req);
}
