import { NextRequest } from "next/server";
import { createProfile, getAllProfiles } from "@/controller/profile";

export async function POST(req: NextRequest) {
  return createProfile(req);
}

export async function GET(req: NextRequest) {
  return getAllProfiles(req);
}


