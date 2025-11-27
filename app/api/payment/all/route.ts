import { NextRequest } from "next/server";
import { getAllPayments } from "@/controller/payment";

export async function GET(req: NextRequest) {
  return getAllPayments(req);
}

