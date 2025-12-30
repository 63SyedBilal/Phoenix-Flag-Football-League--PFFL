import { NextRequest } from "next/server";
import { completeTournament } from "@/controller/tournament";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return completeTournament(req, { params: resolvedParams });
}
