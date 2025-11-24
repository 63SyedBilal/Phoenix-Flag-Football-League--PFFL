import mongoose from "mongoose"

const MONGODB_URI = process.env.MONGODB_URI || ""

if (!MONGODB_URI) {
  throw new Error(
    "Please define the MONGODB_URI environment variable inside .env.local"
  )
}

interface MongooseCache {
  conn: typeof mongoose | null
  promise: Promise<typeof mongoose> | null
}

// Use global variable to cache the connection in development
declare global {
  // eslint-disable-next-line no-var
  var mongoose: MongooseCache | undefined
}

let cached: MongooseCache = global.mongoose || { conn: null, promise: null }

if (!global.mongoose) {
  global.mongoose = cached
}

/**
 * Connect to MongoDB database
 * Uses connection pooling and caching to prevent multiple connections in development
 * @returns Mongoose connection instance
 */
export async function connectDB(): Promise<typeof mongoose> {
  if (cached.conn) {
    return cached.conn
  }

  if (!cached.promise) {
    const opts = {
      bufferCommands: false,
    }

    cached.promise = mongoose
      .connect(MONGODB_URI, opts)
      .then((mongoose) => {
        console.log("✅ MongoDB connected successfully")
        return mongoose
      })
      .catch((error) => {
        console.error("❌ MongoDB connection error:", error)
        throw error
      })
  }

  try {
    cached.conn = await cached.promise
  } catch (e) {
    cached.promise = null
    throw e
  }

  return cached.conn
}

/**
 * Disconnect from MongoDB database
 */
export async function disconnectDB(): Promise<void> {
  if (cached.conn) {
    await mongoose.disconnect()
    cached.conn = null
    cached.promise = null
    console.log("✅ MongoDB disconnected")
  }
}

/**
 * Check if database is connected
 * @returns True if connected, false otherwise
 */
export function isConnected(): boolean {
  return mongoose.connection.readyState === 1
}



