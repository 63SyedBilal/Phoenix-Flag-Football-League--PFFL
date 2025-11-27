import { NextRequest } from "next/server";
import { updatePayment } from "@/controller/payment";

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return updatePayment(req, { params: resolvedParams });
}

