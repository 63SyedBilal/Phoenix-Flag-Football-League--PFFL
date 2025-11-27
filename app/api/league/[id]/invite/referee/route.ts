import { NextRequest } from "next/server";
import { inviteReferee } from "@/controller/league-invite";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return inviteReferee(req, { params: { leagueId: resolvedParams.id } });
}

