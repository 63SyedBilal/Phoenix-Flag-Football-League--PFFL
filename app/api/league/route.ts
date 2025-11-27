import { NextRequest } from "next/server";
import { createLeague, getAllLeagues } from "@/controller/league";

export async function POST(req: NextRequest) {
  return createLeague(req);
}

export async function GET(req: NextRequest) {
  return getAllLeagues(req);
}

