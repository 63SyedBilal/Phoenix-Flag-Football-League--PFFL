import { NextRequest, NextResponse } from "next/server";
import { sendEmailNotification } from "@/controller/email";

/**
 * Send email notification
 * POST /api/email/send
 */
export async function POST(req: NextRequest) {
  return sendEmailNotification(req);
}
