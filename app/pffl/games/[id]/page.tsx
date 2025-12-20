"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { ArrowLeft, MoreVertical, Plus, Check, Clock, Coins, Timer } from "lucide-react"
import LoadingSpinner from "@/components/ui/loading-spinner"
import TossModal from "@/components/modals/toss-modal"
import AttendanceTab from "@/components/game/attendance-tab"
import SelectPlayersTab from "@/components/game/select-players-tab"
import AddGameActionModal from "@/components/modals/add-game-action-modal"
import ActionsTimeline from "@/components/game/actions-timeline"

interface Match {
  _id: string
  leagueId: {
    _id: string
    leagueName: string
    logo?: string
    format: "5v5" | "7v7"
  }
  teamA: {
    teamId: {
      _id: string
      teamName: string
      enterCode?: string
    }
    side: "offense" | "defense"
    score: number
    players?: Array<{
      playerId: string | { _id: string; firstName?: string; lastName?: string; email?: string }
      isActive: boolean
    }>
    playerActions?: Array<{
      _id?: string
      playerId: string | { _id: string; firstName?: string; lastName?: string; email?: string }
      actionType: string
      timestamp: string | Date
    }>
    playerStats?: Array<{
      playerId: string | { _id: string; firstName?: string; lastName?: string; email?: string }
      catches?: number
      catchYards?: number
      rushes?: number
      rushYards?: number
      touchdowns?: number
      extraPoints?: number
      defensiveTDs?: number
      safeties?: number
      flags?: number
      totalPoints?: number
    }>
    teamStats?: {
      catches?: number
      catchYards?: number
      rushes?: number
      rushYards?: number
      touchdowns?: number
      extraPoints?: number
      defensiveTDs?: number
      safeties?: number
      flags?: number
      totalPoints?: number
    }
  }
  teamB: {
    teamId: {
      _id: string
      teamName: string
      enterCode?: string
    }
    side: "offense" | "defense"
    score: number
    players?: Array<{
      playerId: string | { _id: string; firstName?: string; lastName?: string; email?: string }
      isActive: boolean
    }>
    playerActions?: Array<{
      _id?: string
      playerId: string | { _id: string; firstName?: string; lastName?: string; email?: string }
      actionType: string
      timestamp: string | Date
    }>
    playerStats?: Array<{
      playerId: string | { _id: string; firstName?: string; lastName?: string; email?: string }
      catches?: number
      catchYards?: number
      rushes?: number
      rushYards?: number
      touchdowns?: number
      extraPoints?: number
      defensiveTDs?: number
      safeties?: number
      flags?: number
      totalPoints?: number
    }>
    teamStats?: {
      catches?: number
      catchYards?: number
      rushes?: number
      rushYards?: number
      touchdowns?: number
      extraPoints?: number
      defensiveTDs?: number
      safeties?: number
      flags?: number
      totalPoints?: number
    }
  }
  gameDate: string
  gameTime: string
  venue?: string
  status: string
  timesSwitched?: string | null
  refereeId?: {
    _id: string
  } | string | null
  statKeeperId?: {
    _id: string
  } | string | null
}

export default function GameDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [match, setMatch] = useState<Match | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState<"actions" | "attendance" | "players">("actions")
  const [showMenu, setShowMenu] = useState(false)
  const [showStatusButtons, setShowStatusButtons] = useState(false)
  const [showAddActionModal, setShowAddActionModal] = useState(false)
  const [showTossModal, setShowTossModal] = useState(false)

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const target = event.target as HTMLElement
      if (!target.closest('.menu-container')) {
        setShowMenu(false)
      }
    }

    if (showMenu) {
      document.addEventListener('mousedown', handleClickOutside)
      return () => {
        document.removeEventListener('mousedown', handleClickOutside)
      }
    }
  }, [showMenu])

  useEffect(() => {
    const fetchMatch = async () => {
      try {
        setIsLoading(true)
        setError(null)

        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view game details")
          setIsLoading(false)
          return
        }

        const matchId = params.id as string
        if (!matchId) {
          setError("Match ID is required")
          setIsLoading(false)
          return
        }

        const response = await fetch(`/api/match/${matchId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || "Failed to fetch match")
        }

        const data = await response.json()
        setMatch(data.data)
      } catch (err: any) {
        console.error("Error fetching match:", err)
        setError(err.message || "Failed to load game")
      } finally {
        setIsLoading(false)
      }
    }

    if (params.id) {
      fetchMatch()
    }
  }, [params.id])

  // Get team initials for logo
  const getTeamInitials = (teamName: string) => {
    const words = teamName.split(" ")
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase()
    }
    return teamName.substring(0, 2).toUpperCase()
  }

  if (isLoading) {
    return <LoadingSpinner fullScreen text="Loading game details..." />
  }

  if (error || !match) {
    return (
      <div className="flex flex-col gap-3 p-6">
        <button
          onClick={() => router.back()}
          className="flex items-center gap-2 text-gray-600 hover:text-gray-800 w-fit"
        >
          <ArrowLeft className="w-4 h-4" />
          Back
        </button>
        <div className="text-center py-8 text-red-500">{error || "Game not found"}</div>
      </div>
    )
  }

  // Safely extract team names with fallback
  const getTeamName = (team: any, fallback: string): string => {
    if (!team || !team.teamId) return fallback
    if (typeof team.teamId === "object" && team.teamId.teamName) {
      return team.teamId.teamName
    }
    return fallback
  }

  const teamAName = getTeamName(match.teamA, "Team A")
  const teamBName = getTeamName(match.teamB, "Team B")
  const teamAScore = match.teamA?.score || 0
  const teamBScore = match.teamB?.score || 0

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Top Bar with Back and Menu */}
      <div className="bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
        <button
          onClick={() => router.back()}
          className="flex items-center gap-2 text-gray-700 hover:text-gray-900"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div className="relative menu-container">
          <button
            onClick={() => setShowMenu(!showMenu)}
            className="p-2 hover:bg-gray-100 rounded-full"
          >
            <MoreVertical className="w-5 h-5 text-gray-700" />
          </button>
          {showMenu && (
            <div className="absolute right-0 mt-2 w-48 bg-white border border-gray-200 rounded-lg shadow-lg z-10 overflow-hidden">
              <button
                onClick={() => {
                  setShowMenu(false)
                  // Handle forfeit game
                }}
                className="w-full text-left px-4 py-3 text-sm text-white hover:bg-blue-700 transition-colors"
                style={{ backgroundColor: "#0F173E" }}
              >
                Forfeit Game
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Score Section */}
      <div className="bg-white px-6 py-8">
        <div className="flex items-center justify-between">
          {/* Team A */}
          <div className="flex items-center gap-3 flex-1">
            <div className="w-16 h-16 rounded-lg bg-red-600 flex items-center justify-center flex-shrink-0">
              <span className="text-white font-bold text-lg">
                {getTeamInitials(teamAName)}
              </span>
            </div>
            <div>
              <p className="text-sm font-medium text-gray-700" style={{ fontFamily: "Lato, sans-serif" }}>
                {teamAName}
              </p>
            </div>
          </div>

          {/* Score */}
          <div className="flex-1 text-center">
            <span className="text-5xl font-bold text-gray-600" style={{ fontFamily: "Lato, sans-serif" }}>
              {teamAScore} | {teamBScore}
            </span>
          </div>

          {/* Team B */}
          <div className="flex items-center gap-3 flex-1 justify-end">
            <div>
              <p className="text-sm font-medium text-gray-900 text-right" style={{ fontFamily: "Lato, sans-serif" }}>
                {teamBName}
              </p>
            </div>
            <div className="w-16 h-16 rounded-lg bg-yellow-400 flex items-center justify-center flex-shrink-0">
              <span className="text-gray-900 font-bold text-lg">
                {getTeamInitials(teamBName)}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Tab Buttons */}
      <div className="bg-white border-b border-gray-200 px-4 py-2">
        <div className="flex gap-2">
          <button
            onClick={() => setActiveTab("actions")}
            className={`flex-1 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${
              activeTab === "actions"
                ? "bg-blue-600 text-white"
                : "bg-white text-gray-700 border border-gray-200 hover:bg-gray-50"
            }`}
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Game actions
          </button>
          <button
            onClick={() => setActiveTab("attendance")}
            className={`flex-1 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${
              activeTab === "attendance"
                ? "bg-blue-600 text-white"
                : "bg-white text-gray-700 border border-gray-200 hover:bg-gray-50"
            }`}
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Mark Attendance
          </button>
          <button
            onClick={() => setActiveTab("players")}
            className={`flex-1 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${
              activeTab === "players"
                ? "bg-blue-600 text-white"
                : "bg-white text-gray-700 border border-gray-200 hover:bg-gray-50"
            }`}
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Select Players
          </button>
        </div>
      </div>

      {/* Content Area */}
      <div className={`flex-1 flex gap-4 p-4 overflow-auto relative ${activeTab === "attendance" ? "flex-col" : ""}`}>
        {/* Main Content */}
        <div className={activeTab === "attendance" ? "flex-1 w-full" : "flex-1"}>
          {activeTab === "actions" && match && (
            <div className="bg-white rounded-xl p-4">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
                  Actions
                </h3>
                <button
                  onClick={() => setShowAddActionModal(true)}
                  className="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center hover:bg-blue-700 transition-colors"
                >
                  <Plus className="w-4 h-4" />
                </button>
              </div>
              <div className="border-2 border-dashed border-blue-100 rounded-lg p-4">
                <ActionsTimeline teamA={match.teamA} teamB={match.teamB} />
              </div>
            </div>
          )}
          {activeTab === "attendance" && match && (
            <AttendanceTab
              match={match}
              onConfirm={async (teamId, attendanceArray) => {
                try {
                  const token = localStorage.getItem("token")
                  if (!token) {
                    alert("Please login to mark attendance")
                    return
                  }

                  // Determine which team (A or B)
                  const teamAId = match.teamA?.teamId 
                    ? (typeof match.teamA.teamId === "object" ? match.teamA.teamId._id : match.teamA.teamId)
                    : null
                  const teamBId = match.teamB?.teamId 
                    ? (typeof match.teamB.teamId === "object" ? match.teamB.teamId._id : match.teamB.teamId)
                    : null
                  const isTeamA = teamId === teamAId

                  // Update match with players (attendance)
                  // attendanceArray format: [{ playerId: string, present: boolean }]
                  // Convert to players array with isActive field
                  const requestBody = {
                    [isTeamA ? "teamA" : "teamB"]: {
                      players: attendanceArray.map(att => ({
                        playerId: att.playerId,
                        isActive: att.present === true, // present maps to isActive
                      })),
                    },
                  }
                  
                  console.log("Sending attendance update:", requestBody)
                  
                  const response = await fetch(`/api/match/${match._id}`, {
                    method: "PUT",
                    headers: {
                      "Content-Type": "application/json",
                      Authorization: `Bearer ${token}`,
                    },
                    body: JSON.stringify(requestBody),
                  })

                  if (!response.ok) {
                    const errorData = await response.json()
                    throw new Error(errorData.error || "Failed to mark attendance")
                  }

                  // Refresh match data
                  const data = await response.json()
                  setMatch(data.data)
                  alert("Attendance marked successfully!")
                } catch (err: any) {
                  console.error("Error marking attendance:", err)
                  alert(err.message || "Failed to mark attendance")
                }
              }}
            />
          )}
          {activeTab === "players" && match && (
            <SelectPlayersTab
              match={match}
              onConfirm={async (teamId, activePlayerIds) => {
                try {
                  const token = localStorage.getItem("token")
                  if (!token) {
                    alert("Please login to select players")
                    return
                  }

                  // Determine which team (A or B)
                  const teamAId = match.teamA?.teamId 
                    ? (typeof match.teamA.teamId === "object" ? match.teamA.teamId._id : match.teamA.teamId)
                    : null
                  const teamBId = match.teamB?.teamId 
                    ? (typeof match.teamB.teamId === "object" ? match.teamB.teamId._id : match.teamB.teamId)
                    : null
                  const isTeamA = teamId === teamAId

                  // Update match with active players
                  // activePlayerIds is an array of player ID strings
                  // Convert to players array with isActive field
                  const currentTeam = isTeamA ? match.teamA : match.teamB
                  const existingPlayers = currentTeam.players || []
                  
                  // Create a map of existing players
                  const playerMap = new Map()
                  existingPlayers.forEach((p: any) => {
                    const pid = typeof p.playerId === "object" ? p.playerId._id : p.playerId
                    playerMap.set(pid, p)
                  })
                  
                  // Update isActive for all players
                  const updatedPlayers = existingPlayers.map((p: any) => {
                    const pid = typeof p.playerId === "object" ? p.playerId._id : p.playerId
                    return {
                      playerId: pid,
                      isActive: activePlayerIds.includes(pid)
                    }
                  })
                  
                  // Add any new players that weren't in the existing list
                  activePlayerIds.forEach((pid: string) => {
                    if (!playerMap.has(pid)) {
                      updatedPlayers.push({
                        playerId: pid,
                        isActive: true
                      })
                    }
                  })
                  
                  const requestBody = {
                    [isTeamA ? "teamA" : "teamB"]: {
                      players: updatedPlayers,
                    },
                  }
                  
                  console.log("Sending active players update:", requestBody)
                  
                  const response = await fetch(`/api/match/${match._id}`, {
                    method: "PUT",
                    headers: {
                      "Content-Type": "application/json",
                      Authorization: `Bearer ${token}`,
                    },
                    body: JSON.stringify(requestBody),
                  })

                  if (!response.ok) {
                    const errorData = await response.json()
                    throw new Error(errorData.error || "Failed to select players")
                  }

                  // Refresh match data
                  const data = await response.json()
                  setMatch(data.data)
                  alert("Players selected successfully!")
                } catch (err: any) {
                  console.error("Error selecting players:", err)
                  alert(err.message || "Failed to select players")
                }
              }}
            />
          )}
        </div>

        {/* Right Side - Status Buttons (only for actions tab) */}
        {activeTab === "actions" && (
          <div className="flex flex-col gap-2 items-end">
            {showStatusButtons && (
              <>
                <button
                  className="px-4 py-3 rounded-lg text-sm font-medium text-white flex items-center gap-2 shadow-md hover:shadow-lg transition-shadow min-w-[140px]"
                  style={{ backgroundColor: "#0F173E" }}
                  onClick={async () => {
                    try {
                      const token = localStorage.getItem("token")
                      if (!token) {
                        alert("Please login to complete game")
                        return
                      }

                      const response = await fetch(`/api/match/${match._id}`, {
                        method: "PUT",
                        headers: {
                          "Content-Type": "application/json",
                          Authorization: `Bearer ${token}`,
                        },
                        body: JSON.stringify({
                          status: "completed"
                        }),
                      })

                      if (!response.ok) {
                        const errorData = await response.json()
                        throw new Error(errorData.error || "Failed to complete game")
                      }

                      const data = await response.json()
                      setMatch(data.data)
                      setShowStatusButtons(false)
                      alert("Game marked as completed!")
                    } catch (err: any) {
                      console.error("Error completing game:", err)
                      alert(err.message || "Failed to complete game")
                    }
                  }}
                >
                  <Check className="w-4 h-4" />
                  Game Complete
                </button>
                <button
                  className="px-4 py-3 rounded-lg text-sm font-medium text-white flex items-center gap-2 shadow-md hover:shadow-lg transition-shadow min-w-[140px]"
                  style={{ backgroundColor: "#F97316" }}
                  onClick={async () => {
                    try {
                      const token = localStorage.getItem("token")
                      if (!token) {
                        alert("Please login to switch overtime")
                        return
                      }

                      const response = await fetch(`/api/match/${match._id}/overtime`, {
                        method: "POST",
                        headers: {
                          "Content-Type": "application/json",
                          Authorization: `Bearer ${token}`,
                        },
                      })

                      if (!response.ok) {
                        const errorData = await response.json()
                        throw new Error(errorData.error || "Failed to switch overtime")
                      }

                      const data = await response.json()
                      setMatch(data.data)
                      setShowStatusButtons(false)
                      alert("Overtime switched successfully!")
                    } catch (err: any) {
                      console.error("Error switching overtime:", err)
                      alert(err.message || "Failed to switch overtime")
                    }
                  }}
                >
                  <div className="relative">
                    <Clock className="w-4 h-4" />
                    <Plus className="w-2.5 h-2.5 absolute -top-1 -right-1" />
                  </div>
                  Over Time
                </button>
                <button
                  className="px-4 py-3 rounded-lg text-sm font-medium text-white flex items-center gap-2 shadow-md hover:shadow-lg transition-shadow min-w-[140px]"
                  style={{ backgroundColor: "#8B5CF6" }}
                  onClick={async () => {
                    try {
                      const token = localStorage.getItem("token")
                      if (!token) {
                        alert("Please login to switch half time")
                        return
                      }

                      const response = await fetch(`/api/match/${match._id}/halftime`, {
                        method: "POST",
                        headers: {
                          "Content-Type": "application/json",
                          Authorization: `Bearer ${token}`,
                        },
                      })

                      if (!response.ok) {
                        const errorData = await response.json()
                        throw new Error(errorData.error || "Failed to switch half time")
                      }

                      const data = await response.json()
                      setMatch(data.data)
                      setShowStatusButtons(false)
                      alert("Half time switched successfully! Sides have been swapped.")
                    } catch (err: any) {
                      console.error("Error switching half time:", err)
                      alert(err.message || "Failed to switch half time")
                    }
                  }}
                >
                  <Timer className="w-4 h-4" />
                  Half Time
                </button>
                <button
                  className="px-4 py-3 rounded-lg text-sm font-medium text-white flex items-center gap-2 shadow-md hover:shadow-lg transition-shadow min-w-[140px]"
                  style={{ backgroundColor: "#0F173E" }}
                  onClick={async () => {
                    try {
                      const token = localStorage.getItem("token")
                      if (!token) {
                        alert("Please login to switch full time")
                        return
                      }

                      const response = await fetch(`/api/match/${match._id}/fulltime`, {
                        method: "POST",
                        headers: {
                          "Content-Type": "application/json",
                          Authorization: `Bearer ${token}`,
                        },
                      })

                      if (!response.ok) {
                        const errorData = await response.json()
                        throw new Error(errorData.error || "Failed to switch full time")
                      }

                      const data = await response.json()
                      setMatch(data.data)
                      setShowStatusButtons(false)
                      alert("Full time switched successfully! Sides have been swapped again.")
                    } catch (err: any) {
                      console.error("Error switching full time:", err)
                      alert(err.message || "Failed to switch full time")
                    }
                  }}
                >
                  <Check className="w-4 h-4" />
                  Full Time Done
                </button>
                <button
                  className="px-4 py-3 rounded-lg text-sm font-medium text-white flex items-center gap-2 shadow-md hover:shadow-lg transition-shadow min-w-[140px]"
                  style={{ backgroundColor: "#3B82F6" }}
                  onClick={() => {
                    // Handle Half Time Done
                  }}
                >
                  <Check className="w-4 h-4" />
                  Half Time Done
                </button>
                <button
                  className="px-4 py-3 rounded-lg text-sm font-medium text-white flex items-center gap-2 shadow-md hover:shadow-lg transition-shadow min-w-[140px]"
                  style={{ backgroundColor: "#0F173E" }}
                  onClick={() => {
                    setShowTossModal(true)
                    setShowStatusButtons(false)
                  }}
                >
                  <Coins className="w-4 h-4" />
                  Toss
                </button>
              </>
            )}
            <button
              onClick={() => setShowStatusButtons(!showStatusButtons)}
              className="w-10 h-10 rounded-full bg-blue-600 text-white flex items-center justify-center hover:bg-blue-700 transition-colors shadow-md"
            >
              <Plus className="w-5 h-5" />
            </button>
          </div>
        )}
      </div>

      {/* Add Game Action Modal */}
      {match && (
        <AddGameActionModal
          isOpen={showAddActionModal}
          onClose={() => setShowAddActionModal(false)}
          match={match}
          onAddAction={async (teamId, actionType, playerId) => {
            try {
              const token = localStorage.getItem("token")
              if (!token) {
                alert("Please login to add action")
                return
              }

              // Map UI action types to backend action types
              const actionTypeMap: { [key: string]: string } = {
                "Touchdown (TD)": "Touchdown",
                "Extra Point from 5-yard line": "Extra Point from 5-yard line",
                "Extra Point from 12-yard line": "Extra Point from 12-yard line",
                "Extra Point from 20-yard line": "Extra Point from 20-yard line",
                "Defensive Touchdown": "Defensive Touchdown",
                "Extra Point Return only": "Extra Point Return only",
                "Safety": "Safety"
              }

              const backendActionType = actionTypeMap[actionType] || actionType

              console.log("Adding action:", { teamId, actionType: backendActionType, playerId })
              
              // Call the action API endpoint
              const response = await fetch(`/api/match/${match._id}/action`, {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({
                  teamId,
                  playerId,
                  actionType: backendActionType,
                  quarter: "1" // TODO: Get current quarter from match state
                }),
              })

              if (!response.ok) {
                const errorData = await response.json()
                throw new Error(errorData.error || "Failed to add action")
              }

                const data = await response.json()
                setMatch(data.data)
                alert("Action added successfully!")
            } catch (err: any) {
              console.error("Error adding action:", err)
              alert(err.message || "Failed to add action")
            }
          }}
        />
      )}

      {/* Toss Modal */}
      {match && match.teamA?.teamId && match.teamB?.teamId && (
        <TossModal
          isOpen={showTossModal}
          onClose={() => setShowTossModal(false)}
          teamA={typeof match.teamA.teamId === "object" ? match.teamA.teamId : { _id: match.teamA.teamId, teamName: "Team A" }}
          teamB={typeof match.teamB.teamId === "object" ? match.teamB.teamId : { _id: match.teamB.teamId, teamName: "Team B" }}
          onStartMatch={async (tossWinner, decision) => {
            try {
              const token = localStorage.getItem("token")
              if (!token) {
                alert("Please login to start match")
                return
              }

              const teamAId = typeof match.teamA.teamId === "object" ? match.teamA.teamId._id : match.teamA.teamId
              const teamBId = typeof match.teamB.teamId === "object" ? match.teamB.teamId._id : match.teamB.teamId

              // Update match with toss winner and decision
              const response = await fetch(`/api/match/${match._id}`, {
                method: "PUT",
                headers: {
                  "Content-Type": "application/json",
                  Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({
                  gameWinnerTeam: tossWinner,
                  teamA: {
                    side: tossWinner === teamAId ? decision : (decision === "offense" ? "defense" : "offense")
                  },
                  teamB: {
                    side: tossWinner === teamBId ? decision : (decision === "offense" ? "defense" : "offense")
                  }
                }),
              })

              if (!response.ok) {
                const errorData = await response.json()
                throw new Error(errorData.error || "Failed to start match")
              }

              // Refresh match data
              const data = await response.json()
              setMatch(data.data)
              alert("Match started successfully!")
            } catch (err: any) {
              console.error("Error starting match:", err)
              alert(err.message || "Failed to start match")
            }
          }}
        />
      )}
    </div>
  )
}

