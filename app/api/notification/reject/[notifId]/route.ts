import { NextRequest } from "next/server";
import { rejectInvite } from "@/controller/notification";

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ notifId: string }> | { notifId: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return rejectInvite(req, { params: resolvedParams });
}

