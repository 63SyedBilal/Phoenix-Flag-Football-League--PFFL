"use client"

import { useEffect, useState } from "react"
import { Goal, Shield, Target, Flag, AlertTriangle } from "lucide-react"
import { useRouter } from "next/navigation"

interface PlayerAction {
  _id?: string
  playerId: string | { _id: string; firstName?: string; lastName?: string; email?: string }
  actionType: string
  timestamp: string | Date
}

interface Match {
  _id: string
  teamA: {
    teamId: { _id: string; teamName: string }
    playerActions?: PlayerAction[]
  }
  teamB: {
    teamId: { _id: string; teamName: string }
    playerActions?: PlayerAction[]
  }
  gameDate: string
  gameTime: string
}

interface LeagueActionsListProps {
  leagueId: string
}

interface ActionItem {
  _id: string
  playerId: string
  playerName: string
  jerseyNumber: string
  position: string
  actionType: string
  timestamp: Date
  teamName: string
  matchId: string
  gameDate: string
  gameTime: string
}

// Get action icon
function getActionIcon(actionType: string) {
  switch (actionType) {
    case "Touchdown":
      return <Goal className="w-4 h-4" />
    case "Defensive Touchdown":
      return <Shield className="w-4 h-4" />
    case "Extra Point from 5-yard line":
    case "Extra Point from 12-yard line":
    case "Extra Point from 20-yard line":
      return <Target className="w-4 h-4" />
    case "Extra Point Return only":
      return <Flag className="w-4 h-4" />
    case "Safety":
      return <AlertTriangle className="w-4 h-4" />
    default:
      return <Shield className="w-4 h-4" />
  }
}

// Get action icon color
function getActionIconColor(actionType: string) {
  switch (actionType) {
    case "Touchdown":
    case "Defensive Touchdown":
      return "bg-blue-600"
    case "Extra Point from 5-yard line":
    case "Extra Point from 12-yard line":
    case "Extra Point from 20-yard line":
      return "bg-green-600"
    case "Extra Point Return only":
      return "bg-purple-600"
    case "Safety":
      return "bg-yellow-500"
    default:
      return "bg-gray-600"
  }
}

export default function LeagueActionsList({ leagueId }: LeagueActionsListProps) {
  const router = useRouter()
  const [actions, setActions] = useState<ActionItem[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchActions = async () => {
      try {
        setLoading(true)
        const token = localStorage.getItem("token")
        if (!token) {
          setLoading(false)
          return
        }

        // Fetch all matches for this league
        const matchesResponse = await fetch(`/api/match?leagueId=${leagueId}`, {
          headers: { Authorization: `Bearer ${token}` },
        })

        if (!matchesResponse.ok) {
          console.error("Failed to fetch matches")
          setLoading(false)
          return
        }

        const matchesData = await matchesResponse.json()
        const matches: Match[] = matchesData.data || []

        console.log("Fetched matches:", matches.length)
        console.log("First match sample:", matches[0])

        const allActions: ActionItem[] = []

        // Process all matches and their actions
        for (const match of matches) {
          // Process teamA actions
          if (match.teamA?.playerActions && Array.isArray(match.teamA.playerActions)) {
            console.log(`TeamA has ${match.teamA.playerActions.length} actions`)
            for (const action of match.teamA.playerActions) {
              if (!action || !action.playerId) {
                console.warn("Invalid action:", action)
                continue
              }

              // Check if playerId is already populated
              let playerId: string
              let playerName = ""
              let jerseyNumber = ""
              let position = ""

              if (typeof action.playerId === "object" && action.playerId._id) {
                // Already populated
                playerId = action.playerId._id
                playerName = `${action.playerId.firstName || ""} ${action.playerId.lastName || ""}`.trim()
              } else {
                // Need to fetch
                playerId = typeof action.playerId === "string" ? action.playerId : String(action.playerId)
              }

              // If we don't have player name, fetch it
              if (!playerName) {
                try {
                  const userRes = await fetch(`/api/user/${playerId}`, {
                    headers: { Authorization: `Bearer ${token}` },
                  })
                  if (userRes.ok) {
                    const userData = await userRes.json()
                    const user = userData.data || {}
                    playerName = `${user.firstName || ""} ${user.lastName || ""}`.trim()
                  }
                } catch (err) {
                  console.error("Error fetching user:", err)
                }
              }

              // Fetch profile for jersey number and position
              try {
                const profileRes = await fetch(`/api/profile/${playerId}`, {
                  headers: { Authorization: `Bearer ${token}` },
                })
                if (profileRes.ok) {
                  const profileData = await profileRes.json()
                  const profile = profileData.data || {}
                  jerseyNumber = profile.jerseyNumber?.toString() || ""
                  position = profile.position || ""
                }
              } catch (err) {
                console.error("Error fetching profile:", err)
              }

              if (action.actionType && playerId) {
                allActions.push({
                  _id: action._id || `${match._id}-${playerId}-${action.timestamp}`,
                  playerId,
                  playerName: playerName || "Unknown Player",
                  jerseyNumber,
                  position,
                  actionType: action.actionType,
                  timestamp: new Date(action.timestamp),
                  teamName: match.teamA.teamId?.teamName || "Team A",
                  matchId: match._id,
                  gameDate: match.gameDate,
                  gameTime: match.gameTime
                })
              }
            }
          }

          // Process teamB actions
          if (match.teamB?.playerActions && Array.isArray(match.teamB.playerActions)) {
            console.log(`TeamB has ${match.teamB.playerActions.length} actions`)
            for (const action of match.teamB.playerActions) {
              if (!action || !action.playerId) {
                console.warn("Invalid action:", action)
                continue
              }

              // Check if playerId is already populated
              let playerId: string
              let playerName = ""
              let jerseyNumber = ""
              let position = ""

              if (typeof action.playerId === "object" && action.playerId._id) {
                // Already populated
                playerId = action.playerId._id
                playerName = `${action.playerId.firstName || ""} ${action.playerId.lastName || ""}`.trim()
              } else {
                // Need to fetch
                playerId = typeof action.playerId === "string" ? action.playerId : String(action.playerId)
              }

              // If we don't have player name, fetch it
              if (!playerName) {
                try {
                  const userRes = await fetch(`/api/user/${playerId}`, {
                    headers: { Authorization: `Bearer ${token}` },
                  })
                  if (userRes.ok) {
                    const userData = await userRes.json()
                    const user = userData.data || {}
                    playerName = `${user.firstName || ""} ${user.lastName || ""}`.trim()
                  }
                } catch (err) {
                  console.error("Error fetching user:", err)
                }
              }

              // Fetch profile for jersey number and position
              try {
                const profileRes = await fetch(`/api/profile/${playerId}`, {
                  headers: { Authorization: `Bearer ${token}` },
                })
                if (profileRes.ok) {
                  const profileData = await profileRes.json()
                  const profile = profileData.data || {}
                  jerseyNumber = profile.jerseyNumber?.toString() || ""
                  position = profile.position || ""
                }
              } catch (err) {
                console.error("Error fetching profile:", err)
              }

              if (action.actionType && playerId) {
                allActions.push({
                  _id: action._id || `${match._id}-${playerId}-${action.timestamp}`,
                  playerId,
                  playerName: playerName || "Unknown Player",
                  jerseyNumber,
                  position,
                  actionType: action.actionType,
                  timestamp: new Date(action.timestamp),
                  teamName: match.teamB.teamId?.teamName || "Team B",
                  matchId: match._id,
                  gameDate: match.gameDate,
                  gameTime: match.gameTime
                })
              }
            }
          }
        }

        console.log("Total actions collected:", allActions.length)

        // Sort by timestamp (newest first)
        allActions.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())

        // Limit to 20 most recent actions
        setActions(allActions.slice(0, 20))
      } catch (err) {
        console.error("Error fetching actions:", err)
      } finally {
        setLoading(false)
      }
    }

    fetchActions()
  }, [leagueId])

  if (loading) {
    return (
      <div className="flex items-center justify-center py-8">
        <div className="text-gray-500">Loading actions...</div>
      </div>
    )
  }

  if (actions.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-4">
          <Shield className="w-8 h-8 text-gray-400" />
        </div>
        <p className="text-gray-500 text-sm">No actions recorded yet</p>
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {actions.map((action) => {
        if (!action || !action.actionType || !action.playerName) {
          return null
        }

        const Icon = getActionIcon(action.actionType)
        const iconColor = getActionIconColor(action.actionType)
        const formattedDate = new Date(action.timestamp).toLocaleString("en-US", {
          month: "short",
          day: "numeric",
          hour: "numeric",
          minute: "2-digit"
        })

        const displayName = action.jerseyNumber 
          ? `#${action.jerseyNumber} ${action.playerName}` 
          : action.playerName

        return (
          <div
            key={action._id}
            onClick={() => router.push(`/pffl/games/${action.matchId}`)}
            className="flex items-center gap-3 p-3 bg-white border border-gray-200 rounded-lg hover:shadow-md transition-shadow cursor-pointer"
          >
            {/* Action Icon */}
            <div className={`w-8 h-8 rounded-full ${iconColor} flex items-center justify-center text-white flex-shrink-0`}>
              {Icon}
            </div>

            {/* Player and Action Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                <p className="text-sm font-medium text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
                  {displayName}
                </p>
                {action.teamName && (
                  <>
                    <span className="text-xs text-gray-500">•</span>
                    <p className="text-xs text-gray-500" style={{ fontFamily: "Lato, sans-serif" }}>
                      {action.teamName}
                    </p>
                  </>
                )}
              </div>
              <p className="text-xs text-gray-600 mt-0.5" style={{ fontFamily: "Lato, sans-serif" }}>
                {action.actionType}
              </p>
            </div>

            {/* Timestamp */}
            <div className="text-xs text-gray-400 flex-shrink-0" style={{ fontFamily: "Lato, sans-serif" }}>
              {formattedDate}
            </div>
          </div>
        )
      })}
    </div>
  )
}

