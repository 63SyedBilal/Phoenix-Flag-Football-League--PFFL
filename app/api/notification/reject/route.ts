import { NextRequest } from "next/server";
import { rejectNotification } from "@/controller/notification-handlers";

export async function POST(req: NextRequest) {
  return rejectNotification(req);
}

