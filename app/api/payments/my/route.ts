import { NextRequest } from "next/server";
import { getMyPayment } from "@/controller/payment";

export async function GET(req: NextRequest) {
  return getMyPayment(req);
}






