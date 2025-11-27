import { NextRequest } from "next/server";
import { inviteStatKeeper } from "@/controller/league-invite";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return inviteStatKeeper(req, { params: { leagueId: resolvedParams.id } });
}

