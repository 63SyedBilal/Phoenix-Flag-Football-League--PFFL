import { NextRequest, NextResponse } from "next/server";
import { transferLeadership } from "@/controller/team";

/**
 * Transfer team leadership to another player
 * PUT /api/team/:id/transfer-leadership
 */
export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  return transferLeadership(req, { params });
}
