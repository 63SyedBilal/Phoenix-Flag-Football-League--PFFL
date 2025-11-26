import { NextRequest } from "next/server";
import { getUser } from "@/controller/user";

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  return getUser(req, { params });
}
