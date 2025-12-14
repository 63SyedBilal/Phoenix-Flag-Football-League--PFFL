import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";

export async function GET(req: NextRequest) {
  try {
    console.log("Attempting to connect to database...");
    await connectDB();
    console.log("Database connected successfully!");
    
    return NextResponse.json(
      { 
        message: "Database connection successful!",
        timestamp: new Date().toISOString()
      },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Database connection error:", error);
    return NextResponse.json(
      { 
        error: "Database connection failed",
        message: error.message,
        code: error.code,
        timestamp: new Date().toISOString()
      },
      { status: 500 }
    );
  }
}