"use client"

import { useState, useEffect } from "react"
import { X, ChevronDown } from "lucide-react"

interface Team {
  _id: string
  teamName: string
  enterCode?: string
}

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

interface Match {
  teamA: {
    teamId: Team
    initialSide: "offense" | "defense"
    activePlayers?: Array<string | { _id: string; firstName?: string; lastName?: string; email?: string }>
    attendance?: Array<{
      playerId: string | { _id: string }
      present: boolean
    }>
  }
  teamB: {
    teamId: Team
    initialSide: "offense" | "defense"
    activePlayers?: Array<string | { _id: string; firstName?: string; lastName?: string; email?: string }>
    attendance?: Array<{
      playerId: string | { _id: string }
      present: boolean
    }>
  }
}

interface AddGameActionModalProps {
  isOpen: boolean
  onClose: () => void
  match: Match
  onAddAction: (teamId: string, actionType: string, playerId: string) => void
}

const OFFENSIVE_ACTION_TYPES = [
  "Touchdown (TD)",
  "Extra Point from 5-yard line",
  "Extra Point from 12-yard line",
  "Extra Point from 20-yard line",
]

const DEFENSIVE_ACTION_TYPES = [
  "Defensive Touchdown",
  "Extra Point Return only",
  "Safety",
]

export default function AddGameActionModal({ isOpen, onClose, match, onAddAction }: AddGameActionModalProps) {
  const [selectedTeam, setSelectedTeam] = useState<"A" | "B" | null>(null)
  const [selectedActionType, setSelectedActionType] = useState<string | null>(null)
  const [selectedPlayerId, setSelectedPlayerId] = useState<string | null>(null)
  const [isActionDropdownOpen, setIsActionDropdownOpen] = useState(false)
  const [players, setPlayers] = useState<Player[]>([])
  const [isLoadingPlayers, setIsLoadingPlayers] = useState(false)

  // Reset state when modal closes
  useEffect(() => {
    if (!isOpen) {
      setSelectedTeam(null)
      setSelectedActionType(null)
      setSelectedPlayerId(null)
      setIsActionDropdownOpen(false)
      setPlayers([])
    }
  }, [isOpen])

  // Fetch active players when team is selected
  useEffect(() => {
    const fetchActivePlayers = async () => {
      if (!selectedTeam || !isOpen) {
        setPlayers([])
        return
      }

      setIsLoadingPlayers(true)
      try {
        if (!match || !match.teamA || !match.teamB) {
          console.error("Match data is incomplete")
          setPlayers([])
          setIsLoadingPlayers(false)
          return
        }

        const team = selectedTeam === "A" ? match.teamA : match.teamB
        const activePlayerIds = team.activePlayers || []

        console.log("Fetching active players for team:", selectedTeam)
        console.log("Active players count:", activePlayerIds.length)
        console.log("Active players data:", activePlayerIds)

        if (activePlayerIds.length === 0) {
          console.warn(`No active players found for team ${selectedTeam}`)
          setPlayers([])
          setIsLoadingPlayers(false)
          return
        }

        // Fetch player profiles for each active player
        const token = localStorage.getItem("token")
        if (!token) {
          setIsLoadingPlayers(false)
          return
        }

        const playerPromises = activePlayerIds.map(async (playerIdOrObj) => {
          // Handle both string IDs and populated objects
          let playerId: string
          let firstName: string = ""
          let lastName: string = ""
          let email: string = ""

          if (typeof playerIdOrObj === "string") {
            playerId = playerIdOrObj
          } else if (playerIdOrObj && typeof playerIdOrObj === "object") {
            playerId = playerIdOrObj._id?.toString() || ""
            firstName = playerIdOrObj.firstName || ""
            lastName = playerIdOrObj.lastName || ""
            email = playerIdOrObj.email || ""
          } else {
            console.error("Invalid player data:", playerIdOrObj)
            return null
          }

          if (!playerId) {
            console.error("No player ID found:", playerIdOrObj)
            return null
          }

          try {
            // If we already have user data from populated object, use it
            if (firstName && lastName) {
              // Still fetch profile for jersey number and position
              let profile = {}
              try {
                const profileRes = await fetch(`/api/profile/${playerId}`, {
                  headers: { Authorization: `Bearer ${token}` },
                })

                if (profileRes.ok) {
                  const profileData = await profileRes.json()
                  profile = profileData.data || {}
                }
              } catch (profileErr) {
                console.error(`Error fetching profile for ${playerId}:`, profileErr)
              }

              return {
                _id: playerId,
                firstName,
                lastName,
                email,
                profile: {
                  jerseyNumber: profile?.jerseyNumber?.toString() || "",
                  position: profile?.position || "",
                  profilePicture: profile?.image || "",
                },
              }
            }

            // Otherwise fetch user data
            const userRes = await fetch(`/api/user/${playerId}`, {
              headers: { Authorization: `Bearer ${token}` },
            })

            if (!userRes.ok) {
              console.error(`Failed to fetch user ${playerId}:`, userRes.status)
              return null
            }

            const userData = await userRes.json()
            const user = userData.data || {}

            // Fetch profile data
            let profile = {}
            try {
              const profileRes = await fetch(`/api/profile/${playerId}`, {
                headers: { Authorization: `Bearer ${token}` },
              })

              if (profileRes.ok) {
                const profileData = await profileRes.json()
                profile = profileData.data || {}
              }
            } catch (profileErr) {
              console.error(`Error fetching profile for ${playerId}:`, profileErr)
            }

            return {
              _id: playerId,
              firstName: user.firstName || "",
              lastName: user.lastName || "",
              email: user.email || "",
              profile: {
                jerseyNumber: profile?.jerseyNumber?.toString() || "",
                position: profile?.position || "",
                profilePicture: profile?.image || "",
              },
            }
          } catch (err) {
            console.error(`Error fetching player ${playerId}:`, err)
            return null
          }
        })

        const fetchedPlayers = (await Promise.all(playerPromises)).filter((p): p is Player => p !== null)
        console.log("Fetched players count:", fetchedPlayers.length)
        console.log("Fetched players:", fetchedPlayers)
        setPlayers(fetchedPlayers)
      } catch (err) {
        console.error("Error fetching active players:", err)
        setPlayers([])
      } finally {
        setIsLoadingPlayers(false)
      }
    }

    if (isOpen && selectedTeam) {
      fetchActivePlayers()
    }
  }, [selectedTeam, isOpen, match])

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = () => {
      setIsActionDropdownOpen(false)
    }

    if (isActionDropdownOpen) {
      document.addEventListener("click", handleClickOutside)
      return () => {
        document.removeEventListener("click", handleClickOutside)
      }
    }
  }, [isActionDropdownOpen])

  if (!isOpen) return null

  // Get team initials for logo
  const getTeamInitials = (teamName: string) => {
    const words = teamName.split(" ")
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase()
    }
    return teamName.substring(0, 2).toUpperCase()
  }

  const getTeamEnterCode = (team: Team) => {
    return team.enterCode || team.teamName.substring(0, 3).toUpperCase()
  }

  const handleAddAction = () => {
    if (selectedTeam && selectedActionType && selectedPlayerId) {
      const team = selectedTeam === "A" ? match.teamA : match.teamB
      const teamId = team.teamId._id
      onAddAction(teamId, selectedActionType, selectedPlayerId)
      // Reset state
      setSelectedTeam(null)
      setSelectedActionType(null)
      setSelectedPlayerId(null)
      onClose()
    }
  }

  const teamA = match.teamA
  const teamB = match.teamB
  const teamASide = teamA.initialSide === "offense" ? "Offensive" : "Defensive"
  const teamBSide = teamB.initialSide === "offense" ? "Offensive" : "Defensive"

  return (
    <div
      className="fixed inset-0 flex items-center justify-center z-50"
      style={{ backgroundColor: "rgba(0, 0, 0, 0.2)" }}
      onClick={(e) => {
        if (e.target === e.currentTarget) {
          onClose()
        }
      }}
    >
      <div
        className="bg-white rounded-[24px] relative max-h-[90vh] overflow-y-auto"
        style={{
          width: "603px",
          padding: "20px 14px",
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex flex-col" style={{ width: "575px", gap: "20px" }}>
          {/* Header */}
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-bold text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Add Game Action
            </h2>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 rounded-full transition-colors"
            >
              <X className="w-5 h-5 text-gray-600" />
            </button>
          </div>

          {/* Select Team */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Select Team
            </label>
            <div className="flex gap-3">
              {/* Team A Button */}
              <button
                onClick={() => {
                  setSelectedTeam("A")
                  setSelectedPlayerId(null) // Reset player selection when team changes
                  setSelectedActionType(null) // Reset action type when team changes
                }}
                className={`flex-1 flex items-center gap-3 px-4 py-3 rounded-lg border-2 transition-colors ${
                  selectedTeam === "A"
                    ? "border-blue-600 bg-blue-50"
                    : "border-gray-200 bg-white hover:bg-gray-50"
                }`}
              >
                <div className="w-12 h-12 rounded-lg bg-red-600 flex items-center justify-center flex-shrink-0">
                  <span className="text-white font-bold text-sm">
                    {getTeamInitials(teamA.teamId.teamName)}
                  </span>
                </div>
                <span
                  className={`text-sm font-medium ${
                    selectedTeam === "A" ? "text-blue-600" : "text-gray-700"
                  }`}
                  style={{ fontFamily: "Lato, sans-serif" }}
                >
                  {getTeamEnterCode(teamA.teamId)} ({teamASide})
                </span>
              </button>

              {/* Team B Button */}
              <button
                onClick={() => {
                  setSelectedTeam("B")
                  setSelectedPlayerId(null) // Reset player selection when team changes
                  setSelectedActionType(null) // Reset action type when team changes
                }}
                className={`flex-1 flex items-center gap-3 px-4 py-3 rounded-lg border-2 transition-colors ${
                  selectedTeam === "B"
                    ? "border-blue-600 bg-blue-50"
                    : "border-gray-200 bg-white hover:bg-gray-50"
                }`}
              >
                <div className="w-12 h-12 rounded-lg bg-yellow-400 flex items-center justify-center flex-shrink-0">
                  <span className="text-gray-900 font-bold text-sm">
                    {getTeamInitials(teamB.teamId.teamName)}
                  </span>
                </div>
                <span
                  className={`text-sm font-medium ${
                    selectedTeam === "B" ? "text-blue-600" : "text-gray-700"
                  }`}
                  style={{ fontFamily: "Lato, sans-serif" }}
                >
                  {getTeamEnterCode(teamB.teamId)} ({teamBSide})
                </span>
              </button>
            </div>
          </div>

          {/* Action Type */}
          {selectedTeam && (
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
                Action Type
              </label>
              <div className="relative">
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation()
                    setIsActionDropdownOpen(!isActionDropdownOpen)
                  }}
                  className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left"
                  style={{ fontFamily: "Lato, sans-serif" }}
                >
                  <span>{selectedActionType || "Select Action Type"}</span>
                  <ChevronDown className={`w-4 h-4 transition-transform ${isActionDropdownOpen ? "rotate-180" : ""}`} />
                </button>
                {isActionDropdownOpen && (
                  <div
                    className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 overflow-y-auto max-h-60"
                    onClick={(e) => e.stopPropagation()}
                  >
                    {(() => {
                      const team = selectedTeam === "A" ? match.teamA : match.teamB
                      const actionTypes = team.initialSide === "offense" ? OFFENSIVE_ACTION_TYPES : DEFENSIVE_ACTION_TYPES
                      
                      return actionTypes.map((actionType) => (
                        <button
                          key={actionType}
                          type="button"
                          onClick={() => {
                            setSelectedActionType(actionType)
                            setIsActionDropdownOpen(false)
                          }}
                          className="w-full px-4 py-3 text-left text-sm transition-colors hover:bg-gray-100"
                          style={{
                            fontFamily: "Lato, sans-serif",
                            backgroundColor: selectedActionType === actionType ? "#0F173E" : "transparent",
                            color: selectedActionType === actionType ? "#FFFFFF" : "#000000",
                          }}
                        >
                          {actionType}
                        </button>
                      ))
                    })()}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Player List */}
          {selectedTeam && (
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
                Select Player
              </label>
              <div className="max-h-60 overflow-y-auto border border-gray-200 rounded-lg">
                {isLoadingPlayers ? (
                  <div className="p-4 text-center text-gray-500 text-sm">Loading players...</div>
                ) : players.length === 0 ? (
                  <div className="p-4 text-center text-gray-500 text-sm">No active players available</div>
                ) : (
                  <div className="divide-y divide-gray-200">
                    {players.map((player) => (
                      <button
                        key={player._id}
                        type="button"
                        onClick={() => setSelectedPlayerId(player._id)}
                        className="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50 transition-colors"
                      >
                        {/* Profile Picture */}
                        <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center flex-shrink-0 overflow-hidden">
                          {player.profile?.profilePicture ? (
                            <img
                              src={player.profile.profilePicture}
                              alt={`${player.firstName} ${player.lastName}`}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <span className="text-gray-600 text-xs font-medium">
                              {player.firstName?.[0]?.toUpperCase() || ""}
                              {player.lastName?.[0]?.toUpperCase() || ""}
                            </span>
                          )}
                        </div>

                        {/* Player Info */}
                        <div className="flex-1 text-left">
                          <div className="font-medium text-gray-900 text-sm" style={{ fontFamily: "Lato, sans-serif" }}>
                            #{player.profile?.jerseyNumber || "N/A"} {player.firstName} {player.lastName}
                          </div>
                          <div className="text-xs text-gray-500" style={{ fontFamily: "Lato, sans-serif" }}>
                            Position: {player.profile?.position || "N/A"}
                          </div>
                        </div>

                        {/* Radio Button */}
                        <div className="w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0"
                          style={{
                            borderColor: selectedPlayerId === player._id ? "#3B82F6" : "#D1D5DB",
                            backgroundColor: selectedPlayerId === player._id ? "#3B82F6" : "transparent",
                          }}
                        >
                          {selectedPlayerId === player._id && (
                            <div className="w-2.5 h-2.5 rounded-full bg-white" />
                          )}
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex gap-3 pt-4">
            <button
              onClick={onClose}
              className="flex-1 px-4 py-3 rounded-lg text-sm font-medium text-gray-700 bg-white border border-gray-200 hover:bg-gray-50 transition-colors"
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              Close
            </button>
            <button
              onClick={handleAddAction}
              disabled={!selectedTeam || !selectedActionType || !selectedPlayerId}
              className="flex-1 px-4 py-3 rounded-lg text-sm font-medium text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              style={{
                backgroundColor: "#0F173E",
                fontFamily: "Lato, sans-serif",
              }}
            >
              Add Action
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

