import { NextRequest } from "next/server";
import { inviteStatKeeper } from "@/controller/league-invite";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> | { id: string } }
) {
  try {
    console.log("🚀 [ROUTE] /api/league/[id]/invite/statkeeper POST called");
    const resolvedParams = await Promise.resolve(params);
    console.log("🚀 [ROUTE] League ID from params:", resolvedParams.id);
    const result = await inviteStatKeeper(req, { params: { leagueId: resolvedParams.id } });
    console.log("🚀 [ROUTE] inviteStatKeeper completed, status:", result.status);
    return result;
  } catch (error: any) {
    console.error("❌ [ROUTE] Error in invite/statkeeper route:", error);
    console.error("❌ [ROUTE] Error message:", error?.message);
    console.error("❌ [ROUTE] Error stack:", error?.stack);
    throw error;
  }
}

