import { NextRequest } from "next/server";
import { getProfile, updateProfile, deleteProfile } from "@/controller/profile";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return getProfile(req, { params: resolvedParams });
}

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return updateProfile(req, { params: resolvedParams });
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  const resolvedParams = await Promise.resolve(params);
  return deleteProfile(req, { params: resolvedParams });
}








