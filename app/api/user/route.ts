import { NextRequest } from "next/server";
import { createUser, getAllUsers } from "@/controller/user";

export async function POST(req: NextRequest) {
  return createUser(req);
}

export async function GET(req: NextRequest) {
  return getAllUsers(req);
}


