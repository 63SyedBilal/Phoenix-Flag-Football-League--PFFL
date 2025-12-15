import { NextRequest, NextResponse } from "next/server";

// Predefined test credentials for different roles
const TEST_USERS = [
  { email: "pffl@gmail.com", password: "123456", role: "superadmin" },
  { email: "player@gmail.com", password: "123456", role: "player" },
  { email: "freeagent@gmail.com", password: "123456", role: "free-agent" },
  { email: "captain@gmail.com", password: "123456", role: "captain" },
  { email: "referee@gmail.com", password: "123456", role: "referee" },
  { email: "statkeeper@gmail.com", password: "123456", role: "stat-keeper" },
];

export async function GET(req: NextRequest) {
  try {
    // Return the list of test users
    return NextResponse.json(
      {
        message: "Available test users",
        users: TEST_USERS,
      },
      { status: 200 }
    );
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const { email, password, role } = await req.json();
    
    // Find the user in our test users
    let userToTest = TEST_USERS.find(u => u.email === email && u.password === password);
    
    // If not found by email/password, try to find by role
    if (!userToTest && role) {
      userToTest = TEST_USERS.find(u => u.role === role);
    }
    
    if (!userToTest) {
      return NextResponse.json(
        { 
          success: false,
          error: "User not found. Please provide valid email/password or role.",
          availableUsers: TEST_USERS
        },
        { status: 404 }
      );
    }
    
    console.log("Attempting login with:", userToTest.email);
    
    // Try to login with the provided credentials
    const response = await fetch("http://localhost:3000/api/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: userToTest.email,
        password: userToTest.password,
      }),
    });
    
    const data = await response.json();
    
    console.log("Login response status:", response.status);
    
    if (response.status === 200) {
      return NextResponse.json(
        {
          success: true,
          message: "Login successful",
          user: {
            email: userToTest.email,
            role: userToTest.role,
          },
          token: data.token,
          fullResponse: data
        },
        { status: 200 }
      );
    } else {
      return NextResponse.json(
        {
          success: false,
          message: "Login failed",
          user: {
            email: userToTest.email,
            role: userToTest.role,
          },
          error: data.error || "Unknown error",
          fullResponse: data
        },
        { status: response.status }
      );
    }
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