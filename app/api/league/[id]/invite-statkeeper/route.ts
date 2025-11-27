import { NextRequest } from "next/server";
import { inviteStatKeeper } from "@/controller/league-invite";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  console.log("Invite stat keeper route - league ID from params:", resolvedParams.id);
  return inviteStatKeeper(req, { params: { leagueId: resolvedParams.id } });
}

