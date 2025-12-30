import { NextRequest, NextResponse } from "next/server";
import { sendPushNotification } from "@/controller/push-notification";

/**
 * Send push notification
 * POST /api/push-notification/send
 */
export async function POST(req: NextRequest) {
  return sendPushNotification(req);
}
