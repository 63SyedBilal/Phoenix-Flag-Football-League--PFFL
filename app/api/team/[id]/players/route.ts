import { NextRequest } from "next/server";
import { addPlayer } from "@/controller/team";

export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return addPlayer(req, { params });
}








