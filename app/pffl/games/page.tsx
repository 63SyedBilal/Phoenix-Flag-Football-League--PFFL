"use client"

import { useEffect, useState } from "react"
import { Calendar } from "lucide-react"
import GameCard from "@/components/cards/game-card"
import LoadingSpinner from "@/components/ui/loading-spinner"

interface Match {
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

export default function GamesPage() {
  const [matches, setMatches] = useState<Match[]>([])
  const [filteredMatches, setFilteredMatches] = useState<Match[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [selectedDate, setSelectedDate] = useState<string | null>(null)
  const [availableDates, setAvailableDates] = useState<string[]>([])
  const [currentUserId, setCurrentUserId] = useState<string | null>(null)
  const [userRole, setUserRole] = useState<string | null>(null)

  // Get current user ID and role on mount
  useEffect(() => {
    const storedUser = localStorage.getItem("user")
    if (storedUser) {
      try {
        const userData = JSON.parse(storedUser)
        setCurrentUserId(userData._id || userData.id)
        setUserRole(userData.role || null)
      } catch (e) {
        console.error("Error parsing user data:", e)
      }
    }
  }, [])

  useEffect(() => {
    const fetchMatches = async () => {
      // For statkeeper, we don't need to wait for user ID. For others, wait for user ID.
      if (userRole !== "stat-keeper" && !currentUserId) return

      try {
        setIsLoading(true)
        setError(null)

        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view games")
          setIsLoading(false)
          return
        }

        // Fetch all matches
        const response = await fetch("/api/match", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || "Failed to fetch matches")
        }

        const data = await response.json()
        const allMatches: Match[] = data.data || []

        // If user is stat-keeper, show all matches. Otherwise, filter by referee assignment
        let displayedMatches: Match[] = []
        if (userRole === "stat-keeper") {
          // Statkeeper sees all matches
          displayedMatches = allMatches
        } else {
          // Filter matches where current user is assigned as referee
          displayedMatches = allMatches.filter((match) => {
            const refereeId = typeof match.refereeId === "object" ? match.refereeId?._id : match.refereeId
            return refereeId === currentUserId
          })
        }

        setMatches(displayedMatches)

        // Extract unique dates from matches
        const dates = new Set<string>()
        displayedMatches.forEach((match) => {
          try {
            const date = new Date(match.gameDate)
            const dateStr = date.toISOString().split("T")[0] // YYYY-MM-DD format
            dates.add(dateStr)
          } catch (e) {
            console.error("Error parsing date:", e)
          }
        })

        const sortedDates = Array.from(dates).sort()
        setAvailableDates(sortedDates)

        // Set default selected date to first available date or today
        if (sortedDates.length > 0 && !selectedDate) {
          const today = new Date().toISOString().split("T")[0]
          const todayIndex = sortedDates.indexOf(today)
          if (todayIndex >= 0) {
            setSelectedDate(today)
          } else {
            setSelectedDate(sortedDates[0])
          }
        }
      } catch (err: any) {
        console.error("Error fetching matches:", err)
        setError(err.message || "Failed to load games")
      } finally {
        setIsLoading(false)
      }
    }

    fetchMatches()
  }, [currentUserId, userRole])

  useEffect(() => {
    if (selectedDate) {
      const filtered = matches.filter((match) => {
        try {
          const matchDate = new Date(match.gameDate).toISOString().split("T")[0]
          return matchDate === selectedDate
        } catch (e) {
          return false
        }
      })
      setFilteredMatches(filtered)
    } else {
      setFilteredMatches(matches)
    }
  }, [selectedDate, matches])

  // Format date for display
  const formatDateDisplay = (dateStr: string) => {
    try {
      const date = new Date(dateStr)
      return date.toLocaleDateString("en-US", { day: "numeric", month: "long" })
    } catch (e) {
      return dateStr
    }
  }

  // Check if match is assigned to current user (for non-statkeeper users)
  const isAssignedToUser = (match: Match) => {
    if (!currentUserId || userRole === "stat-keeper") return false
    const refereeId = typeof match.refereeId === "object" ? match.refereeId?._id : match.refereeId
    return refereeId === currentUserId
  }

  return (
    <div className="flex flex-col gap-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Games.</h1>
        <p className="text-muted-foreground mt-1">View all Games are listed below.</p>
      </div>

      {/* Loading State */}
      {isLoading && <LoadingSpinner fullScreen text="Loading games..." />}

      {/* Error State */}
      {error && !isLoading && <div className="text-center py-8 text-red-500">{error}</div>}

      {/* Date Selection Bar */}
      {!isLoading && !error && availableDates.length > 0 && (
        <div className="flex items-center gap-3 overflow-x-auto pb-2">
          {availableDates.slice(0, 3).map((dateStr) => (
            <button
              key={dateStr}
              onClick={() => setSelectedDate(dateStr)}
              className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors ${
                selectedDate === dateStr
                  ? "bg-blue-600 text-white"
                  : "bg-white text-gray-700 border border-gray-200 hover:bg-gray-50"
              }`}
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              {formatDateDisplay(dateStr)}
            </button>
          ))}
          {/* Calendar Icon */}
          <button
            className="ml-auto p-2 rounded-lg text-gray-600 hover:bg-gray-100"
            aria-label="Calendar"
          >
            <Calendar className="w-5 h-5" />
          </button>
        </div>
      )}

      {/* Games List */}
      {!isLoading && !error && (
        <div className="space-y-4">
          {filteredMatches.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              {selectedDate ? "No games scheduled for this date" : "No games found"}
            </div>
          ) : (
            filteredMatches.map((match) => (
              <GameCard
                key={match._id}
                match={match}
                currentUserId={currentUserId || undefined}
                isAssigned={isAssignedToUser(match)}
              />
            ))
          )}
        </div>
      )}
    </div>
  )
}

