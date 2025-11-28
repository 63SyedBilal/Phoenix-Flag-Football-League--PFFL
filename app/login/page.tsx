"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Eye, EyeOff } from "lucide-react"
import Image from "next/image"

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError("")

    try {
      const response = await fetch("/api/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email.trim(),
          password,
        }),
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "Login failed")
        setIsLoading(false)
        return
      }

      setError("")

      // Store token in localStorage
      if (data.token) {
        localStorage.setItem("token", data.token)
        localStorage.setItem("user", JSON.stringify(data.data))
      }

      // Redirect based on role and profile completion
      const userRole = data.data.role;
      const needsProfileCompletion = data.data.needsProfileCompletion;
      const needsProfileForm = data.data.needsProfileForm || false;
      const needsTeamForm = data.data.needsTeamForm || false;
      
      if (userRole === "superadmin") {
        router.push("/superadmin/home")
      } else if (
        userRole === "player" || 
        userRole === "captain" || 
        userRole === "free-agent" || 
        userRole === "referee" || 
        userRole === "stat-keeper"
      ) {
        // If profile is incomplete, redirect to signup to complete profile
        if (needsProfileCompletion) {
          router.push(`/pffl/signup?email=${encodeURIComponent(data.data.email)}&role=${encodeURIComponent(userRole)}&complete=true`)
        } else if (userRole === "captain") {
          // For captains, check if profile or team form is needed
          if (needsProfileForm) {
            router.push(`/pffl/signup?email=${encodeURIComponent(data.data.email)}&role=${encodeURIComponent(userRole)}&step=profile`)
          } else if (needsTeamForm) {
            router.push(`/pffl/signup?email=${encodeURIComponent(data.data.email)}&role=${encodeURIComponent(userRole)}&step=team`)
          } else {
            router.push("/pffl/home")
          }
        } else {
          router.push("/pffl/home")
        }
      } else {
        router.push("/pffl/home")
      }
    } catch (error) {
      console.error("Login error:", error)
      setError("An error occurred. Please try again.")
      setIsLoading(false)
    }
  }

  return (
    <div className="h-[100vh] w-[100vw] flex items-center justify-center  p-1 px-0">
      
       
          {/* Left Section - Login Form (70%) */}
          <div className="flex-[0.6] flex flex-col  items-center p-12 bg-white">
            <div className="flex flex-col gap-6 w-[70%] rounded-[24px]">
              {/* Title */}
              <div >
                <h1
                  className="text-4xl font-bold mb-1"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    fontWeight: 600,
                    color: "#0F173E",
                  }}
                >
                  Welcome Back to PFFL
                </h1>
                <p
                  className="text-base"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    color: "#6B7280",
                  }}
                >
                  Log in to access your teams and games
                </p>
              </div>

              {/* Error Message */}
              {error && (
                <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
                  <strong className="font-bold">Error!</strong>
                  <span className="block sm:inline"> {error}</span>
                </div>
              )}

              {/* Form */}
              <form onSubmit={handleSubmit} className="flex flex-col gap-6">
                {/* Email Field */}
                <div className="flex flex-col gap-2">
                  <label
                    htmlFor="email"
                    className="font-medium"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      fontWeight: 500,
                      fontSize: "14px",
                      lineHeight: "20px",
                      color: "#111827",
                    }}
                  >
                    Email Address
                  </label>
                  <input
                    id="email"
                    type="email"
                    placeholder="e.g bilal@phoenixleague.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="w-full h-12 px-3 py-[10px] rounded-md border"
                    style={{
                      border: "1px solid #D1D5DB",
                      boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                      backgroundColor: "#FFFFFF",
                      fontFamily: "Lato, sans-serif",
                    }}
                  />
                </div>

                {/* Password Field */}
                <div className="flex flex-col gap-2">
                  <label
                    htmlFor="password"
                    className="font-medium"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      fontWeight: 500,
                      fontSize: "14px",
                      lineHeight: "20px",
                      color: "#111827",
                    }}
                  >
                    Password
                  </label>
                  <div className="relative">
                    <input
                      id="password"
                      type={showPassword ? "text" : "password"}
                      placeholder="Enter your password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                      className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                      style={{
                        border: "1px solid #D1D5DB",
                        boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                        backgroundColor: "#FFFFFF",
                        fontFamily: "Lato, sans-serif",
                      }}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 transition-colors"
                    >
                      {showPassword ? (
                        <EyeOff className="w-5 h-5" />
                      ) : (
                        <Eye className="w-5 h-5" />
                      )}
                    </button>
                  </div>
                  <div className="flex justify-end">
                    <button
                      type="button"
                      className="text-sm"
                      style={{
                        fontFamily: "Lato, sans-serif",
                        color: "#6B7280",
                      }}
                    >
                      Forgot Password
                    </button>
                  </div>
                </div>

                {/* Login Button */}
                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full h-[58px] rounded-full text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  style={{
                    backgroundColor: "#0F173E",
                    fontFamily: "Lato, sans-serif",
                  }}
                >
                  {isLoading ? "Logging in..." : "Login"}
                </button>
              </form>
            </div>
          </div>

          {/* Right Section - Thumbnail Image (40%) */}
          <div
            className="flex-[0.4] flex items-center justify-center relative h-[100%] overflow-hidden rounded-3xl"
          >
            <Image
              src="/assets/image/Thumbnail.jpg"
              alt="PFFL"
              fill
              className="object-contain"
              priority
            />
          </div>
      
     
    </div>
  )
}

