import { NextRequest } from "next/server";
import { getPaymentReminders } from "@/controller/payment";

export async function GET(req: NextRequest) {
  return getPaymentReminders(req);
}

