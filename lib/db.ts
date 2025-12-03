import mongoose from "mongoose"

const MONGODB_URI = process.env.MONGODB_URI

if (!MONGODB_URI) {
  throw new Error("Please define MONGODB_URI in .env.local")
}

interface MongooseCache {
  conn: typeof mongoose | null
  promise: Promise<typeof mongoose> | null
}

declare global {
  var mongoose: MongooseCache | undefined
}

let cached: MongooseCache = global.mongoose || { conn: null, promise: null }

if (!global.mongoose) {
  global.mongoose = cached
}

export async function connectDB() {
  // Check if already connected to the correct database
  if (cached.conn) {
    const currentDb = cached.conn.connection.db?.databaseName
    if (currentDb === "pffl") {
      return cached.conn
    }
    // If connected to wrong database, disconnect first
    await mongoose.disconnect()
    cached.conn = null
    cached.promise = null
  }

  if (!cached.promise) {
    // Ensure database name is in the URI
    let uri = MONGODB_URI
    if (!uri.includes("/pffl") && !uri.includes("?") && !uri.endsWith("/")) {
      uri = uri.replace(/\/$/, "") + "/pffl?retryWrites=true&w=majority"
    } else if (!uri.includes("/pffl") && uri.includes("?")) {
      uri = uri.replace(/\?/, "/pffl?")
    } else if (!uri.includes("/pffl") && uri.endsWith("/")) {
      uri = uri + "pffl?retryWrites=true&w=majority"
    }

    cached.promise = mongoose.connect(uri, {
      dbName: "pffl", // Explicitly set database name
    }).then((mongoose) => {
      const dbName = mongoose.connection.db?.databaseName || "unknown"
      console.log(`✅ MongoDB connected to database: ${dbName}`)
      return mongoose
    })
  }

  cached.conn = await cached.promise
  return cached.conn
}




