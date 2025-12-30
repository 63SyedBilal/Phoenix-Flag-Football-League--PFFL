import { NextRequest } from "next/server";
import { setMatchWinner } from "@/controller/tournament";

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return setMatchWinner(req, { params: resolvedParams });
}
