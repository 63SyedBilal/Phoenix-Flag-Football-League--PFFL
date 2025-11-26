"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Bell, UserPlus, MoreVertical } from "lucide-react"
import Image from "next/image"
import TeamUsersCard from "@/components/cards/team-users-card"
import PageHeader from "@/components/layout/page-header"

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
          setError("Please login to view your team")
          setIsLoading(false)
          return
        }

        const userData = JSON.parse(localStorage.getItem("user") || "{}")
        const userId = userData.id
        const role = userData.role
        setUserRole(role || "")

        if (!userId) {
          setError("User ID not found")
          setIsLoading(false)
          return
        }

        // Fetch team - if captain, get by captainId; if player, get by playerId
        let apiUrl = ""
        if (role === "captain") {
          apiUrl = `/api/team?captainId=${userId}`
        } else if (role === "player" || role === "free-agent") {
          apiUrl = `/api/team?playerId=${userId}`
        } else {
          setError("You don't have access to team information")
          setIsLoading(false)
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

        // Fetch profiles for captain and players to get position and payment status
        const allUserIds = [team.captain._id, ...team.players.map((p: any) => p._id)]
        const profilesMap = new Map()

        // Fetch profiles for all users
        for (const userId of allUserIds) {
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

        // Add captain
        const captainProfile = profilesMap.get(team.captain._id)
        members.push({
          id: team.captain._id,
          name: `#${captainProfile?.jerseyNumber || ""} ${team.captain.firstName} ${team.captain.lastName}`,
          email: team.captain.email,
          position: captainProfile?.position || "N/A",
          avatar: captainProfile?.image || "/placeholder-user.jpg",
    role: "Captain" as const,
          paymentStatus: (captainProfile?.paymentStatus === "paid" ? "Paid" : "Unpaid") as const,
    showClockIcon: false,
        })

        // Add players
        team.players.forEach((player: any) => {
          const playerProfile = profilesMap.get(player._id)
          members.push({
            id: player._id,
            name: `#${playerProfile?.jerseyNumber || ""} ${player.firstName} ${player.lastName}`,
            email: player.email,
            position: playerProfile?.position || "N/A",
            avatar: playerProfile?.image || "/placeholder-user.jpg",
    role: "Player" as const,
            paymentStatus: (playerProfile?.paymentStatus === "paid" ? "Paid" : "Unpaid") as const,
    showClockIcon: true,
          })
        })

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

  const currentRoster = teamMembers.length
  const maxRoster = selectedFormat === "5v5" ? 5 : 7

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>Loading team data...</p>
      </div>
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
          <button className="w-[60px] h-[60px] p-3 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center relative">
            <Bell className="w-5 h-5 text-foreground" />
            <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
          </button>
          {userRole === "captain" && (
            <button
              onClick={() => router.push(`/pffl/team/invite?format=${selectedFormat}`)}
              className="flex items-center justify-center gap-2 text-white font-medium rounded-xl"
              style={{
                width: "111px",
                height: "50px",
                gap: "8px",
                borderRadius: "14px",
                backgroundColor: "#3B82F6",
              }}
            >
              <UserPlus className="w-5 h-5" />
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





