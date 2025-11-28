import { NextRequest } from "next/server";
import { getTeam, updateTeam, deleteTeam } from "@/controller/team";

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return getTeam(req, { params });
}

export async function PUT(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return updateTeam(req, { params });
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return deleteTeam(req, { params });
}




