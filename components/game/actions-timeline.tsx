"use client"

import { useEffect, useState } from "react"
import { Shield, AlertTriangle, Goal, Target, Flag, Circle } from "lucide-react"

interface Player {
  _id: string
  firstName?: string
  lastName?: string
  email?: string
}

interface PlayerAction {
  _id?: string
  playerId: string | Player
  actionType: string
  timestamp: string | Date
}

interface ActionsTimelineProps {
  teamA: {
    teamId: { _id: string; teamName: string }
    playerActions?: PlayerAction[]
  }
  teamB: {
    teamId: { _id: string; teamName: string }
    playerActions?: PlayerAction[]
  }
}

interface ActionItem {
  playerId: string
  playerName: string
  jerseyNumber: string
  position: string
  actionType: string
  timestamp: Date
  team: "A" | "B"
}

// Get action icon based on action type
function getActionIcon(actionType: string) {
  switch (actionType) {
    case "Touchdown":
      return <Goal className="w-5 h-5" />
    case "Defensive Touchdown":
      return <Shield className="w-5 h-5" />
    case "Extra Point from 5-yard line":
    case "Extra Point from 12-yard line":
    case "Extra Point from 20-yard line":
      return <Target className="w-5 h-5" />
    case "Extra Point Return only":
      return <Flag className="w-5 h-5" />
    case "Safety":
      return <AlertTriangle className="w-5 h-5" />
    default:
      return <Shield className="w-5 h-5" />
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

export default function ActionsTimeline({ teamA, teamB }: ActionsTimelineProps) {
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

        const allActions: ActionItem[] = []

        // Process teamA actions
        if (teamA.playerActions && Array.isArray(teamA.playerActions)) {
          for (const action of teamA.playerActions) {
            const playerId = typeof action.playerId === "object" 
              ? action.playerId._id 
              : action.playerId

            // Fetch player data
            try {
              const userRes = await fetch(`/api/user/${playerId}`, {
                headers: { Authorization: `Bearer ${token}` },
              })
              const userData = await userRes.json()
              const user = userData.data || {}

              // Fetch profile for jersey number and position
              let jerseyNumber = ""
              let position = ""
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

              allActions.push({
                playerId,
                playerName: `${user.firstName || ""} ${user.lastName || ""}`.trim(),
                jerseyNumber,
                position,
                actionType: action.actionType,
                timestamp: new Date(action.timestamp),
                team: "A"
              })
            } catch (err) {
              console.error("Error fetching player data:", err)
            }
          }
        }

        // Process teamB actions
        if (teamB.playerActions && Array.isArray(teamB.playerActions)) {
          for (const action of teamB.playerActions) {
            const playerId = typeof action.playerId === "object" 
              ? action.playerId._id 
              : action.playerId

            // Fetch player data
            try {
              const userRes = await fetch(`/api/user/${playerId}`, {
                headers: { Authorization: `Bearer ${token}` },
              })
              const userData = await userRes.json()
              const user = userData.data || {}

              // Fetch profile for jersey number and position
              let jerseyNumber = ""
              let position = ""
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

              allActions.push({
                playerId,
                playerName: `${user.firstName || ""} ${user.lastName || ""}`.trim(),
                jerseyNumber,
                position,
                actionType: action.actionType,
                timestamp: new Date(action.timestamp),
                team: "B"
              })
            } catch (err) {
              console.error("Error fetching player data:", err)
            }
          }
        }

        // Sort by timestamp (oldest first, so newest appears at bottom)
        allActions.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime())

        setActions(allActions)
      } catch (err) {
        console.error("Error fetching actions:", err)
      } finally {
        setLoading(false)
      }
    }

    fetchActions()
  }, [teamA.playerActions, teamB.playerActions])

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
    <div className="relative min-h-[400px] pb-8">
      {/* Vertical timeline line */}
      <div className="absolute left-1/2 top-0 bottom-0 w-0.5 bg-gray-200 transform -translate-x-1/2" />

      {/* Actions container - flex-col-reverse to show newest at bottom */}
      <div className="flex flex-col-reverse gap-6">
        {actions.map((action, index) => {
          const isLeft = action.team === "A"
          const Icon = getActionIcon(action.actionType)
          const iconColor = getActionIconColor(action.actionType)

          return (
            <div
              key={`${action.playerId}-${action.timestamp.getTime()}-${index}`}
              className={`flex items-center gap-4 ${isLeft ? "flex-row" : "flex-row-reverse"}`}
            >
              {/* Player info */}
              <div className={`flex-1 ${isLeft ? "text-right pr-4" : "text-left pl-4"}`}>
                <p className="text-sm font-medium text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
                  {action.jerseyNumber ? `#${action.jerseyNumber} - ${action.playerName}` : action.playerName}
                </p>
                <p className="text-xs text-gray-500" style={{ fontFamily: "Lato, sans-serif" }}>
                  {action.position || "Player"}
                </p>
              </div>

              {/* Action icon */}
              <div className={`relative z-10 w-10 h-10 rounded-full ${iconColor} flex items-center justify-center text-white shadow-md`}>
                {Icon}
              </div>

              {/* Spacer for right side */}
              <div className={`flex-1 ${isLeft ? "" : "pr-4"}`} />
            </div>
          )
        })}
      </div>
    </div>
  )
}

