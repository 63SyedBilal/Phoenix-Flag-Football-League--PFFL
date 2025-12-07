import { NextRequest } from "next/server";
import { invitePlayer } from "@/controller/notification";

export async function POST(req: NextRequest) {
  return invitePlayer(req);
}








