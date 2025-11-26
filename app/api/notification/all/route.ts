import { NextRequest } from "next/server";
import { getAllNotifications } from "@/controller/notification";

export async function GET(req: NextRequest) {
  return getAllNotifications(req);
}

