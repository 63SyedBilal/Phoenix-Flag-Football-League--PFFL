import { NextRequest } from "next/server";
import { getAllUnpaidPayments } from "@/controller/payment";

export async function GET(req: NextRequest) {
  return getAllUnpaidPayments(req);
}






