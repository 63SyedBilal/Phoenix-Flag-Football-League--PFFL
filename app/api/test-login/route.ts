import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  try {
    const { email, password } = await req.json();
    
    console.log("Attempting login with:", email);
    
    // Try to login with the provided credentials
    const response = await fetch("http://localhost:3000/api/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email,
        password,
      }),
    });
    
    const data = await response.json();
    
    console.log("Login response status:", response.status);
    console.log("Login response data:", data);
    
    return NextResponse.json(
      {
        success: response.status === 200,
        status: response.status,
        data: data,
      },
      { status: response.status === 200 ? 200 : response.status }
    );
  } catch (error: any) {
    console.error("Login test error:", error);
    return NextResponse.json(
      { 
        success: false,
        error: error.message,
      },
      { status: 500 }
    );
  }
}