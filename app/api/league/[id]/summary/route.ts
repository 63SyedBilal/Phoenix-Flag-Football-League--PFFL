import { NextRequest } from "next/server";
import { getLeagueSummary } from "@/controller/league";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return getLeagueSummary(req, { params: resolvedParams });
}
