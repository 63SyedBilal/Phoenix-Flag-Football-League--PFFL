import { NextRequest } from "next/server";
import { getAllNotifications } from "@/controller/notification-handlers";

export async function GET(req: NextRequest) {
  return getAllNotifications(req);
}


