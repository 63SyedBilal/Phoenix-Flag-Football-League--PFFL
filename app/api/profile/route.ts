import { NextRequest, NextResponse } from "next/server";
import { createProfile, getAllProfiles } from "@/controller/profile";

// CORS headers helper
function getCorsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age': '86400',
  };
}

// Handle preflight OPTIONS request
export async function OPTIONS() {
  return NextResponse.json({}, { headers: getCorsHeaders() });
}

export async function POST(req: NextRequest) {
  try {
    const response = await createProfile(req);
    const headers = new Headers(response.headers);
    Object.entries(getCorsHeaders()).forEach(([key, value]) => {
      headers.set(key, value);
    });
    return new NextResponse(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: headers,
    });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500, headers: getCorsHeaders() }
    );
  }
}

export async function GET(req: NextRequest) {
  try {
    const response = await getAllProfiles(req);
    const headers = new Headers(response.headers);
    Object.entries(getCorsHeaders()).forEach(([key, value]) => {
      headers.set(key, value);
    });
    return new NextResponse(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: headers,
    });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500, headers: getCorsHeaders() }
    );
  }
}








