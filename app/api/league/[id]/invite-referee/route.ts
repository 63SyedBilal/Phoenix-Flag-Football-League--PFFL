import { NextRequest } from "next/server";
import { inviteReferee } from "@/controller/league-invite";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  console.log("Invite referee route - league ID from params:", resolvedParams.id);
  return inviteReferee(req, { params: { leagueId: resolvedParams.id } });
}

