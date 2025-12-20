"use client"

import { useEffect, useState } from "react"
import { Plus, X, Check } from "lucide-react"
import Image from "next/image"

interface Player {
  _id: string
  firstName: string
  lastName: string
  email: string
  profile?: {
    jerseyNumber?: string
    position?: string
    profilePicture?: string
  }
}

interface AttendanceTabProps {
  match: {
    _id: string
    teamA: {
      teamId: {
        _id: string
        teamName: string
      }
    }
    teamB: {
      teamId: {
        _id: string
        teamName: string
      }
    }
    leagueId: {
      format: "5v5" | "7v7"
    }
  }
  onConfirm: (teamId: string, attendance: Array<{ playerId: string; present: boolean }>) => void
}

export default function AttendanceTab({ match, onConfirm }: AttendanceTabProps) {
  const [selectedTeam, setSelectedTeam] = useState<"A" | "B" | null>(null)
  const [players, setPlayers] = useState<Player[]>([])
  const [attendance, setAttendance] = useState<Map<string, boolean>>(new Map())
  const [isLoading, setIsLoading] = useState(false)

  // Get team initials for logo
  const getTeamInitials = (teamName: string) => {
    const words = teamName.split(" ")
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase()
    }
    return teamName.substring(0, 2).toUpperCase()
  }

  // Fetch team players when team is selected
  useEffect(() => {
    const fetchTeamPlayers = async () => {
      if (!selectedTeam) {
        setPlayers([])
        setAttendance(new Map())
        return
      }

      try {
        setIsLoading(true)
        const token = localStorage.getItem("token")
        if (!token) return

        const teamId = selectedTeam === "A" 
          ? (typeof match.teamA.teamId === "object" ? match.teamA.teamId._id : match.teamA.teamId)
          : (typeof match.teamB.teamId === "object" ? match.teamB.teamId._id : match.teamB.teamId)

        // Fetch team details
        const teamResponse = await fetch(`/api/team/${teamId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        if (!teamResponse.ok) {
          throw new Error("Failed to fetch team")
        }

        const teamData = await teamResponse.json()
        const team = teamData.data

        // Get squad based on league format
        const format = typeof match.leagueId === "object" ? match.leagueId.format : "5v5"
        const squadField = format === "5v5" ? "squad5v5" : "squad7v7"
        
        // Get squad players - API already populates them with user data
        const squadPlayers = (team as any)[squadField] || []
        
        // Get captain (already populated by API)
        const captain = team.captain || null
        const captainId = captain?._id?.toString() || captain?.toString() || ""

        // Build list of all players from the selected squad
        const allPlayers: any[] = []
        
        // Add squad players first (these are the players for the match format)
        if (Array.isArray(squadPlayers) && squadPlayers.length > 0) {
          squadPlayers.forEach((player: any) => {
            // Handle both populated objects and IDs
            if (player && typeof player === "object" && player._id) {
              // Already populated
              allPlayers.push({
                _id: player._id?.toString() || player.toString(),
                firstName: player.firstName || "",
                lastName: player.lastName || "",
                email: player.email || "",
              })
            } else if (player) {
              // Just an ID, need to fetch user data
              allPlayers.push({
                _id: player.toString(),
                firstName: "",
                lastName: "",
                email: "",
              })
            }
          })
        }
        
        // Add captain if not already in the squad
        if (captain) {
          const captainIdStr = captain._id?.toString() || captain.toString()
          const captainInSquad = allPlayers.some(p => p._id === captainIdStr)
          
          if (!captainInSquad) {
            allPlayers.push({
              _id: captainIdStr,
              firstName: captain.firstName || "",
              lastName: captain.lastName || "",
              email: captain.email || "",
            })
          }
        }

        // If we have players without user data, fetch user data first
        const playersNeedingUserData = allPlayers.filter(p => !p.firstName && !p.lastName)
        if (playersNeedingUserData.length > 0) {
          for (const player of playersNeedingUserData) {
            try {
              const userResponse = await fetch(`/api/user/${player._id}`, {
                headers: {
                  Authorization: `Bearer ${token}`,
                },
              })
              
              if (userResponse.ok) {
                const userData = await userResponse.json()
                const user = userData.data || {}
                player.firstName = user.firstName || ""
                player.lastName = user.lastName || ""
                player.email = user.email || ""
              }
            } catch (err) {
              console.error(`Error fetching user for ${player._id}:`, err)
            }
          }
        }

        // Fetch profiles for all players to get jersey number and position
        const playersWithProfiles: Player[] = []
        for (const player of allPlayers) {
          // Skip if no user data
          if (!player.firstName && !player.lastName) {
            continue
          }

          try {
            const profileResponse = await fetch(`/api/profile/${player._id}`, {
              headers: {
                Authorization: `Bearer ${token}`,
              },
            })

            if (profileResponse.ok) {
              const profileData = await profileResponse.json()
              // Profile API returns data directly
              const profile = profileData.data || {}
              
              playersWithProfiles.push({
                _id: player._id,
                firstName: player.firstName,
                lastName: player.lastName,
                email: player.email,
                profile: {
                  jerseyNumber: profile.jerseyNumber?.toString() || "",
                  position: profile.position || "",
                  profilePicture: profile.image || "/placeholder-user.jpg",
                },
              })
            } else {
              // If profile fetch fails, still add player without profile data
              playersWithProfiles.push({
                _id: player._id,
                firstName: player.firstName,
                lastName: player.lastName,
                email: player.email,
                profile: {},
              })
            }
          } catch (err) {
            console.error(`Error fetching profile for ${player._id}:`, err)
            // Still add player even if profile fetch fails
            playersWithProfiles.push({
              _id: player._id,
              firstName: player.firstName,
              lastName: player.lastName,
              email: player.email,
              profile: {},
            })
          }
        }

        setPlayers(playersWithProfiles)
        
        // Initialize attendance map (default to present)
        const initialAttendance = new Map<string, boolean>()
        playersWithProfiles.forEach(player => {
          initialAttendance.set(player._id, true)
        })
        setAttendance(initialAttendance)
      } catch (err) {
        console.error("Error fetching team players:", err)
      } finally {
        setIsLoading(false)
      }
    }

    fetchTeamPlayers()
  }, [selectedTeam, match])

  const handleAttendanceToggle = (playerId: string, present: boolean) => {
    setAttendance(prev => {
      const newMap = new Map(prev)
      newMap.set(playerId, present)
      return newMap
    })
  }

  const handleConfirm = () => {
    if (!selectedTeam) return

    const teamId = selectedTeam === "A" 
      ? (typeof match.teamA.teamId === "object" ? match.teamA.teamId._id : match.teamA.teamId)
      : (typeof match.teamB.teamId === "object" ? match.teamB.teamId._id : match.teamB.teamId)

    // Convert attendance Map to array format: [{ playerId, present: true/false }]
    const attendanceArray = Array.from(attendance.entries()).map(([playerId, present]) => ({
      playerId,
      present: present === true, // Ensure boolean value
    }))

    console.log("Attendance data being sent:", attendanceArray)
    onConfirm(teamId, attendanceArray)
  }

  const teamAName = typeof match.teamA.teamId === "object" ? match.teamA.teamId.teamName : ""
  const teamBName = typeof match.teamB.teamId === "object" ? match.teamB.teamId.teamName : ""

  return (
    <div className="flex flex-col h-full">
      {/* Select Team Section */}
      <div className="bg-white rounded-xl p-4 mb-4">
        <h3 className="text-sm font-medium text-gray-900 mb-3" style={{ fontFamily: "Lato, sans-serif" }}>
          Select Team
        </h3>
        <div className="flex gap-3">
          <button
            onClick={() => setSelectedTeam("A")}
            className={`flex-1 flex items-center gap-3 px-4 py-3 rounded-lg border-2 transition-colors ${
              selectedTeam === "A"
                ? "border-blue-600 bg-blue-50"
                : "border-gray-200 bg-white hover:bg-gray-50"
            }`}
          >
            <div className="w-12 h-12 rounded-lg bg-red-600 flex items-center justify-center flex-shrink-0">
              <span className="text-white font-bold text-sm">
                {getTeamInitials(teamAName)}
              </span>
            </div>
            <span
              className={`text-sm font-medium ${
                selectedTeam === "A" ? "text-blue-600" : "text-gray-700"
              }`}
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              {teamAName}
            </span>
          </button>

          <button
            onClick={() => setSelectedTeam("B")}
            className={`flex-1 flex items-center gap-3 px-4 py-3 rounded-lg border-2 transition-colors ${
              selectedTeam === "B"
                ? "border-blue-600 bg-blue-50"
                : "border-gray-200 bg-white hover:bg-gray-50"
            }`}
          >
            <div className="w-12 h-12 rounded-lg bg-yellow-400 flex items-center justify-center flex-shrink-0">
              <span className="text-gray-900 font-bold text-sm">
                {getTeamInitials(teamBName)}
              </span>
            </div>
            <span
              className={`text-sm font-medium ${
                selectedTeam === "B" ? "text-blue-600" : "text-gray-700"
              }`}
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              {teamBName}
            </span>
          </button>
        </div>
      </div>

      {/* Attendance Section */}
      {selectedTeam && (
        <div className="flex-1 flex flex-col bg-white rounded-xl p-4 overflow-hidden">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
              Attendance
            </h3>
            <button
              className="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center hover:bg-blue-700 transition-colors"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {/* Players List */}
          <div className="flex-1 overflow-y-auto space-y-3 mb-4">
            {isLoading ? (
              <div className="text-center py-8 text-gray-500">Loading players...</div>
            ) : players.length === 0 ? (
              <div className="text-center py-8 text-gray-500">No players found</div>
            ) : (
              players.map((player) => {
                const isPresent = attendance.get(player._id) ?? true
                const jerseyNumber = player.profile?.jerseyNumber || ""
                const position = player.profile?.position || "N/A"
                const profilePicture = player.profile?.profilePicture || "/placeholder-user.jpg"
                const fullName = `${player.firstName} ${player.lastName}`.trim()

                return (
                  <div
                    key={player._id}
                    className="flex items-center gap-4 p-4 bg-white border border-gray-200 rounded-lg"
                  >
                    {/* Profile Picture */}
                    <div className="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center flex-shrink-0 overflow-hidden">
                      <Image
                        src={profilePicture}
                        alt={fullName}
                        width={48}
                        height={48}
                        className="w-12 h-12 rounded-full object-cover"
                      />
                    </div>

                    {/* Player Info */}
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
                        {jerseyNumber ? `#${jerseyNumber} ${fullName}` : fullName}
                      </p>
                      <p className="text-xs text-gray-500" style={{ fontFamily: "Lato, sans-serif" }}>
                        Position: {position}
                      </p>
                    </div>

                    {/* Attendance Buttons */}
                    <div className="flex gap-2">
                      {/* Absent Button (X) */}
                      <button
                        onClick={() => handleAttendanceToggle(player._id, false)}
                        className={`w-10 h-10 rounded-lg flex items-center justify-center transition-colors ${
                          !isPresent
                            ? "bg-red-600 text-white"
                            : "bg-gray-100 text-gray-400 hover:bg-gray-200"
                        }`}
                      >
                        <X className="w-5 h-5" />
                      </button>

                      {/* Present Button (Checkmark) */}
                      <button
                        onClick={() => handleAttendanceToggle(player._id, true)}
                        className={`w-10 h-10 rounded-lg flex items-center justify-center transition-colors ${
                          isPresent
                            ? "bg-blue-600 text-white"
                            : "bg-gray-100 text-gray-400 hover:bg-gray-200"
                        }`}
                      >
                        <Check className="w-5 h-5" />
                      </button>
                    </div>
                  </div>
                )
              })
            )}
          </div>

          {/* Confirm Button */}
          <button
            onClick={handleConfirm}
            disabled={players.length === 0 || isLoading}
            className="w-full px-4 py-3 rounded-lg text-sm font-medium text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            style={{
              backgroundColor: "#0F173E",
              fontFamily: "Lato, sans-serif",
            }}
          >
            Confirm
          </button>
        </div>
      )}

      {!selectedTeam && (
        <div className="bg-white rounded-xl p-8 text-center text-gray-500">
          Please select a team to mark attendance
        </div>
      )}
    </div>
  )
}

