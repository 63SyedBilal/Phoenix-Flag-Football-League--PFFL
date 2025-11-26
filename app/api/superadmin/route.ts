import { NextRequest } from "next/server";
import { createSuperAdmin } from "@/controller/superadmin";

export async function POST(req: NextRequest) {
  return createSuperAdmin(req);
}

