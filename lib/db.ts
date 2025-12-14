import mongoose from "mongoose"

// Try multiple connection strings
const MONGODB_URI = process.env.MONGODB_URI || 
  "mongodb://localhost:27017/pffl" ||
  "mongodb://127.0.0.1:27017/pffl" ||
  "mongodb+srv://zubairhashmi423_db_user:zubairkhann123@cluster0.ikrhunq.mongodb.net/pffl?retryWrites=true&w=majority"

console.log("Attempting to connect to MongoDB with URI:", MONGODB_URI)

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
  console.log("connectDB called")
  
  // Check if already connected to the correct database
  if (cached.conn) {
    const currentDb = cached.conn.connection.db?.databaseName
    if (currentDb === "pffl") {
      console.log(`Already connected to database: ${currentDb}`)
      return cached.conn
    }
    // If connected to wrong database, disconnect first
    console.log("Connected to wrong database, disconnecting...")
    await mongoose.disconnect()
    cached.conn = null
    cached.promise = null
  }

  if (!cached.promise) {
    console.log("Creating new connection promise")
    // Ensure database name is in the URI
    let uri = MONGODB_URI
    if (!uri.includes("/pffl") && !uri.includes("?") && !uri.endsWith("/")) {
      uri = uri.replace(/\/$/, "") + "/pffl?retryWrites=true&w=majority"
    } else if (!uri.includes("/pffl") && uri.includes("?")) {
      uri = uri.replace(/\?/, "/pffl?")
    } else if (!uri.includes("/pffl") && uri.endsWith("/")) {
      uri = uri + "pffl?retryWrites=true&w=majority"
    }

    console.log("Connecting to MongoDB with URI:", uri)
    
    cached.promise = mongoose.connect(uri, {
      dbName: "pffl", // Explicitly set database name
      serverSelectionTimeoutMS: 5000, // Timeout after 5s instead of 30s
      socketTimeoutMS: 5000,
    }).then((mongoose) => {
      const dbName = mongoose.connection.db?.databaseName || "unknown"
      console.log(`✅ MongoDB connected to database: ${dbName}`)
      return mongoose
    }).catch((error) => {
      console.error("❌ MongoDB connection error:", error)
      throw error
    })
  }

  try {
    cached.conn = await cached.promise
    console.log("✅ Database connection established")
    return cached.conn
  } catch (error) {
    console.error("❌ Failed to establish database connection:", error)
    cached.promise = null
    throw error
  }
}