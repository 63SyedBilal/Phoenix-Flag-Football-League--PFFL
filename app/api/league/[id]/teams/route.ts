import { NextRequest } from "next/server";
import { addTeamToLeague } from "@/controller/league";

export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return addTeamToLeague(req, { params });
}

