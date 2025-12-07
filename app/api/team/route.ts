import { NextRequest } from "next/server";
import { createTeam, getAllTeams } from "@/controller/team";

export async function POST(req: NextRequest) {
  return createTeam(req);
}

export async function GET(req: NextRequest) {
  return getAllTeams(req);
}








