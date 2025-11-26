import { NextRequest } from "next/server";
import { updateSuperAdmin, deleteSuperAdmin } from "@/controller/superadmin";

export async function PUT(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return updateSuperAdmin(req, { params });
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return deleteSuperAdmin(req, { params });
}

