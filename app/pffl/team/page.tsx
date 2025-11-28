"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Bell, UserPlus, MoreVertical } from "lucide-react"
import Image from "next/image"
import TeamUsersCard from "@/components/cards/team-users-card"
import PageHeader from "@/components/layout/page-header"
import BellNotificationButton from "@/components/layout/bell-notification-button"
import LoadingSpinner from "@/components/ui/loading-spinner"

interface TeamMember {
  id: string
  name: string
  email: string
  position: string
  avatar: string
  role: "Captain" | "Player"
  paymentStatus: "Paid" | "Unpaid"
  showClockIcon: boolean
}

interface TeamData {
  _id: string
  teamName: string
  enterCode: string
  location: string
  skillLevel: string
  format: string
  image: string
  captain: {
    _id: string
    firstName: string
    lastName: string
    email: string
    role: string
  }
  players: Array<{
    _id: string
    firstName: string
    lastName: string
    email: string
    role: string
  }>
  squad5v5?: Array<{
    _id: string
    firstName: string
    lastName: string
    email: string
    role: string
  }>
  squad7v7?: Array<{
    _id: string
    firstName: string
    lastName: string
    email: string
    role: string
  }>
}

export default function PfflTeamPage() {
  const router = useRouter()
  const [selectedFormat, setSelectedFormat] = useState("5v5")
  const [teamData, setTeamData] = useState<TeamData | null>(null)
  const [teamMembers, setTeamMembers] = useState<TeamMember[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState("")
  const [userRole, setUserRole] = useState<string>("")

  // Fetch team data
  useEffect(() => {
    const fetchTeamData = async () => {
      try {
        const token = localStorage.getItem("token")
        if (!token) {
          router.push("/not-found")
          return
        }

        const userData = JSON.parse(localStorage.getItem("user") || "{}")
        const userId = userData.id
        const role = userData.role
        setUserRole(role || "")

        if (!userId) {
          router.push("/not-found")
          return
        }

        // Fetch team - if captain, get by captainId; if player, get by playerId
        let apiUrl = ""
        if (role === "captain") {
          apiUrl = `/api/team?captainId=${userId}`
        } else if (role === "player" || role === "free-agent") {
          apiUrl = `/api/team?playerId=${userId}`
        } else {
          router.push("/not-found")
          return
        }

        const response = await fetch(apiUrl, {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          if (response.status === 404) {
            setError("Team not found. Please create a team first.")
          } else {
            const errorData = await response.json()
            setError(errorData.error || "Failed to fetch team data")
          }
          setIsLoading(false)
          return
        }

        const data = await response.json()
        const team = data.data

        if (!team) {
          setError("Team not found")
          setIsLoading(false)
          return
        }

        setTeamData(team)
        setSelectedFormat(team.format || "5v5")

        // Helper function to build team members for a format
        const buildTeamMembersForFormat = async (format: string) => {
          // Get squad for the selected format (API already populates these)
          const squadField = format === "5v5" ? "squad5v5" : "squad7v7"
          const squadPlayers = (team as any)[squadField] || []
          
          // Get all unique user IDs (captain + squad players)
          const captainId = team.captain._id.toString()
          const squadPlayerIds = squadPlayers.map((p: any) => {
            return p._id?.toString() || p.toString()
          })
          const allUserIds = [captainId, ...squadPlayerIds]
          const uniqueUserIds = [...new Set(allUserIds)]
          
          // Fetch profiles for all users
          const profilesMap = new Map()
          for (const userId of uniqueUserIds) {
            try {
              const profileResponse = await fetch(`/api/profile/${userId}`, {
                headers: {
                  "Authorization": `Bearer ${token}`,
                },
              })
              if (profileResponse.ok) {
                const profileData = await profileResponse.json()
                if (profileData.data) {
                  profilesMap.set(userId, profileData.data)
                }
              }
            } catch (err) {
              console.error(`Error fetching profile for ${userId}:`, err)
            }
          }

          // Build team members array
          const members: TeamMember[] = []

          // Add captain (always included)
          const captainProfile = profilesMap.get(captainId)
          const captainName = `#${captainProfile?.jerseyNumber || ""} ${team.captain.firstName} ${team.captain.lastName}`.trim()
          members.push({
            id: team.captain._id,
            name: captainName,
            email: team.captain.email,
            position: captainProfile?.position || "N/A",
            avatar: captainProfile?.image || "/placeholder-user.jpg",
            role: "Captain" as const,
            paymentStatus: (captainProfile?.paymentStatus === "paid" ? "Paid" : "Unpaid") as const,
            showClockIcon: false,
          })

          // Add squad players (from the selected format's squad)
          squadPlayers.forEach((player: any) => {
            const playerId = player._id?.toString() || player.toString()
            // Skip if it's the captain (already added)
            if (playerId === captainId) return
            
            const playerProfile = profilesMap.get(playerId)
            const firstName = player.firstName || ""
            const lastName = player.lastName || ""
            const playerName = `#${playerProfile?.jerseyNumber || ""} ${firstName} ${lastName}`.trim()
            
            members.push({
              id: playerId,
              name: playerName,
              email: player.email || "",
              position: playerProfile?.position || "N/A",
              avatar: playerProfile?.image || "/placeholder-user.jpg",
              role: "Player" as const,
              paymentStatus: (playerProfile?.paymentStatus === "paid" ? "Paid" : "Unpaid") as const,
              showClockIcon: true,
            })
          })

          return members
        }

        // Build initial team members for the team's format
        const members = await buildTeamMembersForFormat(team.format || "5v5")
        setTeamMembers(members)
        setIsLoading(false)
      } catch (err) {
        console.error("Error fetching team data:", err)
        setError("An error occurred while fetching team data")
        setIsLoading(false)
      }
    }

    fetchTeamData()
  }, [])

  // Update team members when format changes
  useEffect(() => {
    if (!teamData) return

    const updateTeamMembers = async () => {
      try {
        const token = localStorage.getItem("token")
        if (!token) return

        // Get squad for the selected format (API already populates these)
        const squadField = selectedFormat === "5v5" ? "squad5v5" : "squad7v7"
        const squadPlayers = (teamData as any)[squadField] || []
        
        // Get all unique user IDs (captain + squad players)
        const captainId = teamData.captain._id.toString()
        const squadPlayerIds = squadPlayers.map((p: any) => {
          return p._id?.toString() || p.toString()
        })
        const allUserIds = [captainId, ...squadPlayerIds]
        const uniqueUserIds = [...new Set(allUserIds)]
        
        // Fetch profiles for all users
        const profilesMap = new Map()
        for (const userId of uniqueUserIds) {
          try {
            const profileResponse = await fetch(`/api/profile/${userId}`, {
              headers: {
                "Authorization": `Bearer ${token}`,
              },
            })
            if (profileResponse.ok) {
              const profileData = await profileResponse.json()
              if (profileData.data) {
                profilesMap.set(userId, profileData.data)
              }
            }
          } catch (err) {
            console.error(`Error fetching profile for ${userId}:`, err)
          }
        }

        // Build team members array
        const members: TeamMember[] = []

        // Add captain (always included)
        const captainProfile = profilesMap.get(captainId)
        const captainName = `#${captainProfile?.jerseyNumber || ""} ${teamData.captain.firstName} ${teamData.captain.lastName}`.trim()
        members.push({
          id: teamData.captain._id,
          name: captainName,
          email: teamData.captain.email,
          position: captainProfile?.position || "N/A",
          avatar: captainProfile?.image || "/placeholder-user.jpg",
          role: "Captain" as const,
          paymentStatus: (captainProfile?.paymentStatus === "paid" ? "Paid" : "Unpaid") as const,
          showClockIcon: false,
        })

        // Add squad players (from the selected format's squad)
        squadPlayers.forEach((player: any) => {
          const playerId = player._id?.toString() || player.toString()
          // Skip if it's the captain (already added)
          if (playerId === captainId) return
          
          const playerProfile = profilesMap.get(playerId)
          const firstName = player.firstName || ""
          const lastName = player.lastName || ""
          const playerName = `#${playerProfile?.jerseyNumber || ""} ${firstName} ${lastName}`.trim()
          
          members.push({
            id: playerId,
            name: playerName,
            email: player.email || "",
            position: playerProfile?.position || "N/A",
            avatar: playerProfile?.image || "/placeholder-user.jpg",
            role: "Player" as const,
            paymentStatus: (playerProfile?.paymentStatus === "paid" ? "Paid" : "Unpaid") as const,
            showClockIcon: true,
          })
        })

        setTeamMembers(members)
      } catch (err) {
        console.error("Error updating team members:", err)
      }
    }

    updateTeamMembers()
  }, [selectedFormat, teamData])

  const currentRoster = teamMembers.length
  const maxRoster = selectedFormat === "5v5" ? 5 : 7

  if (isLoading) {
    return (
      <LoadingSpinner fullScreen text="Loading team data..." />
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <p style={{ fontFamily: "Lato, sans-serif", color: "#EF4444" }}>{error}</p>
        </div>
      </div>
    )
  }

  if (!teamData) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>No team data available</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-3">
      {/* Header Section */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-3xl font-bold text-foreground">My Team</h1>
          <p className="text-muted-foreground mt-1">View your team roster and player details.</p>
        </div>
        <div className="flex items-center gap-3">
          <BellNotificationButton notificationRoute="/pffl/settings/notifications" />
          {userRole === "captain" && (
            <button
              onClick={() => router.push(`/pffl/team/invite?format=${selectedFormat}`)}
              className="flex items-center justify-center gap-2 text-white font-medium rounded-xl"
              style={{
                width: "100px",
                height: "44px",
                gap: "7px",
                borderRadius: "14px",
                backgroundColor: "#3B82F6",
              }}
            >
              <UserPlus className="w-4 h-4" />
              <span>Invite</span>
            </button>
          )}
        </div>
      </div>

      {/* Team Information Section */}
      <div className="mb-4">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            {/* Team Logo */}
            <div className="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 overflow-hidden border-2 border-dashed border-gray-300">
              <Image
                src={teamData.image || "/placeholder-logo.png"}
                alt="Team Logo"
                width={48}
                height={48}
                className="w-12 h-12 rounded-full object-cover"
              />
            </div>
            {/* Team Name */}
            <h2 className="text-2xl font-bold text-foreground">{teamData.teamName}</h2>
          </div>
          <div className="flex items-center gap-3">
            {/* Roster Count */}
            <span className="text-lg font-medium text-foreground">
              {currentRoster}/{maxRoster}
            </span>
            {/* 3-dot Menu */}
            <button className="p-2 hover:bg-gray-100 rounded transition-colors">
              <MoreVertical className="w-5 h-5 text-gray-400" />
            </button>
          </div>
        </div>

        {/* Format Buttons */}
        <div className="flex items-center gap-2">
          <button
            onClick={() => setSelectedFormat("7v7")}
            className="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
            style={{
              backgroundColor: selectedFormat === "7v7" ? "#3B82F6" : "#FFFFFF",
              color: selectedFormat === "7v7" ? "#FFFFFF" : "#000000",
              border: selectedFormat === "7v7" ? "none" : "0.67px solid rgba(0, 0, 0, 0.12)",
            }}
          >
            7v7
          </button>
          <button
            onClick={() => setSelectedFormat("5v5")}
            className="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
            style={{
              backgroundColor: selectedFormat === "5v5" ? "#3B82F6" : "#FFFFFF",
              color: selectedFormat === "5v5" ? "#FFFFFF" : "#000000",
              border: selectedFormat === "5v5" ? "none" : "0.67px solid rgba(0, 0, 0, 0.12)",
            }}
          >
            5v5
          </button>
        </div>
      </div>

      {/* Team Member Cards */}
      <div className="space-y-3">
        {teamMembers.length > 0 ? (
          teamMembers.map((member) => (
          <TeamUsersCard
            key={member.id}
            id={member.id}
            name={member.name}
            email={member.email}
            position={member.position}
            avatar={member.avatar}
            role={member.role}
            paymentStatus={member.paymentStatus}
            showClockIcon={member.showClockIcon}
          />
          ))
        ) : (
          <div className="text-center py-8">
            <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>No team members yet</p>
        </div>
      )}
      </div>

    </div>
  )
}





