"use client"

import { useRouter } from "next/navigation"
import Image from "next/image"
import { ChevronRight } from "lucide-react"

interface GameCardProps {
  match: {
    _id: string
    leagueId: {
      _id: string
      leagueName: string
      logo?: string
    }
    teamA: {
      teamId: {
        _id: string
        teamName: string
        enterCode?: string
      }
    }
    teamB: {
      teamId: {
        _id: string
        teamName: string
        enterCode?: string
      }
    }
    gameDate: string
    gameTime: string
    venue?: string
    status: string
    refereeId?: {
      _id: string
    } | string | null
    statKeeperId?: {
      _id: string
    } | string | null
  }
  currentUserId?: string
  isAssigned?: boolean
}

export default function GameCard({ match, currentUserId, isAssigned = false }: GameCardProps) {
  const router = useRouter()

  // Format date and time
  const formatGameDateTime = () => {
    try {
      const date = new Date(match.gameDate)
      const day = date.getDate().toString().padStart(2, "0")
      const month = (date.getMonth() + 1).toString().padStart(2, "0")
      
      // Format time (assuming gameTime is in HH:mm format or similar)
      let timeStr = match.gameTime
      if (timeStr && !timeStr.includes("AM") && !timeStr.includes("PM")) {
        // Convert 24h to 12h format if needed
        const [hours, minutes] = timeStr.split(":")
        if (hours && minutes) {
          const hour24 = parseInt(hours)
          const hour12 = hour24 > 12 ? hour24 - 12 : hour24 === 0 ? 12 : hour24
          const ampm = hour24 >= 12 ? "PM" : "AM"
          timeStr = `${hour12.toString().padStart(2, "0")}:${minutes} ${ampm}`
        }
      }
      
      return `${day}/${month} ${timeStr || ""} PKT`
    } catch (error) {
      return match.gameDate
    }
  }

  // Get team initials for logo
  const getTeamInitials = (teamName: string) => {
    const words = teamName.split(" ")
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase()
    }
    return teamName.substring(0, 2).toUpperCase()
  }

  // Safely extract league name
  const leagueName = typeof match.leagueId === "object" && match.leagueId 
    ? (match.leagueId.leagueName || "") 
    : ""

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

  return (
    <div
      onClick={() => router.push(`/pffl/games/${match._id}`)}
      className="bg-white border border-gray-200 rounded-xl p-4 cursor-pointer hover:shadow-md transition-shadow"
    >
      {/* League Name Row */}
      <div className="flex items-center justify-between mb-3">
        <span className="text-sm text-gray-600 font-medium" style={{ fontFamily: "Lato, sans-serif" }}>
          {leagueName}
        </span>
        <ChevronRight className="w-4 h-4 text-gray-400" />
      </div>

      {/* Teams Row */}
      <div className="flex items-center justify-between gap-4 mb-3">
        {/* Team A */}
        <div className="flex items-center gap-2 flex-shrink-0">
          <div className="w-12 h-12 rounded-lg bg-red-600 flex items-center justify-center flex-shrink-0">
            <span className="text-white font-bold text-xs">
              {getTeamInitials(teamAName)}
            </span>
          </div>
        </div>

        {/* Date and Time - Center */}
        <div className="flex-1 text-center min-w-0">
          <span className="text-sm text-gray-700 font-medium" style={{ fontFamily: "Lato, sans-serif" }}>
            {formatGameDateTime()}
          </span>
        </div>

        {/* Team B */}
        <div className="flex items-center gap-2 flex-shrink-0">
          <div className="w-12 h-12 rounded-lg bg-yellow-400 flex items-center justify-center flex-shrink-0">
            <span className="text-gray-900 font-bold text-xs">
              {getTeamInitials(teamBName)}
            </span>
          </div>
        </div>
      </div>

      {/* Assigned Game Label */}
      {isAssigned && (
        <div className="mt-2 pt-2 border-t border-gray-100">
          <span className="text-xs text-gray-500" style={{ fontFamily: "Lato, sans-serif" }}>
            Your Assigned Game
          </span>
        </div>
      )}
    </div>
  )
}

