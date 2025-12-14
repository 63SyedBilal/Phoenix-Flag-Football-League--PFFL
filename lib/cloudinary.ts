import { v2 as cloudinary } from "cloudinary"
import { Readable } from "stream"

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || "",
  api_key: process.env.CLOUDINARY_API_KEY || "",
  api_secret: process.env.CLOUDINARY_API_SECRET || "",
})

/**
 * Validate Cloudinary configuration
 * Throws error if required environment variables are missing
 */
export function validateCloudinaryConfig(): void {
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const apiKey = process.env.CLOUDINARY_API_KEY;
  const apiSecret = process.env.CLOUDINARY_API_SECRET;

  if (!cloudName || !apiKey || !apiSecret) {
    const missing = [];
    if (!cloudName) missing.push('CLOUDINARY_CLOUD_NAME');
    if (!apiKey) missing.push('CLOUDINARY_API_KEY');
    if (!apiSecret) missing.push('CLOUDINARY_API_SECRET');
    
    throw new Error(
      `Cloudinary configuration is missing. Please set the following environment variables: ${missing.join(', ')}`
    );
  }
}

/**
 * Extract error message from Cloudinary error object
 * Cloudinary errors have specific structure with http_code, message, etc.
 */
function extractCloudinaryErrorMessage(error: any): string {
  // Cloudinary errors have specific structure
  if (error && typeof error === 'object') {
    // Check for Cloudinary error properties
    if (error.http_code) {
      const httpCode = error.http_code;
      const message = error.message || 'Unknown Cloudinary error';
      
      // Provide specific messages for common error codes
      if (httpCode === 401) {
        return `Cloudinary authentication failed (401). Please check your API credentials. Original: ${message}`;
      } else if (httpCode === 400) {
        return `Cloudinary invalid request (400). ${message}`;
      } else if (httpCode === 403) {
        return `Cloudinary access forbidden (403). ${message}`;
      } else if (httpCode === 404) {
        return `Cloudinary resource not found (404). ${message}`;
      } else if (httpCode === 500) {
        return `Cloudinary server error (500). ${message}`;
      }
      
      return `Cloudinary error (${httpCode}): ${message}`;
    }
    
    // Check for standard error message
    if (error.message) {
      return error.message;
    }
    
    // If no message, stringify the error
    return JSON.stringify(error);
  }
  
  // Fallback for non-object errors
  return String(error);
}

export interface UploadOptions {
  folder?: string
  public_id?: string
  overwrite?: boolean
  resource_type?: "image" | "video" | "raw" | "auto"
  transformation?: Array<Record<string, any>>
}

export interface UploadResult {
  public_id: string
  secure_url: string
  url: string
  width: number
  height: number
  format: string
  bytes: number
}

/**
 * Upload a file to Cloudinary
 * @param file - File buffer or path
 * @param options - Upload options
 * @returns Upload result with URL and metadata
 */
export async function uploadToCloudinary(
  file: Buffer | string,
  options: UploadOptions = {}
): Promise<UploadResult> {
  try {
    // Validate configuration first
    validateCloudinaryConfig();
    
    const uploadOptions = {
      folder: options.folder || "pffl",
      public_id: options.public_id,
      overwrite: options.overwrite || false,
      resource_type: options.resource_type || "image",
      transformation: options.transformation,
    }

    let result

    if (Buffer.isBuffer(file)) {
      // Upload from buffer
      result = await new Promise<UploadResult>((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          uploadOptions,
          (error, result) => {
            if (error) reject(error)
            else if (result) {
              resolve({
                public_id: result.public_id,
                secure_url: result.secure_url,
                url: result.url,
                width: result.width,
                height: result.height,
                format: result.format,
                bytes: result.bytes,
              })
            } else {
              reject(new Error("Upload failed: No result returned"))
            }
          }
        )

        const bufferStream = new Readable()
        bufferStream.push(file)
        bufferStream.push(null)
        bufferStream.pipe(uploadStream)
      })
    } else {
      // Upload from file path
      result = await cloudinary.uploader.upload(file, uploadOptions)
    }

    return {
      public_id: result.public_id,
      secure_url: result.secure_url,
      url: result.url,
      width: result.width,
      height: result.height,
      format: result.format,
      bytes: result.bytes,
    }
  } catch (error) {
    console.error("Cloudinary upload error:", error);
    console.error("Error type:", typeof error);
    console.error("Error constructor:", error?.constructor?.name);
    console.error("Full error object:", JSON.stringify(error, null, 2));
    
    // Re-throw with original error message if it's a config error
    if (error instanceof Error && error.message.includes('Cloudinary configuration is missing')) {
      throw error;
    }
    
    // Extract actual error message from Cloudinary error object
    const errorMessage = extractCloudinaryErrorMessage(error);
    const errorDetails = error instanceof Error ? error.stack : JSON.stringify(error, null, 2);
    console.error("Cloudinary error details:", errorDetails);
    console.error("Extracted error message:", errorMessage);
    
    throw new Error(`Failed to upload file: ${errorMessage}`);
  }
}

/**
 * Delete a file from Cloudinary
 * @param publicId - Public ID of the file to delete
 * @param resourceType - Type of resource (image, video, raw)
 * @returns Deletion result
 */
export async function deleteFromCloudinary(
  publicId: string,
  resourceType: "image" | "video" | "raw" = "image"
): Promise<{ result: string }> {
  try {
    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: resourceType,
    })
    return result
  } catch (error) {
    console.error("Cloudinary delete error:", error)
    throw new Error(`Failed to delete file: ${error instanceof Error ? error.message : "Unknown error"}`)
  }
}

/**
 * Generate a Cloudinary URL with transformations
 * @param publicId - Public ID of the file
 * @param transformations - Transformation options
 * @returns Transformed URL
 */
export function getCloudinaryUrl(
  publicId: string,
  transformations: Record<string, any> = {}
): string {
  return cloudinary.url(publicId, {
    secure: true,
    ...transformations,
  })
}

/**
 * Upload multiple files to Cloudinary
 * @param files - Array of file buffers or paths
 * @param options - Upload options
 * @returns Array of upload results
 */
export async function uploadMultipleToCloudinary(
  files: (Buffer | string)[],
  options: UploadOptions = {}
): Promise<UploadResult[]> {
  const uploadPromises = files.map((file) =>
    uploadToCloudinary(file, options)
  )
  return Promise.all(uploadPromises)
}












