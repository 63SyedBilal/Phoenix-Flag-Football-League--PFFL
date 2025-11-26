import { NextRequest } from "next/server";
import { login } from "@/controller/login";

export async function POST(req: NextRequest) {
  return login(req);
}

