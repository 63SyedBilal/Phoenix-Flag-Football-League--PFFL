"use client"

import { useState } from "react"
import { Upload } from "lucide-react"
import Image from "next/image"

export interface TeamFormData {
  teamLogo: File | null
  teamName: string
  enterCode: string
  location: string
  skillLevel: string
  format: string
  agreeToTerms: boolean
}

export interface TeamFormProps {
  onSuccess?: (data: TeamFormData) => void
  onBack?: () => void
  isLoading?: boolean
  showBackButton?: boolean
  title?: string
  subtitle?: string
  successMessage?: string
}

const skillLevels = ["beginner", "intermediate", "advanced", "professional"]

export default function TeamForm({
  onSuccess,
  onBack,
  isLoading: externalLoading,
  showBackButton = true,
  title = "Complete Your Profile",
  subtitle = "This helps teams find you",
  successMessage = "Your captain profile has been completed successfully.",
}: TeamFormProps) {
  const [formData, setFormData] = useState<TeamFormData>({
    teamLogo: null,
    teamName: "",
    enterCode: "",
    location: "",
    skillLevel: "beginner",
    format: "5v5",
    agreeToTerms: false,
  })
  const [isSkillLevelDropdownOpen, setIsSkillLevelDropdownOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [showSuccessPopup, setShowSuccessPopup] = useState(false)
  const [error, setError] = useState("")

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFormData({ ...formData, teamLogo: e.target.files[0] })
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    try {
      const token = localStorage.getItem("token")
      if (!token) {
        setError("Session expired. Please login again.")
        setIsLoading(false)
        return
      }

      let imageUrl = ""

      // Upload image to Cloudinary if provided
      if (formData.teamLogo) {
        try {
          const formDataToUpload = new FormData()
          formDataToUpload.append("file", formData.teamLogo)

          const uploadResponse = await fetch("/api/upload", {
            method: "POST",
            body: formDataToUpload,
          })

          if (!uploadResponse.ok) {
            const errorData = await uploadResponse.json()
            throw new Error(errorData.error || "Failed to upload image")
          }

          const uploadData = await uploadResponse.json()
          imageUrl = uploadData.data.url
        } catch (uploadError) {
          console.error("Image upload error:", uploadError)
          setError("Failed to upload image. Please try again.")
          setIsLoading(false)
          return
        }
      }

      // Prepare team data
      const teamData: any = {
        teamName: formData.teamName.trim(),
        enterCode: formData.enterCode.trim(),
        location: formData.location.trim(),
        skillLevel: formData.skillLevel,
        format: formData.format,
        image: imageUrl,
      }

      // Create team
      const response = await fetch("/api/team", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify(teamData),
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "Failed to create team")
        setIsLoading(false)
        return
      }

      setIsLoading(false)
      setShowSuccessPopup(true)
      if (onSuccess) {
        onSuccess(formData)
      }
    } catch (error) {
      console.error("Team creation error:", error)
      setError("An error occurred. Please try again.")
      setIsLoading(false)
    }
  }

  const handleContinue = () => {
    setShowSuccessPopup(false)
    if (onSuccess) {
      onSuccess(formData)
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
          {title}
        </h1>
        <p
          className="text-base"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#6B7280",
          }}
        >
          {subtitle}
        </p>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="flex flex-col gap-6">
        {/* Team Logo Upload */}
        <div className="flex flex-col items-center gap-4">
          <div
            className="w-32 h-32 rounded-full border-2 border-dashed flex items-center justify-center overflow-hidden"
            style={{
              borderColor: "#D1D5DB",
              backgroundColor: "#F9FAFB",
            }}
          >
            {formData.teamLogo ? (
              <img
                src={URL.createObjectURL(formData.teamLogo)}
                alt="Team Logo"
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="text-4xl text-gray-400">🏈</div>
            )}
          </div>
          <p
            className="text-sm text-center font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              color: "#111827",
            }}
          >
            Team Logo (Optional)
          </p>
          <p
            className="text-xs text-center max-w-md"
            style={{
              fontFamily: "Lato, sans-serif",
              color: "#6B7280",
            }}
          >
            Please upload your team's logo in this section to ensure that we can represent your brand accurately.
          </p>
          <label className="cursor-pointer">
            <input
              type="file"
              accept="image/*"
              onChange={handleFileChange}
              className="hidden"
            />
            <button
              type="button"
              className="flex items-center gap-2 px-4 py-2 rounded-lg text-white font-medium"
              style={{
                backgroundColor: "#000000",
                fontFamily: "Lato, sans-serif",
              }}
            >
              <Upload className="w-4 h-4" />
              Upload
            </button>
          </label>
        </div>

        {/* Team Name */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="teamName"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Team Name
          </label>
          <input
            id="teamName"
            type="text"
            placeholder="e.g Star Eleven"
            value={formData.teamName}
            onChange={(e) => setFormData({ ...formData, teamName: e.target.value })}
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

        {/* Enter Color */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="enterCode"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Enter Color
          </label>
          <input
            id="enterCode"
            type="text"
            placeholder="e.g Blue, Red, Green"
            value={formData.enterCode}
            onChange={(e) => setFormData({ ...formData, enterCode: e.target.value })}
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

        {/* Location */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="location"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Location
          </label>
          <input
            id="location"
            type="text"
            placeholder="e.g Street 11, Newyork"
            value={formData.location}
            onChange={(e) => setFormData({ ...formData, location: e.target.value })}
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

        {/* Skill Level Dropdown */}
        <div className="flex flex-col gap-2">
          <label
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Skill Level
          </label>
          <div className="relative">
            <button
              type="button"
              onClick={() => setIsSkillLevelDropdownOpen(!isSkillLevelDropdownOpen)}
              className="w-full h-12 px-3 py-[10px] rounded-md border flex items-center justify-between text-left"
              style={{
                border: "1px solid #D1D5DB",
                boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                backgroundColor: "#FFFFFF",
                fontFamily: "Lato, sans-serif",
              }}
            >
              <span style={{ color: formData.skillLevel ? "#111827" : "#9CA3AF" }}>
                {formData.skillLevel ? formData.skillLevel.charAt(0).toUpperCase() + formData.skillLevel.slice(1) : "Select skill level"}
              </span>
              <Image
                src="/assets/image/arrow-down.svg"
                alt="dropdown"
                width={16}
                height={16}
                className={`transition-transform ${isSkillLevelDropdownOpen ? "rotate-180" : ""}`}
              />
            </button>
            {isSkillLevelDropdownOpen && (
              <div
                className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 overflow-hidden"
                style={{ maxHeight: "200px", overflowY: "auto" }}
              >
                {skillLevels.map((level) => (
                  <button
                    key={level}
                    type="button"
                    onClick={() => {
                      setFormData({ ...formData, skillLevel: level })
                      setIsSkillLevelDropdownOpen(false)
                    }}
                    className="w-full px-4 py-3 text-left text-sm transition-colors"
                    onMouseEnter={(e) => {
                      if (formData.skillLevel !== level) {
                        e.currentTarget.style.backgroundColor = "#F3F4F6"
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (formData.skillLevel !== level) {
                        e.currentTarget.style.backgroundColor = "transparent"
                      }
                    }}
                    style={{
                      fontFamily: "Lato, sans-serif",
                      backgroundColor: formData.skillLevel === level ? "#0F173E" : "transparent",
                      color: formData.skillLevel === level ? "#FFFFFF" : "#000000",
                    }}
                  >
                    {level.charAt(0).toUpperCase() + level.slice(1)}
                  </button>
                ))}
              </div>
            )}
          </div>
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

        {/* Error Message */}
        {error && (
          <div className="p-3 rounded-md bg-red-50 border border-red-200">
            <p className="text-sm text-red-600" style={{ fontFamily: "Lato, sans-serif" }}>
              {error}
            </p>
          </div>
        )}

        {/* Complete Button */}
        <button
          type="submit"
          disabled={loading || !formData.agreeToTerms || !formData.teamName || !formData.enterCode || !formData.location}
          className="w-full h-[58px] rounded-full text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          {loading ? "Creating Team..." : "Create Team"}
        </button>
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
                Profile Complete
              </h2>
              <p
                className="text-base text-foreground text-center"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                {successMessage}
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

