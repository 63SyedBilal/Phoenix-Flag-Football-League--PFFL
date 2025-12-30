import { NextRequest } from "next/server";
import { getTeamPlayerPayments } from "@/controller/team";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return getTeamPlayerPayments(req, { params: resolvedParams });
}
