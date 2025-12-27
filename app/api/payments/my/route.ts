import { NextRequest } from "next/server";
import { getMyPayment, getAllMyPayments } from "@/controller/payment";

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const leagueId = searchParams.get("leagueId");

  // If leagueId is provided, get specific payment (existing behavior)
  if (leagueId) {
    return getMyPayment(req);
  }

  // If no leagueId, get all payments for the user
  return getAllMyPayments(req);
}