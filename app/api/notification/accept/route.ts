import { NextRequest } from "next/server";
import { acceptNotification } from "@/controller/notification-handlers";

export async function POST(req: NextRequest) {
  return acceptNotification(req);
}

