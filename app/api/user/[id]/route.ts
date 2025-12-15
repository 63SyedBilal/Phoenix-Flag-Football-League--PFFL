import { NextRequest } from "next/server";
import { getUser, updateUser, deleteUser } from "@/controller/user";

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return getUser(req, { params });
}

export async function PUT(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return updateUser(req, { params });
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return deleteUser(req, { params });
}