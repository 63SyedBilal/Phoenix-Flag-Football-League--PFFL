import { NextRequest } from "next/server";
import { inviteTeam } from "@/controller/league-invite";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return inviteTeam(req, { params: { leagueId: resolvedParams.id } });
}

