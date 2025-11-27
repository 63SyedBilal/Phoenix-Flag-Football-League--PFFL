import { NextRequest } from "next/server";
import { removeTeamFromLeague } from "@/controller/league";

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string; teamId: string } }
) {
  return removeTeamFromLeague(req, { params });
}

