import { NextRequest } from "next/server";
import { removePlayer } from "@/controller/team";

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string; playerId: string } }
) {
  return removePlayer(req, { params });
}








