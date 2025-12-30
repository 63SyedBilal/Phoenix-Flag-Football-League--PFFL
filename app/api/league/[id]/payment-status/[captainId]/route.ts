import { NextRequest } from "next/server";
import { checkLeaguePaymentStatus } from "@/controller/league";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string, captainId: string }> | { id: string, captainId: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return checkLeaguePaymentStatus(req, { params: resolvedParams });
}
