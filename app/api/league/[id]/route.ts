import { NextRequest } from "next/server";
import { getLeague, updateLeague, deleteLeague } from "@/controller/league";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return getLeague(req, { params: resolvedParams });
}

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return updateLeague(req, { params: resolvedParams });
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return deleteLeague(req, { params: resolvedParams });
}

