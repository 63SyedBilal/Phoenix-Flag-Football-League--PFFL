import { NextRequest } from "next/server";
import { getTopTeams } from "@/controller/tournament";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return getTopTeams(req, { params: resolvedParams });
}
