"use client"

import { useState } from "react"
import { Eye, EyeOff, ArrowRight } from "lucide-react"
import Image from "next/image"

export interface SignupFormData {
  firstName: string
  lastName: string
  email: string
  phoneNumber: string
  password: string
  confirmPassword: string
  agreeToTerms: boolean
}

export interface SignupFormProps {
  accountType?: string
  onSuccess?: (data: SignupFormData) => void
  onBack?: () => void
  isLoading?: boolean
  showBackButton?: boolean
}

export default function SignupForm({
  accountType = "player",
  onSuccess,
  onBack,
  isLoading: externalLoading,
  showBackButton = true,
}: SignupFormProps) {
  const [formData, setFormData] = useState<SignupFormData>({
    firstName: "",
    lastName: "",
    email: "",
    phoneNumber: "",
    password: "",
    confirmPassword: "",
    agreeToTerms: false,
  })
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [showSuccessPopup, setShowSuccessPopup] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (formData.password !== formData.confirmPassword) {
      return
    }
    setIsLoading(true)
    // Simulate account creation
    setTimeout(() => {
      setIsLoading(false)
      setShowSuccessPopup(true)
      if (onSuccess) {
        onSuccess(formData)
      }
    }, 1000)
  }

  const handleContinue = () => {
    setShowSuccessPopup(false)
    if (onSuccess) {
      onSuccess(formData)
    }
  }

  const getAccountTypeText = () => {
    switch (accountType.toLowerCase()) {
      case "captain":
        return "Create your captain account"
      case "free-agent":
      case "freeagent":
        return "Create your free agent account"
      case "player":
      default:
        return "Create your player account"
    }
  }

  const loading = externalLoading !== undefined ? externalLoading : isLoading

  return (
    <div className="flex flex-col gap-6">
      {/* Back Arrow */}
      {showBackButton && (
        <button
          onClick={onBack}
          className="w-[50px] h-[50px] p-[10px] rounded-full bg-[#F2F2F2] hover:bg-gray-200 transition-colors flex items-center justify-center flex-shrink-0 mb-2"
        >
          <Image src="/assets/image/Back arrow.svg" alt="Back" width={24} height={24} />
        </button>
      )}

      {/* Heading */}
      <div className="mb-4">
        <h1
          className="text-3xl font-bold mb-2"
          style={{
            fontFamily: "Lato, sans-serif",
            fontWeight: 700,
            color: "#111827",
          }}
        >
          Join PFFL Today
        </h1>
        <p
          className="text-base"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#6B7280",
          }}
        >
          {getAccountTypeText()}
        </p>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="flex flex-col gap-6">
        {/* First Name and Last Name in same row */}
        <div className="grid grid-cols-2 gap-4">
          <div className="flex flex-col gap-2">
            <label
              htmlFor="firstName"
              className="font-medium"
              style={{
                fontFamily: "Lato, sans-serif",
                fontWeight: 500,
                fontSize: "14px",
                lineHeight: "20px",
                color: "#111827",
              }}
            >
              First Name
            </label>
            <input
              id="firstName"
              type="text"
              placeholder="e.g bilal"
              value={formData.firstName}
              onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
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

          <div className="flex flex-col gap-2">
            <label
              htmlFor="lastName"
              className="font-medium"
              style={{
                fontFamily: "Lato, sans-serif",
                fontWeight: 500,
                fontSize: "14px",
                lineHeight: "20px",
                color: "#111827",
              }}
            >
              Last Name
            </label>
            <input
              id="lastName"
              type="text"
              placeholder="e.g ahmed"
              value={formData.lastName}
              onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
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
        </div>

        {/* Email */}
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
            value={formData.email}
            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
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

        {/* Phone Number */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="phone"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Phone Number
          </label>
          <div className="relative">
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-lg">🇺🇸</span>
            <input
              id="phone"
              type="tel"
              placeholder="e.g +44 123 456 7890"
              value={formData.phoneNumber}
              onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
              required
              className="w-full h-12 px-3 pl-10 py-[10px] rounded-md border"
              style={{
                border: "1px solid #D1D5DB",
                boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                backgroundColor: "#FFFFFF",
                fontFamily: "Lato, sans-serif",
              }}
            />
          </div>
        </div>

        {/* Create Password */}
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
            Create Password
          </label>
          <div className="relative">
            <input
              id="password"
              type={showPassword ? "text" : "password"}
              placeholder="Create your password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
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
              {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>
          <p
            className="text-xs"
            style={{
              fontFamily: "Lato, sans-serif",
              color: "#6B7280",
            }}
          >
            Password strength: <span className="text-gray-400">●●●●●●</span>
          </p>
        </div>

        {/* Confirm Password */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="confirmPassword"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Confirm Password
          </label>
          <div className="relative">
            <input
              id="confirmPassword"
              type={showConfirmPassword ? "text" : "password"}
              placeholder="Re-enter your password"
              value={formData.confirmPassword}
              onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
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
              onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 transition-colors"
            >
              {showConfirmPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>
          {formData.password && formData.confirmPassword && formData.password !== formData.confirmPassword && (
            <p className="text-xs text-red-600">Passwords do not match</p>
          )}
        </div>

        {/* Terms & Privacy */}
        <div className="flex items-center gap-2">
          <input
            id="terms"
            type="checkbox"
            checked={formData.agreeToTerms}
            onChange={(e) => setFormData({ ...formData, agreeToTerms: e.target.checked })}
            className="rounded border-border"
            required
          />
          <label
            htmlFor="terms"
            className="text-xs"
            style={{
              fontFamily: "Lato, sans-serif",
              color: "#6B7280",
            }}
          >
            I agree to{" "}
            <a href="#" className="text-[#0F173E] hover:underline">
              Terms & Privacy
            </a>
          </label>
        </div>

        {/* Create Account Button */}
        <button
          type="submit"
          disabled={loading || !formData.agreeToTerms}
          className="w-full h-[58px] rounded-full text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          {loading ? "Creating Account..." : "Create Account"}
        </button>

        {/* Already have account */}
        <p
          className="text-center text-sm flex items-center justify-center gap-1"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#6B7280",
          }}
        >
          Already have an account?{" "}
          <a href="/login" className="text-[#0F173E] hover:underline flex items-center gap-1">
            login <ArrowRight className="w-4 h-4" />
          </a>
        </p>
      </form>

      {/* Success Popup */}
      {showSuccessPopup && (
        <div
          className="fixed inset-0 flex items-center justify-center z-50"
          style={{ backgroundColor: "rgba(0, 0, 0, 0.2)" }}
          onClick={() => setShowSuccessPopup(false)}
        >
          <div
            className="bg-white rounded-[24px] relative"
            style={{
              width: "603px",
              padding: "20px 14px",
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div
              className="flex flex-col items-center gap-6"
              style={{
                width: "575px",
                padding: "20px",
              }}
            >
              <h2
                className="text-2xl font-bold text-foreground text-center"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                Account Created Successfully
              </h2>
              <p
                className="text-base text-foreground text-center"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                Your account has been created. Please continue to complete your profile.
              </p>
              <button
                onClick={handleContinue}
                className="w-full h-12 rounded-full text-sm font-medium text-white transition-colors"
                style={{ backgroundColor: "#0F173E", fontFamily: "Lato, sans-serif" }}
              >
                Continue
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}



