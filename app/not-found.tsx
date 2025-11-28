"use client"

import { useRouter } from "next/navigation"
import Image from "next/image"
import Link from "next/link"

export default function NotFound() {
  const router = useRouter()

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div className="text-center max-w-lg w-full">
        <div className="mb-8">
          <div className="mb-6">
            <h1 
              className="text-9xl font-bold text-gray-300 mb-4"
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              404
            </h1>
          </div>
          <h2 
            className="text-3xl font-bold text-gray-900 mb-3"
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Page Not Found
          </h2>
          <p 
            className="text-gray-600 mb-8 text-lg"
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            The page you're looking for doesn't exist or has been moved.
          </p>
        </div>
        
        <div className="flex flex-col gap-4 items-center">
          <Link
            href="/login"
            className="px-8 py-3 bg-blue-600 text-white rounded-xl font-medium hover:bg-blue-700 transition-colors shadow-sm"
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Go to Login
          </Link>
          <button
            onClick={() => router.back()}
            className="px-8 py-3 text-gray-600 hover:text-gray-800 transition-colors font-medium"
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Go Back
          </button>
        </div>
      </div>
    </div>
  )
}

