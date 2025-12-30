import { NextRequest } from "next/server";
import { getTournamentBracket } from "@/controller/tournament";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return getTournamentBracket(req, { params: resolvedParams });
}
