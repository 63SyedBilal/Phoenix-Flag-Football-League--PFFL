import { NextRequest, NextResponse } from "next/server";
import { submitStatsForApproval } from "@/controller/stat";

// Handle CORS preflight
export async function OPTIONS() {
    return new NextResponse(null, {
        status: 200,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization",
        },
    });
}

export async function POST(req: NextRequest) {
    try {
        const response = await submitStatsForApproval(req);
        const headers = new Headers(response.headers);
        headers.set("Access-Control-Allow-Origin", "*");
        headers.set("Access-Control-Allow-Methods", "POST, OPTIONS");
        headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
        return new NextResponse(response.body, {
            status: response.status,
            headers,
        });
    } catch (error: any) {
        return NextResponse.json(
            { error: error.message || "Internal server error" },
            { status: 500, headers: { "Access-Control-Allow-Origin": "*" } }
        );
    }
}
