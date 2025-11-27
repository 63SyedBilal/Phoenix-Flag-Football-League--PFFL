"use client"

import { useState, useEffect, Suspense } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { Search, Mail } from "lucide-react"
import Image from "next/image"

interface User {
  _id: string
  firstName: string
  lastName: string
  email: string
  role: string
}

interface UserWithProfile extends User {
  profile?: {
    position?: string
    jerseyNumber?: number
    image?: string
  }
  isInvited?: boolean
  invitedFormats?: Set<"5v5" | "7v7">
}

function InvitePlayersPageContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [activeTab, setActiveTab] = useState<"players" | "free-agents">("players")
  const [searchQuery, setSearchQuery] = useState("")
  const [users, setUsers] = useState<UserWithProfile[]>([])
  const [invitedUsers, setInvitedUsers] = useState<Set<string>>(new Set())
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState("")
  const [teamId, setTeamId] = useState<string | null>(null)
  const [invitingUserId, setInvitingUserId] = useState<string | null>(null)
  const [pendingInvitesByFormat, setPendingInvitesByFormat] = useState<Map<string, Set<"5v5" | "7v7">>>(new Map())
  
  // Get format from URL query parameter, default to "5v5"
  const selectedFormat = (searchParams.get("format") as "5v5" | "7v7") || "5v5"

  // Fetch users and team data
  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view players")
          setIsLoading(false)
          return
        }

        const userData = JSON.parse(localStorage.getItem("user") || "{}")
        const captainId = userData.id

        if (!captainId) {
          setError("User ID not found")
          setIsLoading(false)
          return
        }

        // Fetch team to get team ID and existing players
        const teamResponse = await fetch(`/api/team?captainId=${captainId}`, {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        let existingPlayerIds = new Set<string>()
        let pendingInviteIds = new Set<string>()
        let invitesMapForUsers = new Map<string, Set<"5v5" | "7v7">>()
        let teamDataForNotifications: any = null
        
        if (teamResponse.ok) {
          const teamData = await teamResponse.json()
          if (teamData.data) {
            teamDataForNotifications = teamData.data
            setTeamId(teamData.data._id)
            // Mark existing players as invited (check both squads)
            const squad5v5Ids = (teamData.data.squad5v5 || []).map((p: any) => p._id?.toString() || p.toString())
            const squad7v7Ids = (teamData.data.squad7v7 || []).map((p: any) => p._id?.toString() || p.toString())
            existingPlayerIds = new Set([...squad5v5Ids, ...squad7v7Ids])
            setInvitedUsers(existingPlayerIds)
            
            // Fetch pending notifications for this team to mark as invited
            try {
              const notificationsResponse = await fetch("/api/notification/all", {
                headers: {
                  "Authorization": `Bearer ${token}`,
                },
              })
              if (notificationsResponse.ok) {
                const notificationsData = await notificationsResponse.json()
                const notifications = notificationsData.data || []
                // Get all player IDs that have pending invites for this team, grouped by format
                notifications
                  .filter((n: any) => {
                    const teamId = n.team._id?.toString() || n.team.toString()
                    return teamId === teamData.data._id && n.status === "pending"
                  })
                  .forEach((n: any) => {
                    const playerId = n.receiver._id?.toString() || n.receiver.toString()
                    const format = n.format || "5v5" // Default to 5v5 if format not present
                    if (!invitesMapForUsers.has(playerId)) {
                      invitesMapForUsers.set(playerId, new Set())
                    }
                    invitesMapForUsers.get(playerId)!.add(format as "5v5" | "7v7")
                  })
                
                setPendingInvitesByFormat(invitesMapForUsers)
                pendingInviteIds = new Set(invitesMapForUsers.keys())
                
                // Combine with existing players
                const allInvited = new Set([...existingPlayerIds, ...pendingInviteIds])
                setInvitedUsers(allInvited)
              }
            } catch (err) {
              console.error("Error fetching notifications:", err)
            }
          }
        }

        // Determine role to fetch based on active tab
        const roleToFetch = activeTab === "players" ? "player" : "free-agent"

        // Fetch users by role
        const usersResponse = await fetch(`/api/user?role=${roleToFetch}`, {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!usersResponse.ok) {
          const errorData = await usersResponse.json().catch(() => ({ error: "Unknown error" }))
          console.error("Failed to fetch users:", errorData)
          throw new Error(errorData.error || "Failed to fetch users")
        }

        const usersData = await usersResponse.json()
        const allUsers = usersData.data || []

        // Fetch all profiles to get profile data
        const profilesResponse = await fetch("/api/profile", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        const profilesData = profilesResponse.ok ? await profilesResponse.json() : { data: [] }
        const profiles = profilesData.data || []

        // Create a map of userId to profile
        const profileMap = new Map()
        profiles.forEach((profile: any) => {
          if (profile.userId) {
            profileMap.set(profile.userId.toString(), profile)
          }
        })

        // Combine users with their profiles
        const usersWithProfiles: UserWithProfile[] = []
        const allInvitedIds = new Set([...existingPlayerIds, ...pendingInviteIds])

        for (const user of allUsers) {
          // Skip captain
          if (user.role === "captain") {
            continue
          }

          const userIdStr = user._id.toString()
          
          // Check if user is already in squad or has pending invite
          const isInSquad = existingPlayerIds.has(userIdStr)
          const hasPendingInvite = pendingInviteIds.has(userIdStr)
          
          // Skip if already in squad or has pending invite (for any format)
          if (isInSquad || hasPendingInvite) {
            continue
          }

          const profile = profileMap.get(userIdStr)
          const invitedFormats = invitesMapForUsers.get(userIdStr) || new Set<"5v5" | "7v7">()
          
          usersWithProfiles.push({
            _id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            profile: profile
              ? {
                  position: profile.position,
                  jerseyNumber: profile.jerseyNumber,
                  image: profile.image,
                }
              : undefined,
            isInvited: false, // Not invited yet (we filtered them out above)
            invitedFormats: invitedFormats,
          })
        }

        setUsers(usersWithProfiles)
        setIsLoading(false)
      } catch (err: any) {
        console.error("Error fetching data:", err)
        setError(err.message || "An error occurred while fetching data")
        setIsLoading(false)
      }
    }

    fetchData()
  }, [activeTab])

  // Handle invite button click
  const handleInvite = async (userId: string) => {
    if (!teamId) {
      alert("Team not found")
      return
    }

    try {
      const token = localStorage.getItem("token")
      if (!token) {
        alert("Please login")
        return
      }

      setInvitingUserId(userId)

      // Send invite notification
      const response = await fetch("/api/team/invite-player", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify({ 
          playerId: userId,
          teamId: teamId,
          format: selectedFormat
        }),
      })

      const data = await response.json()

      if (response.ok) {
        // Mark as invited for this format
        setInvitedUsers((prev) => new Set([...prev, userId]))
        
        // Update pending invites map
        setPendingInvitesByFormat((prev) => {
          const newMap = new Map(prev)
          if (!newMap.has(userId)) {
            newMap.set(userId, new Set())
          }
          newMap.get(userId)!.add(selectedFormat)
          return newMap
        })
        
        // Update user's invited status and format
        setUsers((prevUsers) =>
          prevUsers.map((user) => {
            if (user._id === userId) {
              const newInvitedFormats = new Set(user.invitedFormats || [])
              newInvitedFormats.add(selectedFormat)
              return { 
                ...user, 
                isInvited: true,
                invitedFormats: newInvitedFormats
              }
            }
            return user
          })
        )
      } else {
        alert(data.error || "Failed to invite player")
      }
    } catch (err) {
      console.error("Error inviting player:", err)
      alert("An error occurred while inviting player")
    } finally {
      setInvitingUserId(null)
    }
  }

  // Filter users based on search query
  const filteredUsers = users.filter((user) => {
    const searchLower = searchQuery.toLowerCase()
    return (
      user.firstName.toLowerCase().includes(searchLower) ||
      user.lastName.toLowerCase().includes(searchLower) ||
      user.email.toLowerCase().includes(searchLower)
    )
  })

  return (
    <div className="flex flex-col gap-4" style={{ fontFamily: "Lato, sans-serif" }}>
      {/* Header */}
      <div className="flex items-center gap-4 mb-2">
        <button
          onClick={() => router.back()}
          className="w-[50px] h-[50px] p-[10px] rounded-full bg-[#F2F2F2] hover:bg-gray-200 transition-colors flex items-center justify-center flex-shrink-0"
        >
          <Image src="/assets/image/Back arrow.svg" alt="Back" width={24} height={24} />
        </button>
        <div>
          <h1 className="text-3xl font-bold text-foreground">Invite Players</h1>
          <p className="text-muted-foreground mt-1">
            Add or invite new players to complete your team roster.
          </p>
        </div>
      </div>

      {/* Format Display */}
      <div className="flex items-center gap-2 mb-2">
        <span className="text-sm font-medium text-gray-700">Inviting for:</span>
        <span className="px-4 py-2 rounded-lg text-sm font-medium bg-blue-100 text-blue-700">
          {selectedFormat}
        </span>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-2">
        <button
          onClick={() => setActiveTab("players")}
          className="px-6 py-3 rounded-lg text-sm font-medium transition-colors"
          style={{
            backgroundColor: activeTab === "players" ? "#3B82F6" : "#FFFFFF",
            color: activeTab === "players" ? "#FFFFFF" : "#000000",
            border: activeTab === "players" ? "none" : "1px solid rgba(0, 0, 0, 0.12)",
          }}
        >
          Players
        </button>
        <button
          onClick={() => setActiveTab("free-agents")}
          className="px-6 py-3 rounded-lg text-sm font-medium transition-colors"
          style={{
            backgroundColor: activeTab === "free-agents" ? "#3B82F6" : "#FFFFFF",
            color: activeTab === "free-agents" ? "#FFFFFF" : "#000000",
            border: activeTab === "free-agents" ? "none" : "1px solid rgba(0, 0, 0, 0.12)",
          }}
        >
          Free Agents
        </button>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
        <input
          type="text"
          placeholder="Search users by name..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full h-12 pl-10 pr-4 rounded-lg border border-[#E5E7EB] bg-white"
          style={{ fontFamily: "Lato, sans-serif" }}
        />
      </div>

      {/* User Cards */}
      {isLoading ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ color: "#6B7280" }}>Loading players...</p>
        </div>
      ) : error ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ color: "#EF4444" }}>{error}</p>
        </div>
      ) : filteredUsers.length === 0 ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ color: "#6B7280" }}>No players found</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filteredUsers.map((user) => (
            <div
              key={user._id}
              className="bg-white border-[0.67px] border-[#E5E7EB] rounded-[14px] py-4 px-4 w-full shadow-sm"
            >
              <div className="flex items-center gap-3">
                {/* Avatar */}
                <div className="w-12 h-12 rounded-full flex-shrink-0 overflow-hidden">
                  <img
                    src={user.profile?.image || "/placeholder-user.jpg"}
                    alt={`${user.firstName} ${user.lastName}`}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                </div>

                {/* User Info */}
                <div className="flex-1">
                  <h3 className="font-bold text-base text-[#101828]">
                    {user.profile?.jerseyNumber ? `#${user.profile.jerseyNumber} ` : ""}
                    {user.firstName} {user.lastName}
                  </h3>
                  <p className="font-medium text-sm text-[#6A7282] mt-1">{user.email}</p>
                  <p className="font-medium text-sm text-[#6A7282] mt-1">
                    Position: {user.profile?.position || "N/A"}
                  </p>
                </div>

                {/* Invite Button */}
                <button
                  onClick={() => handleInvite(user._id)}
                  disabled={(user.invitedFormats?.has(selectedFormat) || user.isInvited) || invitingUserId === user._id}
                  className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  style={{
                    backgroundColor: (user.invitedFormats?.has(selectedFormat) || user.isInvited) ? "#F3F4F6" : "#3B82F6",
                    color: (user.invitedFormats?.has(selectedFormat) || user.isInvited) ? "#6B7280" : "#FFFFFF",
                  }}
                >
                  <Mail className="w-4 h-4" />
                  <span>
                    {invitingUserId === user._id 
                      ? "Sending..." 
                      : (user.invitedFormats?.has(selectedFormat) || user.isInvited)
                        ? "Invited" 
                        : "Invite"}
                  </span>
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default function InvitePlayersPage() {
  return (
    <Suspense
      fallback={
        <div className="flex items-center justify-center py-8">
          <p style={{ color: "#6B7280" }}>Loading players...</p>
        </div>
      }
    >
      <InvitePlayersPageContent />
    </Suspense>
  )
}

