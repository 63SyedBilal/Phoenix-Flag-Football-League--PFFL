import { v2 as cloudinary } from "cloudinary"
import { Readable } from "stream"

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || "",
  api_key: process.env.CLOUDINARY_API_KEY || "",
  api_secret: process.env.CLOUDINARY_API_SECRET || "",
})

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
    console.error("Cloudinary upload error:", error)
    throw new Error(`Failed to upload file: ${error instanceof Error ? error.message : "Unknown error"}`)
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








