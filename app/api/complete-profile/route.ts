import { NextRequest } from "next/server";
import { completeProfile } from "@/controller/complete-profile";

export async function PUT(req: NextRequest) {
  return completeProfile(req);
}









