"use client"

import React, { useState, useEffect } from "react"
import { ChevronLeft, Upload, Search, ChevronDown, ChevronUp } from "lucide-react"
import { useRouter } from "next/navigation"

const PRIMARY_COLOR = "#0F173E"

interface FormData {
  format: "5v5" | "7v7" | ""
  leagueName: string
  logo: File | null
  startDate: string
  endDate: string
  minPlayers: string
  entryFeeType: string
  perPlayerFee: string
}

interface SelectableUser {
  id: string
  name: string
  avatar: string
  _id?: string
  firstName?: string
  lastName?: string
  email?: string
}

interface SelectableTeam {
  id: string
  name: string
  logo: string
  playerCount: number
  _id?: string
  teamName?: string
  image?: string
  players?: Array<{
    jerseyNumber: string
    name: string
    position: string
  }>
}

export default function CreateLeagueForm({
  onClose,
}: {
  onClose?: () => void
}) {
  const router = useRouter()
  const [step, setStep] = useState(1)
  const [formData, setFormData] = useState<FormData>({
    format: "",
    leagueName: "",
    logo: null,
    startDate: "",
    endDate: "",
    minPlayers: "",
    entryFeeType: "",
    perPlayerFee: "",
  })

  const [selectedReferees, setSelectedReferees] = useState<Set<string>>(new Set())
  const [selectedStatKeepers, setSelectedStatKeepers] = useState<Set<string>>(new Set())
  const [selectedTeams, setSelectedTeams] = useState<Set<string>>(new Set())

  const [referees, setReferees] = useState<SelectableUser[]>([])
  const [statKeepers, setStatKeepers] = useState<SelectableUser[]>([])
  const [teams, setTeams] = useState<SelectableTeam[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [isLoadingData, setIsLoadingData] = useState(false)
  const [error, setError] = useState("")
  const [successMessages, setSuccessMessages] = useState<string[]>([])
  const [invitationErrors, setInvitationErrors] = useState<string[]>([])
  const [searchReferee, setSearchReferee] = useState("")
  const [searchStatKeeper, setSearchStatKeeper] = useState("")
  const [searchTeam, setSearchTeam] = useState("")
  const [leagueId, setLeagueId] = useState<string | null>(null)

  // Fetch referees, stat keepers, and teams
  useEffect(() => {
    const fetchData = async () => {
      setIsLoadingData(true)
      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to continue")
          setIsLoadingData(false)
          return
        }

        // Fetch referees and free-agents (free-agents can become referees)
        const [refereesResponse, freeAgentsResponse] = await Promise.all([
          fetch("/api/user?role=referee", {
            headers: {
              "Authorization": `Bearer ${token}`,
            },
          }),
          fetch("/api/user?role=free-agent", {
            headers: {
              "Authorization": `Bearer ${token}`,
            },
          })
        ])
        
        const allReferees: any[] = []
        
        if (refereesResponse.ok) {
          const refereesData = await refereesResponse.json()
          const formattedReferees = (refereesData.data || []).map((user: any) => ({
            id: user._id,
            _id: user._id,
            name: `${user.firstName || ""} ${user.lastName || ""}`.trim() || user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${user.email}`,
            role: "referee"
          }))
          allReferees.push(...formattedReferees)
        }
        
        if (freeAgentsResponse.ok) {
          const freeAgentsData = await freeAgentsResponse.json()
          const formattedFreeAgents = (freeAgentsData.data || []).map((user: any) => ({
            id: user._id,
            _id: user._id,
            name: `${user.firstName || ""} ${user.lastName || ""}`.trim() || user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${user.email}`,
            role: "free-agent"
          }))
          allReferees.push(...formattedFreeAgents)
        }
        
        setReferees(allReferees)

        // Fetch stat keepers
        const statKeepersResponse = await fetch("/api/user?role=stat-keeper", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })
        if (statKeepersResponse.ok) {
          const statKeepersData = await statKeepersResponse.json()
          const formattedStatKeepers = (statKeepersData.data || []).map((user: any) => ({
            id: user._id,
            _id: user._id,
            name: `${user.firstName || ""} ${user.lastName || ""}`.trim() || user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${user.email}`,
          }))
          setStatKeepers(formattedStatKeepers)
        }

        // Fetch teams
        const teamsResponse = await fetch("/api/team", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })
        if (teamsResponse.ok) {
          const teamsData = await teamsResponse.json()
          const formattedTeams = (teamsData.data || []).map((team: any) => ({
            id: team._id,
            _id: team._id,
            name: team.teamName,
            teamName: team.teamName,
            logo: team.image || "🏈",
            image: team.image,
            playerCount: team.players?.length || 0,
            players: team.players || [],
          }))
          setTeams(formattedTeams)
        }
      } catch (err) {
        console.error("Error fetching data:", err)
      } finally {
        setIsLoadingData(false)
      }
    }

    fetchData()
  }, [])

  const handleLogoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) {
      setFormData({ ...formData, logo: e.target.files[0] })
    }
  }

  const toggleReferee = (id: string) => {
    const newSet = new Set(selectedReferees)
    if (newSet.has(id)) {
      newSet.delete(id)
    } else {
      newSet.add(id)
    }
    setSelectedReferees(newSet)
  }

  const toggleStatKeeper = (id: string) => {
    const newSet = new Set(selectedStatKeepers)
    if (newSet.has(id)) {
      newSet.delete(id)
    } else {
      newSet.add(id)
    }
    setSelectedStatKeepers(newSet)
  }

  const toggleTeam = (id: string) => {
    const newSet = new Set(selectedTeams)
    if (newSet.has(id)) {
      newSet.delete(id)
    } else {
      newSet.add(id)
    }
    setSelectedTeams(newSet)
  }

  const handleNext = async () => {
    // Step 1: Validate and create league
    if (step === 1) {
      const errors: string[] = []
      
      if (!formData.format) {
        errors.push("Please select a format (5v5 or 7v7)")
      }
      
      if (!formData.leagueName || formData.leagueName.trim() === "") {
        errors.push("League name is required")
      }
      
      if (!formData.startDate) {
        errors.push("Start date is required")
      }
      
      if (!formData.endDate) {
        errors.push("End date is required")
      }
      
      if (!formData.minPlayers || formData.minPlayers.trim() === "") {
        errors.push("Minimum players required is required")
      } else if (parseInt(formData.minPlayers) < 1) {
        errors.push("Minimum players must be at least 1")
      }
      
      if (!formData.entryFeeType) {
        errors.push("Entry fee type is required")
      }
      
      if (!formData.perPlayerFee || formData.perPlayerFee.trim() === "") {
        errors.push("Per player league fee is required")
      } else if (parseFloat(formData.perPlayerFee) < 0) {
        errors.push("Per player league fee must be 0 or greater")
      }
      
      // Validate date range
      if (formData.startDate && formData.endDate) {
        const start = new Date(formData.startDate)
        const end = new Date(formData.endDate)
        if (start >= end) {
          errors.push("End date must be after start date")
        }
      }
      
      if (errors.length > 0) {
        setError(errors.join(". "))
        return
      }
      
      // Create league now
      setIsLoading(true)
      setError("")
      
      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Session expired. Please login again.")
          setIsLoading(false)
          return
        }

        let logoUrl = ""

        // Upload logo to Cloudinary if provided
        if (formData.logo) {
          try {
            const formDataToUpload = new FormData()
            formDataToUpload.append("file", formData.logo)
            formDataToUpload.append("folder", "pffl/leagues")

            const uploadResponse = await fetch("/api/upload", {
              method: "POST",
              body: formDataToUpload,
            })

            if (!uploadResponse.ok) {
              const errorData = await uploadResponse.json()
              throw new Error(errorData.error || "Failed to upload logo")
            }

            const uploadData = await uploadResponse.json()
            logoUrl = uploadData.data.url
          } catch (uploadError) {
            console.error("Logo upload error:", uploadError)
            setError("Failed to upload logo. Please try again.")
            setIsLoading(false)
            return
          }
        }

        // Prepare league data
        const leagueData: any = {
          leagueName: formData.leagueName.trim(),
          format: formData.format,
          startDate: formData.startDate,
          endDate: formData.endDate,
          minimumPlayers: parseInt(formData.minPlayers),
          entryFeeType: formData.entryFeeType === "stripe" || formData.entryFeeType === "paypal" 
            ? formData.entryFeeType 
            : "stripe",
          perPlayerLeagueFee: parseFloat(formData.perPlayerFee) || 0,
          logo: logoUrl,
          status: "pending",
        }

        // Create league
        const response = await fetch("/api/league", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
          },
          body: JSON.stringify(leagueData),
        })

        const data = await response.json()

        if (!response.ok) {
          setError(data.error || "Failed to create league")
          setIsLoading(false)
          return
        }

        // Extract league ID
        console.log("Step 1 - Full API response:", JSON.stringify(data, null, 2));
        let extractedLeagueId = null
        if (data.data) {
          extractedLeagueId = data.data._id || data.data.id
          console.log("Step 1 - Initial extraction - _id:", data.data._id, "id:", data.data.id);
          if (!extractedLeagueId && (data.data as any)._id) {
            extractedLeagueId = (data.data as any)._id.toString ? (data.data as any)._id.toString() : (data.data as any)._id
            console.log("Step 1 - Extracted from _id object:", extractedLeagueId);
          }
        }

        if (!extractedLeagueId) {
          console.error("Step 1 - Failed to extract league ID from response:", JSON.stringify(data, null, 2))
          setError("Failed to get league ID. Please try again.")
          setIsLoading(false)
          return
        }

        extractedLeagueId = extractedLeagueId.toString()
        setLeagueId(extractedLeagueId)
        console.log("Step 1 - League created with ID:", extractedLeagueId)
        console.log("Step 1 - League ID type:", typeof extractedLeagueId)
        console.log("Step 1 - League ID stored in state")
        
        setSuccessMessages(["League created successfully!"])
        setIsLoading(false)
        setError("")
        
        // Move to next step
        setStep(2)
        return
      } catch (err: any) {
        console.error("Error creating league:", err)
        setError(err.message || "An error occurred while creating the league")
        setIsLoading(false)
        return
      }
    }
    
    // Step 2: Just move to next step (no invitations yet)
    if (step === 2) {
      setStep(3)
      return
    }

    // Step 3: Just move to next step (no invitations yet)
    if (step === 3) {
      setStep(4)
      return
    }

    // Step 4: Send all invitations (referees, stat keepers, teams) and finish
    if (step === 4) {
      // Check if league ID exists
      if (!leagueId) {
        setError("League ID not found. Please go back and create the league again.")
        return
      }

      setIsLoading(true)
      setError("")
      const successMessages: string[] = []
      const errorMessages: string[] = []

      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Session expired. Please login again.")
          setIsLoading(false)
          return
        }

        // Send invitations for referees
        const refereeIds = Array.from(selectedReferees)
        if (refereeIds.length > 0) {
          for (const refereeId of refereeIds) {
            try {
              const inviteResponse = await fetch(`/api/league/${leagueId}/invite-referee`, {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": `Bearer ${token}`,
                },
                body: JSON.stringify({ refereeId }),
              })
              
              const inviteData = await inviteResponse.json()
              if (!inviteResponse.ok) {
                console.error("Error inviting referee:", inviteData.error)
                const refereeName = referees.find(r => r.id === refereeId)?.name || "Referee"
                errorMessages.push(`Failed to invite ${refereeName}: ${inviteData.error}`)
    } else {
                console.log("Referee invitation sent successfully:", inviteData)
                const refereeName = referees.find(r => r.id === refereeId)?.name || "Referee"
                successMessages.push(`✓ Invitation sent to ${refereeName}`)
              }
            } catch (err: any) {
              console.error("Error inviting referee:", err)
              const refereeName = referees.find(r => r.id === refereeId)?.name || "Referee"
              errorMessages.push(`Failed to invite ${refereeName}: ${err.message || "Unknown error"}`)
            }
          }
        }

        // Send invitations for stat keepers
        const statKeeperIds = Array.from(selectedStatKeepers)
        if (statKeeperIds.length > 0) {
          console.log("Step 4 - Sending stat keeper invitations with leagueId:", leagueId);
          console.log("Step 4 - LeagueId type:", typeof leagueId);
          console.log("Step 4 - Stat keeper IDs:", statKeeperIds);
          
          for (const statKeeperId of statKeeperIds) {
            try {
              const inviteUrl = `/api/league/${leagueId}/invite-statkeeper`;
              console.log("Step 4 - Inviting stat keeper - URL:", inviteUrl);
              console.log("Step 4 - Inviting stat keeper - Body:", { statKeeperId });
              
              const inviteResponse = await fetch(inviteUrl, {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": `Bearer ${token}`,
                },
                body: JSON.stringify({ statKeeperId }),
              })
              
              const inviteData = await inviteResponse.json()
              if (!inviteResponse.ok) {
                console.error("Error inviting stat keeper:", inviteData.error)
                const statKeeperName = statKeepers.find(sk => sk.id === statKeeperId)?.name || "Stat Keeper"
                errorMessages.push(`Failed to invite ${statKeeperName}: ${inviteData.error}`)
              } else {
                console.log("Stat keeper invitation sent successfully:", inviteData)
                const statKeeperName = statKeepers.find(sk => sk.id === statKeeperId)?.name || "Stat Keeper"
                successMessages.push(`✓ Invitation sent to ${statKeeperName}`)
              }
            } catch (err: any) {
              console.error("Error inviting stat keeper:", err)
              const statKeeperName = statKeepers.find(sk => sk.id === statKeeperId)?.name || "Stat Keeper"
              errorMessages.push(`Failed to invite ${statKeeperName}: ${err.message || "Unknown error"}`)
            }
          }
        }

        // Send invitations for teams
        const teamIds = Array.from(selectedTeams)
        if (teamIds.length > 0) {
          for (const teamId of teamIds) {
            try {
              const inviteResponse = await fetch(`/api/league/${leagueId}/invite-team`, {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": `Bearer ${token}`,
                },
                body: JSON.stringify({ teamId }),
              })
              
              const inviteData = await inviteResponse.json()
              if (!inviteResponse.ok) {
                console.error("Error inviting team:", inviteData.error)
                const teamName = teams.find(t => t.id === teamId)?.name || "Team"
                errorMessages.push(`Failed to invite ${teamName}: ${inviteData.error}`)
              } else {
                console.log("Team invitation sent successfully:", inviteData)
                const teamName = teams.find(t => t.id === teamId)?.name || "Team"
                successMessages.push(`✓ Invitation sent to ${teamName}`)
              }
            } catch (err: any) {
              console.error("Error inviting team:", err)
              const teamName = teams.find(t => t.id === teamId)?.name || "Team"
              errorMessages.push(`Failed to invite ${teamName}: ${err.message || "Unknown error"}`)
            }
          }
        }

        // Set success and error messages separately
        if (successMessages.length > 0) {
          setSuccessMessages(successMessages)
        } else {
          setSuccessMessages(["League created successfully! No invitations to send."])
        }
        
        if (errorMessages.length > 0) {
          setInvitationErrors(errorMessages)
        } else {
          setInvitationErrors([])
        }
        
        setIsLoading(false)
        
        // Close form and refresh after showing messages
        setTimeout(() => {
      onClose?.()
          router.refresh()
        }, 3000)
        return
      } catch (err: any) {
        console.error("Error sending invitations:", err)
        setError(err.message || "An error occurred while sending invitations")
        setIsLoading(false)
        return
      }
    }
  }

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1)
    } else {
      onClose?.()
    }
  }

  const steps = [
    { number: 1, name: "Create League" },
    { number: 2, name: "Referees" },
    { number: 3, name: "Stat Keeper" },
    { number: 4, name: "Invite Teams" },
  ]

  return (
    <div className="flex flex-col gap-6">
      {/* Header */}
      <div className="flex flex-col gap-4">
        <button
          onClick={handleBack}
          className="flex items-center justify-center hover:opacity-80 transition-opacity self-start"
          style={{
            width: "50px",
            height: "50px",
            padding: "10px",
            borderRadius: "50px",
            backgroundColor: "#F2F2F2",
          }}
        >
          <img
            src="/assets/image/Back arrow.svg"
            alt="back"
            className="w-5 h-5"
          />
        </button>
        <div>
          <h1 className="text-3xl font-bold text-foreground">Create League</h1>
          <p className="text-muted-foreground mt-1">
            {step === 1 && "Enter league information below to create a new tournament."}
            {step === 2 && "Choose referees for this league. You can select from existing referees or free-agents (free-agents will become referees when they accept)."}
            {step === 3 && "Choose Stat Keepers for this league. You can invite new Stat Keepers or select from existing ones."}
            {step === 4 && "Invite teams to join this league. You can search existing teams."}
          </p>
        </div>
      </div>

      {/* Progress Nodes */}
      <div className="flex items-center justify-between relative w-full">
        {steps.map((s, index) => (
          <React.Fragment key={s.number}>
            <div className="flex flex-col items-center relative z-10 flex-shrink-0" style={{ width: "90px", minWidth: "90px", height: "79px", gap: "12px" }}>
              <div
                className="rounded-full flex items-center justify-center font-semibold text-sm transition-colors relative z-10 bg-white flex-shrink-0"
                style={{
                  width: "50px",
                  height: "50px",
                  minWidth: "50px",
                  padding: "13px",
                  backgroundColor: step >= s.number ? PRIMARY_COLOR : "#FFFFFF",
                  border: `1px solid ${PRIMARY_COLOR}`,
                  color: step >= s.number ? "#FFFFFF" : "#000000",
                }}
              >
                {step > s.number ? "✓" : s.number}
              </div>
              <span
                className="text-center block"
                style={{
                  width: "90px",
                  minWidth: "90px",
                  height: "17px",
                  fontFamily: "Lato, sans-serif",
                  fontWeight: 400,
                  fontSize: "14px",
                  lineHeight: "100%",
                  color: "#000000",
                }}
              >
                {s.name}
              </span>
            </div>
            {index < steps.length - 1 && (
              <div
                className="flex-1 relative z-0"
                style={{
                  height: "50px",
                  display: "flex",
                  alignItems: "center",
                }}
              >
                <div
                  className="h-0 border-t-2"
                  style={{
                    borderColor: "rgba(15, 23, 62, 0.2)",
                    borderWidth: "1.8px",
                    width: "100%",
                    marginLeft: "20px",
                    marginRight: "20px",
                  }}
                />
              </div>
            )}
          </React.Fragment>
        ))}
      </div>

      {/* Form Content */}
      <form
        className="flex flex-col gap-[18px]"
        onSubmit={(e) => {
          e.preventDefault()
          handleNext()
        }}
      >
        {/* Step 1: Create League */}
        {step === 1 && (
          <div className="flex flex-col gap-[18px]">
            {/* Select Format */}
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
                Format <span className="text-red-500">*</span>
              </label>
            <div className="flex gap-1">
              {["5v5", "7v7"].map((format) => (
                <button
                  key={format}
                  type="button"
                    onClick={() => {
                    setFormData({
                      ...formData,
                      format: format as "5v5" | "7v7",
                    })
                      if (error) setError("") // Clear error when user selects format
                    }}
                  className="flex-1 h-12 px-3 py-[10px] rounded-md font-medium transition-colors"
                  style={{
                    backgroundColor: formData.format === format ? PRIMARY_COLOR : "#FFFFFF",
                    color: formData.format === format ? "#FFFFFF" : "#000000",
                      border: formData.format === format ? "none" : (!formData.format && error ? "1px solid #EF4444" : "1px solid #D1D5DB"),
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  }}
                >
                  {format}
                </button>
              ))}
              </div>
            </div>

            {/* League Name */}
            <div className="flex flex-col gap-3">
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
                League Name <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                placeholder="Enter League Name"
                value={formData.leagueName}
                onChange={(e) => {
                  setFormData({ ...formData, leagueName: e.target.value })
                  if (error) setError("") // Clear error when user starts typing
                }}
                className="w-full h-12 px-3 py-[10px] rounded-md border"
                style={{
                  border: !formData.leagueName && error ? "1px solid #EF4444" : "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
                required
              />
            </div>

            {/* Upload Logo */}
            <div className="flex flex-col gap-3">
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
                Upload Logo
              </label>
              <div
                className="w-full min-h-[161px] px-3 py-[10px] rounded-md border-dashed flex flex-col items-center justify-center gap-3 cursor-pointer hover:bg-gray-50 transition-colors"
                style={{
                  border: "1px solid #D1D5DB",
                  borderStyle: "dashed",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              >
                {formData.logo ? (
                  <div className="flex items-center justify-center gap-4">
                    <div className="text-4xl">{formData.logo.name.split(".")[0]}</div>
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, logo: null })}
                      className="text-red-600 hover:text-red-700"
                    >
                      Remove
                    </button>
                  </div>
                ) : (
                  <>
                    <p className="text-gray-600 mb-2">Tap below to upload your league logo.</p>
                    <label
                      className="inline-flex items-center gap-2 px-4 py-2 rounded-full font-medium text-white cursor-pointer transition-colors"
                      style={{ backgroundColor: PRIMARY_COLOR }}
                    >
                      <Upload className="w-4 h-4" />
                      Upload
                      <input type="file" accept="image/*" onChange={handleLogoUpload} className="hidden" />
                    </label>
                  </>
                )}
              </div>
            </div>

            {/* Dates */}
            <div className="grid grid-cols-2 gap-4">
              <div className="flex flex-col gap-3">
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
                  Start Date <span className="text-red-500">*</span>
                </label>
                <input
                  type="date"
                  value={formData.startDate}
                  onChange={(e) => {
                    setFormData({ ...formData, startDate: e.target.value })
                    if (error) setError("") // Clear error when user starts typing
                  }}
                  className="w-full h-12 px-3 py-[10px] rounded-md border"
                  style={{
                    border: !formData.startDate && error ? "1px solid #EF4444" : "1px solid #D1D5DB",
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                    backgroundColor: "#FFFFFF",
                  }}
                  required
                />
              </div>
              <div className="flex flex-col gap-3">
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
                  End Date <span className="text-red-500">*</span>
                </label>
                <input
                  type="date"
                  value={formData.endDate}
                  min={formData.startDate || undefined}
                  onChange={(e) => {
                    setFormData({ ...formData, endDate: e.target.value })
                    if (error) setError("") // Clear error when user starts typing
                  }}
                  className="w-full h-12 px-3 py-[10px] rounded-md border"
                  style={{
                    border: !formData.endDate && error ? "1px solid #EF4444" : "1px solid #D1D5DB",
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                    backgroundColor: "#FFFFFF",
                  }}
                  required
                />
              </div>
            </div>

            {/* Three Fields Row */}
            <div className="grid grid-cols-3 gap-4">
              <div className="flex flex-col gap-3">
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
                  Minimum Players Required <span className="text-red-500">*</span>
                </label>
                <input
                  type="number"
                  placeholder="Enter number"
                  min="1"
                    value={formData.minPlayers}
                  onChange={(e) => {
                    setFormData({ ...formData, minPlayers: e.target.value })
                    if (error) setError("") // Clear error when user starts typing
                  }}
                  className="w-full h-12 px-3 py-[10px] rounded-md border"
                    style={{
                    border: (!formData.minPlayers || parseInt(formData.minPlayers) < 1) && error ? "1px solid #EF4444" : "1px solid #D1D5DB",
                      boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                      backgroundColor: "#FFFFFF",
                    }}
                  required
                />
              </div>
              <div className="flex flex-col gap-3">
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
                  Entry Fee Type <span className="text-red-500">*</span>
                </label>
                <div className="relative">
                  <select
                    value={formData.entryFeeType}
                    onChange={(e) => {
                      setFormData({ ...formData, entryFeeType: e.target.value })
                      if (error) setError("") // Clear error when user starts typing
                    }}
                    className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border appearance-none"
                    style={{
                      border: !formData.entryFeeType && error ? "1px solid #EF4444" : "1px solid #D1D5DB",
                      boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                      backgroundColor: "#FFFFFF",
                    }}
                    required
                  >
                    <option value="">Select</option>
                    <option value="stripe">Stripe</option>
                    <option value="paypal">PayPal</option>
                  </select>
                  <img
                    src="/assets/image/arrow-down.svg"
                    alt=""
                    className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 pointer-events-none"
                  />
                </div>
              </div>
              <div className="flex flex-col gap-3">
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
                  Per Player League Fee <span className="text-red-500">*</span>
                </label>
                <input
                  type="number"
                  placeholder="$250"
                  min="0"
                  step="0.01"
                  value={formData.perPlayerFee}
                  onChange={(e) => {
                    setFormData({ ...formData, perPlayerFee: e.target.value })
                    if (error) setError("") // Clear error when user starts typing
                  }}
                  className="w-full h-12 px-3 py-[10px] rounded-md border"
                  style={{
                    border: (!formData.perPlayerFee || parseFloat(formData.perPlayerFee) < 0) && error ? "1px solid #EF4444" : "1px solid #D1D5DB",
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                    backgroundColor: "#FFFFFF",
                  }}
                  required
                />
              </div>
            </div>
          </div>
        )}

        {/* Step 2: Referees */}
        {step === 2 && (
          <div className="space-y-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search by Referee name"
                value={searchReferee}
                onChange={(e) => setSearchReferee(e.target.value)}
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              />
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
            {isLoadingData ? (
              <div className="text-center py-8 text-gray-500">Loading referees...</div>
            ) : (
            <div className="space-y-3 max-h-96 overflow-y-auto">
                {referees
                  .filter((referee) =>
                    referee.name.toLowerCase().includes(searchReferee.toLowerCase())
                  )
                  .map((referee) => {
                const isSelected = selectedReferees.has(referee.id)
                return (
                  <div
                    key={referee.id}
                    className="flex items-center justify-between p-3 rounded-md border cursor-pointer hover:bg-gray-50 transition-colors w-full"
                    style={{
                      height: "64px",
                      gap: "10px",
                      border: "1px solid rgba(0, 0, 0, 0.12)",
                      backgroundColor: "#FFFFFF",
                    }}
                    onClick={() => toggleReferee(referee.id)}
                  >
                    <div className="flex items-center gap-[10px]">
                      <img
                        src={referee.avatar || "/placeholder.svg"}
                        alt={referee.name}
                        className="w-10 h-10 rounded-full flex-shrink-0"
                      />
                      <span className="font-medium text-gray-900">{referee.name}</span>
                    </div>
                    <img
                      src={isSelected ? "/assets/image/ic_baseline-email.svg" : "/assets/image/ic_outline-email.svg"}
                      alt="email"
                      className="w-5 h-5 cursor-pointer flex-shrink-0"
                    />
                  </div>
                )
              })}
                {referees.filter((referee) =>
                  referee.name.toLowerCase().includes(searchReferee.toLowerCase())
                ).length === 0 && (
                  <div className="text-center py-8 text-gray-500">No referees found</div>
                )}
            </div>
            )}
          </div>
        )}

        {/* Step 3: Stat Keepers */}
        {step === 3 && (
          <div className="space-y-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search by Stat Keeper name"
                value={searchStatKeeper}
                onChange={(e) => setSearchStatKeeper(e.target.value)}
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              />
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
            {isLoadingData ? (
              <div className="text-center py-8 text-gray-500">Loading stat keepers...</div>
            ) : (
            <div className="space-y-3 max-h-96 overflow-y-auto">
                {statKeepers
                  .filter((keeper) =>
                    keeper.name.toLowerCase().includes(searchStatKeeper.toLowerCase())
                  )
                  .map((keeper) => {
                const isSelected = selectedStatKeepers.has(keeper.id)
                return (
                  <div
                    key={keeper.id}
                    className="flex items-center justify-between p-3 rounded-md border cursor-pointer hover:bg-gray-50 transition-colors w-full"
                    style={{
                      height: "64px",
                      gap: "10px",
                      border: "1px solid rgba(0, 0, 0, 0.12)",
                      backgroundColor: "#FFFFFF",
                    }}
                    onClick={() => toggleStatKeeper(keeper.id)}
                  >
                    <div className="flex items-center gap-[10px]">
                      <img
                        src={keeper.avatar || "/placeholder.svg"}
                        alt={keeper.name}
                        className="w-10 h-10 rounded-full flex-shrink-0"
                      />
                      <span className="font-medium text-gray-900">{keeper.name}</span>
                    </div>
                    <img
                      src={isSelected ? "/assets/image/ic_baseline-email.svg" : "/assets/image/ic_outline-email.svg"}
                      alt="email"
                      className="w-5 h-5 cursor-pointer flex-shrink-0"
                    />
                  </div>
                )
              })}
                {statKeepers.filter((keeper) =>
                  keeper.name.toLowerCase().includes(searchStatKeeper.toLowerCase())
                ).length === 0 && (
                  <div className="text-center py-8 text-gray-500">No stat keepers found</div>
                )}
            </div>
            )}
          </div>
        )}

        {/* Step 4: Teams */}
        {step === 4 && (
          <div className="space-y-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search by Team name"
                value={searchTeam}
                onChange={(e) => setSearchTeam(e.target.value)}
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              />
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
            {isLoadingData ? (
              <div className="text-center py-8 text-gray-500">Loading teams...</div>
            ) : (
            <div className="space-y-3 max-h-96 overflow-y-auto">
                {teams
                  .filter((team) =>
                    team.name.toLowerCase().includes(searchTeam.toLowerCase())
                  )
                  .map((team) => {
                const isExpanded = selectedTeams.has(team.id)
                    const isSelected = selectedTeams.has(team.id)
                return (
                  <div
                    key={team.id}
                    className="rounded-md border w-full p-3"
                    style={{
                      border: "1px solid rgba(0, 0, 0, 0.12)",
                      backgroundColor: "#FFFFFF",
                      borderRadius: "6px",
                      padding: "12px",
                      gap: "12px",
                    }}
                  >
                    <div
                      className="cursor-pointer hover:bg-gray-50 transition-colors -m-3 p-3"
                      onClick={() => toggleTeam(team.id)}
                    >
                      <div className="flex items-start gap-[10px]">
                            <div className="text-2xl flex-shrink-0">
                              {team.image ? (
                                <img src={team.image} alt={team.name} className="w-8 h-8 rounded" />
                              ) : (
                                team.logo
                              )}
                            </div>
                        <div className="flex flex-col gap-1 flex-1 w-full">
                          <div className="flex items-center justify-between w-full">
                            <p className="font-semibold text-gray-900">{team.name}</p>
                            <img
                                  src={isSelected ? "/assets/image/ic_baseline-email.svg" : "/assets/image/ic_outline-email.svg"}
                              alt="email"
                              className="w-5 h-5 flex-shrink-0"
                            />
                          </div>
                          <div className="flex items-center justify-between w-full">
                            <p className="text-sm text-gray-600">
                                  {team.playerCount} {team.playerCount === 1 ? "player" : "players"}
                            </p>
                            {isExpanded ? (
                              <ChevronUp className="w-5 h-5 text-gray-400 flex-shrink-0" />
                            ) : (
                              <ChevronDown className="w-5 h-5 text-gray-400 flex-shrink-0" />
                            )}
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Team Roster */}
                        {isExpanded && team.players && team.players.length > 0 && (
                      <div
                        className="border rounded-md p-3 mt-3 w-full"
                        style={{
                          gap: "12px",
                          border: "1px solid rgba(0, 0, 0, 0.12)",
                          borderRadius: "6px",
                          backgroundColor: "#FFFFFF",
                          padding: "12px",
                        }}
                      >
                        <div className="space-y-2">
                              {team.players.slice(0, 5).map((player: any, idx: number) => (
                            <div key={idx} className="flex items-center justify-between text-sm">
                              <div className="grid grid-cols-3 gap-8 flex-1">
                                    <span className="text-gray-700">#{player.jerseyNumber || idx + 1}</span>
                                    <span className="text-gray-900 font-medium">
                                      {player.firstName} {player.lastName}
                                    </span>
                                    <span className="text-gray-600">{player.position || "N/A"}</span>
                              </div>
                            </div>
                          ))}
                              {team.players.length > 5 && (
                                <div className="text-sm text-gray-500 text-center">
                                  +{team.players.length - 5} more players
                                </div>
                              )}
                        </div>
                      </div>
                    )}
                  </div>
                )
              })}
                {teams.filter((team) =>
                  team.name.toLowerCase().includes(searchTeam.toLowerCase())
                ).length === 0 && (
                  <div className="text-center py-8 text-gray-500">No teams found</div>
                )}
            </div>
            )}
          </div>
        )}

        {/* Error Message */}
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md">
            {error}
          </div>
        )}

        {/* Invitation Error Messages */}
        {invitationErrors.length > 0 && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md space-y-1">
            <div className="font-semibold mb-2">Failed Invitations:</div>
            {invitationErrors.map((msg, idx) => (
              <div key={idx}>• {msg}</div>
            ))}
          </div>
        )}

        {/* Success Messages */}
        {successMessages.length > 0 && (
          <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-md space-y-1">
            {successMessages.length > 1 && <div className="font-semibold mb-2">Successful Invitations:</div>}
            {successMessages.map((msg, idx) => (
              <div key={idx}>{msg}</div>
            ))}
          </div>
        )}

        {/* Next Button */}
        <button
          type="submit"
          disabled={isLoading}
          className="w-full h-[58px] rounded-full text-white font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style={{ backgroundColor: PRIMARY_COLOR }}
        >
          {isLoading 
            ? (step === 1 ? "Creating League..." : step === 2 ? "Sending Invitations..." : step === 3 ? "Sending Invitations..." : "Finishing...")
            : step === 1 
              ? "Create League & Continue" 
              : step === 4 
                ? "Finish" 
                : "Next"}
        </button>
      </form>
    </div>
  )
}
