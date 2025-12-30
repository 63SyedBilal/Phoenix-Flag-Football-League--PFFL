import { NextRequest } from "next/server";
import { removePlayerFromTeam } from "@/controller/team";

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string, playerId: string }> | { id: string, playerId: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return removePlayerFromTeam(req, { params: resolvedParams });
}
