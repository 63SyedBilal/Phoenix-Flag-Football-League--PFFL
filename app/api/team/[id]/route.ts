import { NextRequest } from "next/server";
import { getTeam, updateTeam, deleteTeam } from "@/controller/team";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return getTeam(req, { params: resolvedParams });
}

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return updateTeam(req, { params: resolvedParams });
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return deleteTeam(req, { params: resolvedParams });
}








