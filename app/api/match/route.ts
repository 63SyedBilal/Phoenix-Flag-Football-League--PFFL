import { NextRequest, NextResponse } from "next/server";
import { createMatch, getAllMatches } from "@/controller/match";

// Handle CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  });
}

export async function POST(req: NextRequest) {
  try {
    const response = await createMatch(req);
    // Add CORS headers
    const headers = new Headers(response.headers);
    headers.set("Access-Control-Allow-Origin", "*");
    headers.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    return new NextResponse(response.body, {
      status: response.status,
      headers,
    });
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || "Internal server error" },
      {
        status: 500,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log("🔵 GET /api/match called");
    const response = await getAllMatches(req);
    console.log("✅ getAllMatches response status:", response.status);
    // Add CORS headers
    const headers = new Headers(response.headers);
    headers.set("Access-Control-Allow-Origin", "*");
    headers.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    return new NextResponse(response.body, {
      status: response.status,
      headers,
    });
  } catch (error: any) {
    console.error("❌ Route handler error:", error);
    console.error("Error message:", error.message);
    console.error("Error stack:", error.stack);
    return NextResponse.json(
      { 
        error: error.message || "Internal server error",
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      },
      {
        status: 500,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

