import { NextRequest } from "next/server";
import { getTeamByCode } from "@/controller/team";

export async function GET(
  req: NextRequest,
  { params }: { params: { code: string } }
) {
  return getTeamByCode(req, { params });
}








