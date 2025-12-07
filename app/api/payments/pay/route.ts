import { NextRequest } from "next/server";
import { updatePayment } from "@/controller/payment";

export async function PATCH(req: NextRequest) {
  return updatePayment(req);
}






