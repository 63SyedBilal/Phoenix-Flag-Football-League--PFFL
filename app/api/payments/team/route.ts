import { NextRequest } from "next/server";
import { getTeamPayments } from "@/controller/payment";

export async function GET(req: NextRequest) {
  return getTeamPayments(req);
}
