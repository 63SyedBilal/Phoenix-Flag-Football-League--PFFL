import { NextRequest } from "next/server";
import { getProfile, updateProfile, deleteProfile } from "@/controller/profile";

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return getProfile(req, { params });
}

export async function PUT(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return updateProfile(req, { params });
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return deleteProfile(req, { params });
}

