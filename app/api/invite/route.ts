import { NextRequest } from "next/server";
import { inviteUser } from "@/controller/invite";

export async function POST(req: NextRequest) {
  return inviteUser(req);
}


