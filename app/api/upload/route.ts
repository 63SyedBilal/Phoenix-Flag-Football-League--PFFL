import { NextRequest, NextResponse } from "next/server";
import { uploadToCloudinary, validateCloudinaryConfig } from "@/lib/cloudinary";

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
    // Validate Cloudinary configuration first
    try {
      validateCloudinaryConfig();
      console.log("Cloudinary configuration validated successfully");
    } catch (configError: any) {
      console.error("Cloudinary configuration error:", configError);
      // Log which vars are missing (without values)
      const hasCloudName = !!process.env.CLOUDINARY_CLOUD_NAME;
      const hasApiKey = !!process.env.CLOUDINARY_API_KEY;
      const hasApiSecret = !!process.env.CLOUDINARY_API_SECRET;
      console.error("Environment variables status:", {
        CLOUDINARY_CLOUD_NAME: hasCloudName ? "SET" : "MISSING",
        CLOUDINARY_API_KEY: hasApiKey ? "SET" : "MISSING",
        CLOUDINARY_API_SECRET: hasApiSecret ? "SET" : "MISSING"
      });
      return NextResponse.json(
        { 
          error: configError.message || "Cloudinary configuration is missing. Please check your environment variables.",
          details: "Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET in .env.local"
        },
        { status: 500, headers: getCorsHeaders() }
      );
    }

    const formData = await req.formData();
    const file = formData.get("file") as File;
    const folder = formData.get("folder") as string | null;

    if (!file) {
      return NextResponse.json({ error: "No file provided" }, { status: 400, headers: getCorsHeaders() });
    }

    // Log file info for debugging
    console.log("Upload request received:", {
      fileName: file.name,
      fileSize: file.size,
      fileType: file.type,
      folder: folder || "pffl/profiles"
    });

    // Convert File to Buffer
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    // Determine folder based on parameter or default to profiles
    const uploadFolder = folder || "pffl/profiles";

    // Upload to Cloudinary
    const result = await uploadToCloudinary(buffer, {
      folder: uploadFolder,
      resource_type: "image",
    });

    console.log("Upload successful:", {
      url: result.secure_url,
      public_id: result.public_id
    });

    return NextResponse.json(
      {
        message: "File uploaded successfully",
        data: {
          url: result.secure_url,
          public_id: result.public_id,
        },
      },
      { status: 200, headers: getCorsHeaders() }
    );
  } catch (error: any) {
    console.error("Upload error:", error);
    console.error("Error stack:", error.stack);
    console.error("Error details:", {
      message: error.message,
      name: error.name,
      code: error.code
    });
    
    // Return specific error message
    const errorMessage = error.message || "Failed to upload file";
    return NextResponse.json(
      { 
        error: errorMessage,
        details: error.stack || "Check server logs for more details"
      },
      { status: 500, headers: getCorsHeaders() }
    );
  }
}


