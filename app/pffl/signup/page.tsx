"use client"

import { useState, useEffect } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import SignupForm from "@/components/forms/signup-form"
import ProfileForm from "@/components/forms/profile-form"
import TeamForm from "@/components/forms/team-form"
import type { SignupFormData } from "@/components/forms/signup-form"
import type { CaptainProfileFormData } from "@/components/forms/profile-form"
import type { TeamFormData } from "@/components/forms/team-form"

type Step = "signup" | "profile" | "team"

export default function SignupPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const roleFromLogin = searchParams.get("role") || ""
  
  // Map login roles to signup account types
  const getAccountTypeFromRole = (role: string): string => {
    if (role === "captain") return "captain"
    if (role === "player") return "player"
    if (role === "referee" || role === "stat-keeper") return "free-agent"
    return "player" // default
  }

  const [accountType, setAccountType] = useState<string>(() => {
    return roleFromLogin ? getAccountTypeFromRole(roleFromLogin) : "player"
  })

  const [currentStep, setCurrentStep] = useState<Step>("signup")
  const [signupData, setSignupData] = useState<SignupFormData | null>(null)
  const [profileData, setProfileData] = useState<CaptainProfileFormData | null>(null)

  // Update account type if role changes
  useEffect(() => {
    if (roleFromLogin) {
      setAccountType(getAccountTypeFromRole(roleFromLogin))
    }
  }, [roleFromLogin])

  // Handle signup form success
  const handleSignupSuccess = (data: SignupFormData) => {
    // Prevent double advancement if already moved to next step
    if (currentStep !== "signup") return
    
    setSignupData(data)
    // If captain, go to profile form, otherwise go to home
    if (accountType === "captain") {
      setCurrentStep("profile")
    } else {
      router.push("/pffl/home")
    }
  }

  // Handle profile form success (for captain)
  const handleProfileSuccess = (data: CaptainProfileFormData) => {
    // Prevent double advancement if already moved to next step
    if (currentStep !== "profile") return
    
    setProfileData(data)
    // Move to team form
    setCurrentStep("team")
  }

  // Handle team form success (for captain)
  const handleTeamSuccess = (data: TeamFormData) => {
    // All forms completed, route to home
    router.push("/pffl/home")
  }

  const handleBack = () => {
    if (currentStep === "profile") {
      setCurrentStep("signup")
    } else if (currentStep === "team") {
      setCurrentStep("profile")
    } else {
      router.push("/login")
    }
  }

  return (
    <div>
      <div>
        {currentStep === "signup" && (
          <SignupForm
            accountType={accountType}
            onSuccess={handleSignupSuccess}
            onBack={handleBack}
            showBackButton={true}
          />
        )}
        
        {currentStep === "profile" && accountType === "captain" && (
          <ProfileForm
            onSuccess={handleProfileSuccess}
            onBack={handleBack}
            showBackButton={true}
            title="Complete Your Profile"
            subtitle="This helps teams find you"
          />
        )}
        
        {currentStep === "team" && accountType === "captain" && (
          <TeamForm
            onSuccess={handleTeamSuccess}
            onBack={handleBack}
            showBackButton={true}
            title="Complete Your Team Profile"
            subtitle="Set up your team information"
            successMessage="Your captain profile has been completed successfully."
          />
        )}
      </div>
    </div>
  )
}

