"use client"

import { useState, useEffect, Suspense } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import SignupForm from "@/components/forms/signup-form"
import ProfileForm from "@/components/forms/profile-form"
import TeamForm from "@/components/forms/team-form"
import type { SignupFormData } from "@/components/forms/signup-form"
import type { CaptainProfileFormData } from "@/components/forms/profile-form"
import type { TeamFormData } from "@/components/forms/team-form"

type Step = "signup" | "profile" | "team"

function SignupPageContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const roleFromLogin = searchParams.get("role") || ""
  const emailFromLogin = searchParams.get("email") || ""
  const isCompleteProfile = searchParams.get("complete") === "true"
  const stepFromLogin = searchParams.get("step") || ""
  
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

  // Determine initial step based on URL params
  const [currentStep, setCurrentStep] = useState<Step>(() => {
    if (stepFromLogin === "profile") return "profile"
    if (stepFromLogin === "team") return "team"
    return "signup"
  })
  const [signupData, setSignupData] = useState<SignupFormData | null>(null)
  const [profileData, setProfileData] = useState<CaptainProfileFormData | null>(null)
  const [isChecking, setIsChecking] = useState(true)

  // Update account type if role changes
  useEffect(() => {
    if (roleFromLogin) {
      setAccountType(getAccountTypeFromRole(roleFromLogin))
    }
  }, [roleFromLogin])

  // Check if forms are already completed
  useEffect(() => {
    const checkCompletionStatus = async () => {
      if (!roleFromLogin) {
        setIsChecking(false)
        return
      }

      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setIsChecking(false)
          return
        }

        const userData = JSON.parse(localStorage.getItem("user") || "{}")
        
        // Check if signup is completed (has firstName and lastName)
        const signupCompleted = userData.firstName && userData.lastName && userData.firstName !== "" && userData.lastName !== ""

        // Check if profile exists for this user
        let profileExists = false
        if (accountType === "captain" || accountType === "player") {
          try {
            // Try to get profile by user ID
            const profileResponse = await fetch(`/api/profile/${userData.id}`, {
              headers: {
                "Authorization": `Bearer ${token}`,
              },
            })
            if (profileResponse.ok) {
              profileExists = true
            }
          } catch (error) {
            // Profile doesn't exist (404 is expected), continue
            profileExists = false
          }
        }

        // Check if team exists (for captains)
        let teamExists = false
        if (accountType === "captain") {
          try {
            const teamResponse = await fetch("/api/team", {
              headers: {
                "Authorization": `Bearer ${token}`,
              },
            })
            if (teamResponse.ok) {
              const teamData = await teamResponse.json()
              // Check if captain has a team
              if (teamData.data && Array.isArray(teamData.data)) {
                teamExists = teamData.data.some((t: any) => t.captain?._id === userData.id || t.captain?.toString() === userData.id?.toString())
              }
            }
          } catch (error) {
            console.error("Error checking team:", error)
          }
        }

        // Determine which step to show based on what's completed
        if (!signupCompleted) {
          // Signup not completed, show signup form
          setCurrentStep("signup")
        } else if (accountType === "captain") {
          // Signup completed, check profile and team
          if (!profileExists) {
            setCurrentStep("profile")
          } else if (!teamExists) {
            setCurrentStep("team")
          } else {
            // Everything completed, go to home
            router.push("/pffl/home")
          }
        } else if (accountType === "player") {
          // Signup completed, check profile
          if (!profileExists) {
            setCurrentStep("profile")
          } else {
            // Everything completed, go to home
            router.push("/pffl/home")
          }
        }

        setIsChecking(false)
      } catch (error) {
        console.error("Error checking completion status:", error)
        setIsChecking(false)
      }
    }

    checkCompletionStatus()
  }, [roleFromLogin, accountType, router])

  // Handle signup form success
  const handleSignupSuccess = (data: SignupFormData) => {
    // Prevent double advancement if already moved to next step
    if (currentStep !== "signup") return
    
    setSignupData(data)
    // If captain, go to profile form after signup; if player, go to home or profile form
    if (accountType === "captain") {
      setCurrentStep("profile")
    } else if (accountType === "player" && isCompleteProfile) {
      // For players completing profile, go to profile form
      setCurrentStep("profile")
    } else {
      // For new signups (not completing profile), go to home
      router.push("/pffl/home")
    }
  }

  // Handle profile form success (for captain and player)
  const handleProfileSuccess = (data: CaptainProfileFormData) => {
    // Prevent double advancement if already moved to next step
    if (currentStep !== "profile") return
    
    setProfileData(data)
    // If captain, move to team form; if player, go to home
    if (accountType === "captain") {
      setCurrentStep("team")
    } else {
      // For players, profile completion is done, go to home
      router.push("/pffl/home")
    }
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

  // Show loading state while checking
  if (isChecking) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>Loading...</p>
        </div>
      </div>
    )
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
            prefillEmail={emailFromLogin}
            prefillRole={roleFromLogin}
            isCompleteProfile={isCompleteProfile}
          />
        )}
        
        {currentStep === "profile" && (accountType === "captain" || accountType === "player") && (
          <ProfileForm
            onSuccess={handleProfileSuccess}
            onBack={handleBack}
            showBackButton={true}
            title="Complete Your Profile"
            subtitle="This helps teams find you"
            role={roleFromLogin}
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

export default function SignupPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex items-center justify-center">
          <div className="text-center">
            <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>Loading...</p>
          </div>
        </div>
      }
    >
      <SignupPageContent />
    </Suspense>
  )
}

