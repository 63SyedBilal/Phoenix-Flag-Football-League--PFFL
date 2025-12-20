"use client"

import { useEffect, useState, useCallback } from "react"
import { useRouter } from "next/navigation"
import { Search, Filter, Bell, ArrowLeft, Plus, X } from "lucide-react"
import GameCard from "@/components/cards/game-card"
import LoadingSpinner from "@/components/ui/loading-spinner"

interface TeamStats {
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

interface PlayerStat {
  playerId: string | {
    _id: string
    firstName?: string
    lastName?: string
    email?: string
  }
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

interface MatchPlayer {
  playerId: string | {
    _id: string
    firstName?: string
    lastName?: string
    email?: string
    profileImage?: string
    position?: string
  }
  isActive: boolean
}

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
    score?: number
    teamStats?: TeamStats
    players?: MatchPlayer[]
    playerStats?: PlayerStat[]
    win?: boolean | null
  }
  teamB: {
    teamId: {
      _id: string
      teamName: string
      enterCode?: string
    }
    score?: number
    teamStats?: TeamStats
    players?: MatchPlayer[]
    playerStats?: PlayerStat[]
    win?: boolean | null
  }
  gameDate: string
  gameTime: string
  venue?: string
  status: "upcoming" | "continue" | "completed"
  refereeId?: {
    _id: string
  } | string | null
  statKeeperId?: {
    _id: string
  } | string | null
}

type TabType = "all" | "draft" | "approved"
type SelectedTeam = "teamA" | "teamB"
type StatsDetailTab = "team" | "players"

export default function StatsPage() {
  const router = useRouter()
  const [matches, setMatches] = useState<Match[]>([])
  const [filteredMatches, setFilteredMatches] = useState<Match[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState<TabType>("all")
  const [searchQuery, setSearchQuery] = useState("")
  const [userRole, setUserRole] = useState<string | null>(null)
  const [selectedMatch, setSelectedMatch] = useState<Match | null>(null)
  const [selectedTeam, setSelectedTeam] = useState<SelectedTeam>("teamA")
  const [showStatsDetail, setShowStatsDetail] = useState(false)
  const [statsDetailTab, setStatsDetailTab] = useState<StatsDetailTab>("team")
  const [showAddStatsModal, setShowAddStatsModal] = useState(false)

  // Get user role on mount
  useEffect(() => {
    const storedUser = localStorage.getItem("user")
    if (storedUser) {
      try {
        const userData = JSON.parse(storedUser)
        setUserRole(userData.role || null)
      } catch (e) {
        console.error("Error parsing user data:", e)
      }
    }
  }, [])

  // Fetch matches function - extracted to be reusable
  const fetchMatches = useCallback(async () => {
    // Only allow statkeeper to access this page
    if (userRole !== "stat-keeper") {
      // Wait for role to be loaded
      if (userRole === null) return
      
      router.push("/pffl/games")
      return
    }

    try {
      setIsLoading(true)
      setError(null)

      const token = localStorage.getItem("token")
      if (!token) {
        setError("Please login to view stats")
        setIsLoading(false)
        return
      }

      // Fetch all matches with full details
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
      setMatches(allMatches)
      
      // Update selectedMatch if it exists to reflect the latest data
      setSelectedMatch(prev => {
        if (prev) {
          const updatedMatch = allMatches.find(m => m._id === prev._id)
          return updatedMatch || prev
        }
        return prev
      })
    } catch (err: any) {
      console.error("Error fetching matches:", err)
      setError(err.message || "Failed to load stats")
    } finally {
      setIsLoading(false)
    }
  }, [userRole, router])

  useEffect(() => {
    fetchMatches()
  }, [fetchMatches])

  // Filter matches based on active tab and search query
  useEffect(() => {
    let filtered = [...matches]

    // Filter by tab
    if (activeTab === "draft") {
      // Draft Stats: matches that are not completed (upcoming or continue)
      filtered = filtered.filter((match) => 
        match.status === "upcoming" || match.status === "continue"
      )
    } else if (activeTab === "approved") {
      // Approved Stats: completed matches
      filtered = filtered.filter((match) => match.status === "completed")
    }
    // "all" tab shows all matches, so no filtering needed

    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter((match) => {
        const leagueName = typeof match.leagueId === "object" 
          ? (match.leagueId?.leagueName || "").toLowerCase()
          : ""
        
        const getTeamName = (team: any): string => {
          if (!team || !team.teamId) return ""
          if (typeof team.teamId === "object" && team.teamId.teamName) {
            return team.teamId.teamName.toLowerCase()
          }
          return ""
        }

        const teamAName = getTeamName(match.teamA)
        const teamBName = getTeamName(match.teamB)

        return (
          leagueName.includes(query) ||
          teamAName.includes(query) ||
          teamBName.includes(query)
        )
      })
    }

    setFilteredMatches(filtered)
  }, [matches, activeTab, searchQuery])

  // Get status badge color and text
  const getStatusBadge = (status: string) => {
    switch (status) {
      case "continue":
        return {
          text: "Continue",
          className: "bg-blue-600 text-white"
        }
      case "completed":
        return {
          text: "Completed",
          className: "bg-blue-400 text-white"
        }
      case "upcoming":
        return {
          text: "Upcoming",
          className: "bg-gray-400 text-white"
        }
      default:
        return {
          text: status,
          className: "bg-gray-400 text-white"
        }
    }
  }

  if (isLoading) {
    return <LoadingSpinner fullScreen text="Loading stats..." />
  }

  if (error) {
    return (
      <div className="flex flex-col gap-6 p-4">
        <div className="text-center py-8 text-red-500">{error}</div>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4 p-4 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-3xl font-bold text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
            Games Stats
          </h1>
          <p className="text-muted-foreground mt-1" style={{ fontFamily: "Lato, sans-serif" }}>
            View all Games Stats listed below.
          </p>
        </div>
        <button className="relative p-2 hover:bg-gray-100 rounded-full">
          <Bell className="w-6 h-6 text-gray-700" />
          <span className="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
        </button>
      </div>

      {/* Search and Filter */}
      <div className="flex items-center gap-2">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search by name here"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            style={{ fontFamily: "Lato, sans-serif" }}
          />
        </div>
        <button className="p-2 border border-gray-200 rounded-lg hover:bg-gray-50">
          <Filter className="w-5 h-5 text-gray-700" />
        </button>
      </div>

      {/* Show stats detail view if showStatsDetail is true, otherwise show match detail or list */}
      {showStatsDetail && selectedMatch ? (
        <StatsDetailView
          match={selectedMatch}
          selectedTeam={selectedTeam}
          activeTab={statsDetailTab}
          onTabChange={setStatsDetailTab}
          onBack={() => setShowStatsDetail(false)}
          onStatsAdded={() => {
            // Refresh match data after stats are added
            fetchMatches()
          }}
        />
      ) : selectedMatch ? (
        <>
          <MatchDetailView 
            match={selectedMatch} 
            selectedTeam={selectedTeam}
            onTeamSelect={setSelectedTeam}
            onBack={() => setSelectedMatch(null)}
            onSeeDetails={() => setShowStatsDetail(true)}
            onAddStats={() => setShowAddStatsModal(true)}
          />
          {/* Add Game Stats Modal for Match Detail View */}
          {showAddStatsModal && (
            <AddGameStatsModal
              match={selectedMatch}
              isOpen={showAddStatsModal}
              onClose={() => setShowAddStatsModal(false)}
              onSave={async () => {
                setShowAddStatsModal(false)
                fetchMatches()
              }}
            />
          )}
        </>
      ) : (
        <>
          {/* Tabs */}
          <div className="flex gap-2 border-b border-gray-200">
            <button
              onClick={() => setActiveTab("all")}
              className={`px-4 py-2 text-sm font-medium transition-colors ${
                activeTab === "all"
                  ? "text-blue-600 border-b-2 border-blue-600"
                  : "text-gray-600 hover:text-gray-900"
              }`}
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              All Stats
            </button>
            <button
              onClick={() => setActiveTab("draft")}
              className={`px-4 py-2 text-sm font-medium transition-colors ${
                activeTab === "draft"
                  ? "text-blue-600 border-b-2 border-blue-600"
                  : "text-gray-600 hover:text-gray-900"
              }`}
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              Draft Stats
            </button>
            <button
              onClick={() => setActiveTab("approved")}
              className={`px-4 py-2 text-sm font-medium transition-colors ${
                activeTab === "approved"
                  ? "text-blue-600 border-b-2 border-blue-600"
                  : "text-gray-600 hover:text-gray-900"
              }`}
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              Approved Stats
            </button>
          </div>

          {/* Games List */}
      {filteredMatches.length === 0 ? (
        <div className="text-center py-8 text-gray-500">
          {searchQuery ? "No games found matching your search" : "No games found"}
        </div>
      ) : (
        <div className="space-y-4">
          {filteredMatches.map((match) => {
            const statusBadge = getStatusBadge(match.status)
            return (
              <div
                key={match._id}
                onClick={() => {
                  // Fetch full match details
                  const fetchMatchDetails = async () => {
                    try {
                      const token = localStorage.getItem("token")
                      if (!token) return

                      const response = await fetch(`/api/match/${match._id}`, {
                        headers: {
                          Authorization: `Bearer ${token}`,
                        },
                      })

                      if (response.ok) {
                        const data = await response.json()
                        setSelectedMatch(data.data)
                        setSelectedTeam("teamA")
                      }
                    } catch (err) {
                      console.error("Error fetching match details:", err)
                      // Fallback to basic match data
                      setSelectedMatch(match)
                      setSelectedTeam("teamA")
                    }
                  }
                  fetchMatchDetails()
                }}
                className="bg-white border border-gray-200 rounded-xl p-4 cursor-pointer hover:shadow-md transition-shadow"
              >
                {/* League Name and Status */}
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm text-gray-600 font-medium" style={{ fontFamily: "Lato, sans-serif" }}>
                    {typeof match.leagueId === "object" ? match.leagueId?.leagueName : ""}
                  </span>
                  <span className={`px-3 py-1 rounded-lg text-xs font-medium ${statusBadge.className}`}>
                    {statusBadge.text}
                  </span>
                </div>

                {/* Teams Row */}
                <div className="flex items-center justify-between gap-4">
                  {/* Team A */}
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <div className="w-12 h-12 rounded-lg bg-red-600 flex items-center justify-center flex-shrink-0">
                      <span className="text-white font-bold text-xs">
                        {(() => {
                          const getTeamName = (team: any): string => {
                            if (!team || !team.teamId) return "TA"
                            if (typeof team.teamId === "object" && team.teamId.teamName) {
                              return team.teamId.teamName
                            }
                            return "TA"
                          }
                          const teamName = getTeamName(match.teamA)
                          const words = teamName.split(" ")
                          if (words.length >= 2) {
                            return (words[0][0] + words[1][0]).toUpperCase()
                          }
                          return teamName.substring(0, 2).toUpperCase()
                        })()}
                      </span>
                    </div>
                  </div>

                  {/* Date and Time - Center */}
                  <div className="flex-1 text-center min-w-0">
                    <span className="text-sm text-gray-700 font-medium" style={{ fontFamily: "Lato, sans-serif" }}>
                      {(() => {
                        try {
                          const date = new Date(match.gameDate)
                          const day = date.getDate().toString().padStart(2, "0")
                          const month = (date.getMonth() + 1).toString().padStart(2, "0")
                          
                          let timeStr = match.gameTime
                          if (timeStr && !timeStr.includes("AM") && !timeStr.includes("PM")) {
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
                      })()}
                    </span>
                  </div>

                  {/* Team B */}
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <div className="w-12 h-12 rounded-lg bg-yellow-400 flex items-center justify-center flex-shrink-0">
                      <span className="text-gray-900 font-bold text-xs">
                        {(() => {
                          const getTeamName = (team: any): string => {
                            if (!team || !team.teamId) return "TB"
                            if (typeof team.teamId === "object" && team.teamId.teamName) {
                              return team.teamId.teamName
                            }
                            return "TB"
                          }
                          const teamName = getTeamName(match.teamB)
                          const words = teamName.split(" ")
                          if (words.length >= 2) {
                            return (words[0][0] + words[1][0]).toUpperCase()
                          }
                          return teamName.substring(0, 2).toUpperCase()
                        })()}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      )}
        </>
      )}
    </div>
  )
}

// Match Detail View Component
function MatchDetailView({ 
  match, 
  selectedTeam, 
  onTeamSelect, 
  onBack,
  onSeeDetails,
  onAddStats
}: { 
  match: Match
  selectedTeam: SelectedTeam
  onTeamSelect: (team: SelectedTeam) => void
  onBack: () => void
  onSeeDetails: () => void
  onAddStats: () => void
}) {
  const router = useRouter()
  // Helper functions
  const getTeamName = (team: any): string => {
    if (!team || !team.teamId) return "Team"
    if (typeof team.teamId === "object" && team.teamId.teamName) {
      return team.teamId.teamName
    }
    return "Team"
  }

  const getTeamInitials = (teamName: string): string => {
    const words = teamName.split(" ")
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase()
    }
    return teamName.substring(0, 2).toUpperCase()
  }

  const leagueName = typeof match.leagueId === "object" && match.leagueId 
    ? match.leagueId.leagueName 
    : "Match"

  const teamAName = getTeamName(match.teamA)
  const teamBName = getTeamName(match.teamB)
  const teamAScore = match.teamA?.score || 0
  const teamBScore = match.teamB?.score || 0
  const teamAWin = match.teamA?.win === true
  const teamBWin = match.teamB?.win === true

  const currentTeam = selectedTeam === "teamA" ? match.teamA : match.teamB
  const currentTeamName = selectedTeam === "teamA" ? teamAName : teamBName
  const currentTeamStats = currentTeam?.teamStats || {}

  // Get touchdowns from team stats
  const teamATDs = match.teamA?.teamStats?.touchdowns || 0
  const teamBTDs = match.teamB?.teamStats?.touchdowns || 0

  return (
    <div className="flex flex-col gap-4">
      {/* Header with Back Button */}
      <div className="flex items-center gap-3">
        <button
          onClick={onBack}
          className="p-2 hover:bg-gray-100 rounded-full"
        >
          <ArrowLeft className="w-5 h-5 text-gray-700" />
        </button>
        <div className="flex items-center gap-2">
          {typeof match.leagueId === "object" && match.leagueId?.logo && (
            <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center">
              <span className="text-xs font-bold">L</span>
            </div>
          )}
          <h2 className="text-2xl font-bold text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
            {leagueName}
          </h2>
        </div>
      </div>
      <p className="text-sm text-muted-foreground ml-12" style={{ fontFamily: "Lato, sans-serif" }}>
        View all Stats game summary of this league assigned game.
      </p>

      {/* Score Cards */}
      <div className="grid grid-cols-2 gap-4">
        {/* Team A Card */}
        <div className={`rounded-xl p-4 ${teamAWin ? "bg-blue-900" : "bg-white border border-gray-200"}`}>
          <div className="flex items-start justify-between mb-2">
            <span className={`text-xs font-medium ${teamAWin ? "text-yellow-400" : "text-gray-600"}`}>
              {teamAWin ? `${teamAName} Winner` : teamAName}
            </span>
            <div className="w-10 h-10 rounded-lg bg-red-600 flex items-center justify-center">
              <span className="text-white font-bold text-xs">
                {getTeamInitials(teamAName)}
              </span>
            </div>
          </div>
          <div className={`text-2xl font-bold ${teamAWin ? "text-white" : "text-gray-900"}`}>
            {teamATDs} TDs
          </div>
        </div>

        {/* Team B Card */}
        <div className={`rounded-xl p-4 ${teamBWin ? "bg-blue-900" : "bg-white border border-gray-200"}`}>
          <div className="flex items-start justify-between mb-2">
            <span className={`text-xs font-medium ${teamBWin ? "text-yellow-400" : "text-gray-600"}`}>
              {teamBWin ? `${teamBName} Winner` : teamBName}
            </span>
            <div className="w-10 h-10 rounded-lg bg-yellow-400 flex items-center justify-center">
              <span className="text-gray-900 font-bold text-xs">
                {getTeamInitials(teamBName)}
              </span>
            </div>
          </div>
          <div className={`text-2xl font-bold ${teamBWin ? "text-white" : "text-gray-900"}`}>
            {teamBTDs} TDs
          </div>
        </div>
      </div>

      {/* Team Selector */}
      <div className="bg-white border border-gray-200 rounded-xl p-4">
        <h3 className="text-lg font-semibold mb-3" style={{ fontFamily: "Lato, sans-serif" }}>
          Select Team Stats
        </h3>
        <div className="flex gap-2">
          <button
            onClick={() => onTeamSelect("teamA")}
            className={`flex-1 px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              selectedTeam === "teamA"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            {teamAName}
          </button>
          <button
            onClick={() => onTeamSelect("teamB")}
            className={`flex-1 px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              selectedTeam === "teamB"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            {teamBName}
          </button>
        </div>
      </div>

      {/* Team Stats */}
      <div className="bg-white border border-gray-200 rounded-xl p-4">
        <h3 className="text-lg font-semibold mb-4" style={{ fontFamily: "Lato, sans-serif" }}>
          {currentTeamName} Team Stats
        </h3>
        <div className="space-y-3">
          <StatRow label="Catches" value={currentTeamStats.catches || 0} />
          <StatRow label="Catches Yrds" value={currentTeamStats.catchYards || 0} />
          <StatRow label="Rushes" value={currentTeamStats.rushes || 0} />
          <StatRow label="Rushes Yrds" value={currentTeamStats.rushYards || 0} />
          <StatRow label="TD's" value={currentTeamStats.touchdowns || 0} />
          <StatRow label="Flag Pull" value={currentTeamStats.flags || 0} />
          <StatRow label="INT" value={0} />
          <StatRow label="Safety" value={currentTeamStats.safeties || 0} />
          <StatRow label="Conversion Points" value={currentTeamStats.extraPoints || 0} />
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex gap-3">
        <button
          onClick={onSeeDetails}
          className="flex-1 bg-blue-900 text-white py-3 rounded-xl font-medium hover:bg-blue-800 transition-colors"
          style={{ fontFamily: "Lato, sans-serif" }}
        >
          See Stats in Details
        </button>
        <button
          onClick={onAddStats}
          className="flex-1 bg-white border-2 border-blue-900 text-blue-900 py-3 rounded-xl font-medium hover:bg-blue-50 transition-colors flex items-center justify-center gap-2"
          style={{ fontFamily: "Lato, sans-serif" }}
        >
          <Plus className="w-5 h-5" />
          Add Game Stats
        </button>
      </div>
    </div>
  )
}

// Stats Detail View Component
function StatsDetailView({
  match,
  selectedTeam,
  activeTab,
  onTabChange,
  onBack,
  onStatsAdded
}: {
  match: Match
  selectedTeam: SelectedTeam
  activeTab: StatsDetailTab
  onTabChange: (tab: StatsDetailTab) => void
  onBack: () => void
  onStatsAdded?: () => void
}) {
  const router = useRouter()
  const [expandedPlayers, setExpandedPlayers] = useState<Set<string>>(new Set())
  const [showAddStatsModal, setShowAddStatsModal] = useState(false)
  
  // Helper functions
  const getTeamName = (team: any): string => {
    if (!team || !team.teamId) return "Team"
    if (typeof team.teamId === "object" && team.teamId.teamName) {
      return team.teamId.teamName
    }
    return "Team"
  }

  const getTeamInitials = (teamName: string): string => {
    const words = teamName.split(" ")
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase()
    }
    return teamName.substring(0, 2).toUpperCase()
  }

  const togglePlayer = (playerId: string) => {
    setExpandedPlayers(prev => {
      const newSet = new Set(prev)
      if (newSet.has(playerId)) {
        newSet.delete(playerId)
      } else {
        newSet.add(playerId)
      }
      return newSet
    })
  }

  const currentTeam = selectedTeam === "teamA" ? match.teamA : match.teamB
  const currentTeamName = getTeamName(currentTeam)
  const currentTeamStats = currentTeam?.teamStats || {}
  const currentPlayerStats = currentTeam?.playerStats || []
  const isWinner = currentTeam?.win === true

  return (
    <div className="flex flex-col gap-4">
      {/* Header with Back Button and Team Info */}
      <div className="bg-blue-600 rounded-xl p-4">
        <div className="flex items-center gap-3 mb-3">
          <button
            onClick={onBack}
            className="p-2 hover:bg-blue-700 rounded-full"
          >
            <ArrowLeft className="w-5 h-5 text-white" />
          </button>
          <div className="flex items-center gap-3 flex-1">
            <div className="w-12 h-12 rounded-full bg-black border-2 border-yellow-400 flex items-center justify-center">
              <span className="text-yellow-400 font-bold text-lg">
                {getTeamInitials(currentTeamName)}
              </span>
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <h2 className="text-2xl font-bold text-white" style={{ fontFamily: "Lato, sans-serif" }}>
                  {currentTeamName}
                </h2>
                {isWinner && (
                  <span className="text-yellow-400 text-sm font-medium" style={{ fontFamily: "Lato, sans-serif" }}>
                    winner
                  </span>
                )}
              </div>
              <p className="text-sm text-blue-100 mt-1" style={{ fontFamily: "Lato, sans-serif" }}>
                View all Stats game summary of this league assigned game.
              </p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex gap-2">
          <button
            onClick={() => onTabChange("team")}
            className={`flex-1 px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              activeTab === "team"
                ? "bg-white text-blue-600"
                : "bg-blue-500 text-white border border-blue-400"
            }`}
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Team Stats
          </button>
          <button
            onClick={() => onTabChange("players")}
            className={`flex-1 px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              activeTab === "players"
                ? "bg-white text-blue-600"
                : "bg-blue-500 text-white border border-blue-400"
            }`}
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            Players Stats
          </button>
        </div>
      </div>

      {/* Content based on active tab */}
      {activeTab === "team" ? (
        <div className="bg-white border border-gray-200 rounded-xl p-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold" style={{ fontFamily: "Lato, sans-serif" }}>
              Team Statistics
            </h3>
            <button className="p-2 hover:bg-gray-100 rounded-lg">
              <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
            </button>
          </div>
          <div className="space-y-3">
            <StatRow label="Catches" value={currentTeamStats.catches || 0} />
            <StatRow label="Catches Yrds" value={currentTeamStats.catchYards || 0} />
            <StatRow label="Rushes" value={currentTeamStats.rushes || 0} />
            <StatRow label="Rushes Yrds" value={currentTeamStats.rushYards || 0} />
            <StatRow label="Pass Attempts" value={0} />
            <StatRow label="Pass Yrds" value={0} />
            <StatRow label="Completions" value={0} />
            <StatRow label="TD's" value={currentTeamStats.touchdowns || 0} />
            <StatRow label="Flag Pull" value={currentTeamStats.flags || 0} />
            <StatRow label="Sack" value={0} />
            <StatRow label="INT" value={0} />
            <StatRow label="Safety" value={currentTeamStats.safeties || 0} />
            <StatRow label="Conversion Points" value={currentTeamStats.extraPoints || 0} />
          </div>
        </div>
      ) : (
        <div className="bg-white border border-gray-200 rounded-xl p-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold" style={{ fontFamily: "Lato, sans-serif" }}>
              Players Statistics
            </h3>
            <button className="p-2 hover:bg-gray-100 rounded-lg">
              <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
            </button>
          </div>
          {(() => {
            // Get all players from the match (both active and inactive)
            const matchPlayers = currentTeam?.players || []
            
            if (matchPlayers.length === 0) {
              return (
                <div className="text-center py-8 text-gray-500">
                  No players available for this team
                </div>
              )
            }

            // Create a map of playerId to stats for quick lookup
            const statsMap = new Map<string, PlayerStat>()
            if (currentTeam?.playerStats) {
              currentTeam.playerStats.forEach((stat) => {
                const playerId = typeof stat.playerId === "object" 
                  ? stat.playerId._id 
                  : stat.playerId
                if (playerId) {
                  statsMap.set(playerId.toString(), stat)
                }
              })
            }

            return (
              <div className="space-y-4">
                {matchPlayers.map((matchPlayer, index) => {
                  const playerId = typeof matchPlayer.playerId === "object"
                    ? matchPlayer.playerId._id
                    : matchPlayer.playerId
                  
                  const player = typeof matchPlayer.playerId === "object"
                    ? matchPlayer.playerId
                    : null
                  
                  const playerName = player
                    ? `${player.firstName || ""} ${player.lastName || ""}`.trim() || "Unknown Player"
                    : "Unknown Player"
                  
                  const playerPosition = player?.position || "N/A"
                  const playerImage = player?.profileImage || ""
                  
                  // Get stats for this player
                  const playerStat = playerId ? statsMap.get(playerId.toString()) : null
                  const playerIdStr = playerId?.toString() || `player-${index}`
                  const isExpanded = expandedPlayers.has(playerIdStr)
                  
                  return (
                    <div key={index} className="border border-gray-200 rounded-xl p-4">
                      {/* Player Header */}
                      <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center gap-3">
                          <div className="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center overflow-hidden">
                            {playerImage ? (
                              <img 
                                src={playerImage} 
                                alt={playerName}
                                className="w-full h-full object-cover"
                              />
                            ) : (
                              <span className="text-gray-600 font-semibold text-sm">
                                {playerName.split(" ").map(n => n[0]).join("").toUpperCase().substring(0, 2)}
                              </span>
                            )}
                          </div>
                          <div>
                            <h4 className="font-semibold text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
                              {playerName}
                            </h4>
                            <p className="text-sm text-gray-500" style={{ fontFamily: "Lato, sans-serif" }}>
                              Position: {playerPosition}
                            </p>
                          </div>
                        </div>
                        <button 
                          onClick={() => togglePlayer(playerIdStr)}
                          className="p-2 hover:bg-gray-100 rounded-lg transition-transform"
                        >
                          <svg 
                            className={`w-5 h-5 text-gray-600 transition-transform ${isExpanded ? 'rotate-180' : ''}`} 
                            fill="none" 
                            stroke="currentColor" 
                            viewBox="0 0 24 24"
                          >
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                          </svg>
                        </button>
                      </div>

                      {/* Collapsible Stats Section */}
                      {isExpanded && (
                        <>
                          {/* Player Stats Summary */}
                          <div className="flex items-center justify-between mb-3">
                            <h5 className="text-base font-semibold text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
                              Player Stats Summary
                            </h5>
                            <div className="flex items-center gap-2">
                              <button className="p-1.5 hover:bg-gray-100 rounded-lg">
                                <svg className="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                                </svg>
                              </button>
                              <button className="p-1.5 hover:bg-gray-100 rounded-lg">
                                <svg className="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                </svg>
                              </button>
                            </div>
                          </div>

                          {/* Stats List */}
                          <div className="space-y-2">
                            <StatRow label="Catches" value={String(playerStat?.catches || 0).padStart(2, "0")} />
                            <StatRow label="Catches Yrds" value={playerStat?.catchYards || 0} />
                            <StatRow label="Rushes" value={playerStat?.rushes || 0} />
                            <StatRow label="Rushes Yrds" value={playerStat?.rushYards || 0} />
                            <StatRow label="Pass Attempts" value={0} />
                            <StatRow label="Pass Yrds" value={0} />
                            <StatRow label="Completions" value={String(0).padStart(2, "0")} />
                            <StatRow label="TD's" value={String(playerStat?.touchdowns || 0).padStart(2, "0")} />
                            <StatRow label="Flag Pull" value={String(playerStat?.flags || 0).padStart(2, "0")} />
                            <StatRow label="Sack" value={String(0).padStart(2, "0")} />
                            <StatRow label="INT" value={0} />
                            <StatRow label="Safety" value={String(playerStat?.safeties || 0).padStart(2, "0")} />
                            <StatRow label="Conversion Points" value={String(playerStat?.extraPoints || 0).padStart(2, "0")} />
                          </div>

                          {/* Bottom Separator with Player Info */}
                          <div className="mt-4 pt-4 border-t border-dashed border-gray-300">
                            <div className="flex items-center justify-between">
                              <div className="flex items-center gap-3">
                                <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center overflow-hidden">
                                  {playerImage ? (
                                    <img 
                                      src={playerImage} 
                                      alt={playerName}
                                      className="w-full h-full object-cover"
                                    />
                                  ) : (
                                    <span className="text-gray-600 font-semibold text-xs">
                                      {playerName.split(" ").map(n => n[0]).join("").toUpperCase().substring(0, 2)}
                                    </span>
                                  )}
                                </div>
                                <div>
                                  <p className="font-semibold text-gray-900 text-sm" style={{ fontFamily: "Lato, sans-serif" }}>
                                    {playerName}
                                  </p>
                                  <p className="text-xs text-gray-500" style={{ fontFamily: "Lato, sans-serif" }}>
                                    Position: {playerPosition}
                                  </p>
                                </div>
                              </div>
                              <button 
                                onClick={() => togglePlayer(playerIdStr)}
                                className="p-2 hover:bg-gray-100 rounded-lg"
                              >
                                <svg className="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                </svg>
                              </button>
                            </div>
                          </div>
                        </>
                      )}
                    </div>
                  )
                })}
              </div>
            )
          })(          )}
        </div>
      )}

      {/* Floating Add Game Stats Button */}
      <button
        onClick={() => setShowAddStatsModal(true)}
        className="fixed bottom-6 right-6 w-14 h-14 bg-blue-600 text-white rounded-full shadow-lg hover:bg-blue-700 transition-colors flex items-center justify-center z-50"
        style={{ fontFamily: "Lato, sans-serif" }}
      >
        <Plus className="w-6 h-6" />
      </button>

      {/* Add Game Stats Modal */}
      {showAddStatsModal && (
        <AddGameStatsModal
          match={match}
          isOpen={showAddStatsModal}
          onClose={() => setShowAddStatsModal(false)}
          onSave={async () => {
            setShowAddStatsModal(false)
            if (onStatsAdded) {
              onStatsAdded()
            }
          }}
        />
      )}
    </div>
  )
}

// Add Game Stats Modal Component
function AddGameStatsModal({
  match,
  isOpen,
  onClose,
  onSave
}: {
  match: Match
  isOpen: boolean
  onClose: () => void
  onSave: () => void
}) {
  const [selectedTeam, setSelectedTeam] = useState<"teamA" | "teamB" | "">("")
  const [selectedPlayerId, setSelectedPlayerId] = useState<string>("")
  const [isLoading, setIsLoading] = useState(false)
  
  // Stats form fields
  const [catches, setCatches] = useState<string>("")
  const [catchesYards, setCatchesYards] = useState<string>("")
  const [rushes, setRushes] = useState<string>("")
  const [rushesYards, setRushesYards] = useState<string>("")
  const [passAttempts, setPassAttempts] = useState<string>("")
  const [passYards, setPassYards] = useState<string>("")
  const [completions, setCompletions] = useState<string>("")
  const [tds, setTds] = useState<string>("")
  const [flagPull, setFlagPull] = useState<string>("")
  const [sack, setSack] = useState<string>("")
  const [int, setInt] = useState<string>("")
  const [safety, setSafety] = useState<string>("")
  const [conversionPoints, setConversionPoints] = useState<string>("")

  // Get teams from match
  const teamA = match.teamA
  const teamB = match.teamB
  const teamAName = typeof teamA?.teamId === "object" && teamA.teamId?.teamName 
    ? teamA.teamId.teamName 
    : "Team A"
  const teamBName = typeof teamB?.teamId === "object" && teamB.teamId?.teamName 
    ? teamB.teamId.teamName 
    : "Team B"

  // Get players from selected team
  const selectedTeamData = selectedTeam === "teamA" ? teamA : selectedTeam === "teamB" ? teamB : null
  const availablePlayers = selectedTeamData?.players || []

  // Reset form when team changes
  useEffect(() => {
    if (selectedTeam) {
      setSelectedPlayerId("")
      // Reset all stats fields
      setCatches("")
      setCatchesYards("")
      setRushes("")
      setRushesYards("")
      setPassAttempts("")
      setPassYards("")
      setCompletions("")
      setTds("")
      setFlagPull("")
      setSack("")
      setInt("")
      setSafety("")
      setConversionPoints("")
    }
  }, [selectedTeam])

  const handleSave = async () => {
    if (!selectedTeam || !selectedPlayerId) {
      alert("Please select a team and player")
      return
    }

    setIsLoading(true)
    try {
      // Get authentication token
      const token = localStorage.getItem("token")
      if (!token) {
        alert("Please login to add game stats")
        setIsLoading(false)
        return
      }

      const teamData = selectedTeam === "teamA" ? teamA : teamB
      const existingPlayerStats = teamData?.playerStats || []
      
      // Find existing player stat or create new
      const existingStatIndex = existingPlayerStats.findIndex((ps: any) => {
        const psPlayerId = typeof ps.playerId === "object" ? ps.playerId._id : ps.playerId
        return psPlayerId?.toString() === selectedPlayerId
      })

      // Create new player stat with all fields
      const newPlayerStat = {
        playerId: selectedPlayerId,
        catches: parseInt(catches) || 0,
        catchYards: parseInt(catchesYards) || 0,
        rushes: parseInt(rushes) || 0,
        rushYards: parseInt(rushesYards) || 0,
        touchdowns: parseInt(tds) || 0,
        extraPoints: parseInt(conversionPoints) || 0,
        defensiveTDs: 0,
        safeties: parseInt(safety) || 0,
        flags: parseInt(flagPull) || 0,
        totalPoints: (parseInt(tds) || 0) * 6 + (parseInt(conversionPoints) || 0) + (parseInt(safety) || 0) * 2
      }

      // Update or add player stat
      // First, normalize all existing playerStats to ensure playerId is a string
      const normalizedExistingStats = existingPlayerStats.map((ps: any) => {
        const playerId = typeof ps.playerId === "object" && ps.playerId?._id 
          ? ps.playerId._id.toString() 
          : ps.playerId?.toString() || ps.playerId
        return {
          ...ps,
          playerId: playerId
        }
      })

      const updatedPlayerStats = [...normalizedExistingStats]
      if (existingStatIndex >= 0) {
        // Merge with existing stats (add new values to existing)
        const existing = updatedPlayerStats[existingStatIndex]
        updatedPlayerStats[existingStatIndex] = {
          playerId: selectedPlayerId, // Ensure it's a string
          catches: (existing.catches || 0) + newPlayerStat.catches,
          catchYards: (existing.catchYards || 0) + newPlayerStat.catchYards,
          rushes: (existing.rushes || 0) + newPlayerStat.rushes,
          rushYards: (existing.rushYards || 0) + newPlayerStat.rushYards,
          touchdowns: (existing.touchdowns || 0) + newPlayerStat.touchdowns,
          extraPoints: (existing.extraPoints || 0) + newPlayerStat.extraPoints,
          defensiveTDs: (existing.defensiveTDs || 0) + newPlayerStat.defensiveTDs,
          safeties: (existing.safeties || 0) + newPlayerStat.safeties,
          flags: (existing.flags || 0) + newPlayerStat.flags,
          totalPoints: (existing.totalPoints || 0) + newPlayerStat.totalPoints
        }
      } else {
        // Add new player stat
        updatedPlayerStats.push(newPlayerStat)
      }

      // Ensure all playerIds are strings before sending
      const statsToSend = updatedPlayerStats.map((ps: any) => ({
        playerId: typeof ps.playerId === "object" && ps.playerId?._id 
          ? ps.playerId._id.toString() 
          : ps.playerId?.toString() || ps.playerId,
        catches: ps.catches || 0,
        catchYards: ps.catchYards || 0,
        rushes: ps.rushes || 0,
        rushYards: ps.rushYards || 0,
        touchdowns: ps.touchdowns || 0,
        extraPoints: ps.extraPoints || 0,
        defensiveTDs: ps.defensiveTDs || 0,
        safeties: ps.safeties || 0,
        flags: ps.flags || 0,
        totalPoints: ps.totalPoints || 0
      }))

      // Calculate team stats from sum of all player stats
      const teamStats = {
        catches: statsToSend.reduce((sum, ps) => sum + (ps.catches || 0), 0),
        catchYards: statsToSend.reduce((sum, ps) => sum + (ps.catchYards || 0), 0),
        rushes: statsToSend.reduce((sum, ps) => sum + (ps.rushes || 0), 0),
        rushYards: statsToSend.reduce((sum, ps) => sum + (ps.rushYards || 0), 0),
        touchdowns: statsToSend.reduce((sum, ps) => sum + (ps.touchdowns || 0), 0),
        extraPoints: statsToSend.reduce((sum, ps) => sum + (ps.extraPoints || 0), 0),
        defensiveTDs: statsToSend.reduce((sum, ps) => sum + (ps.defensiveTDs || 0), 0),
        safeties: statsToSend.reduce((sum, ps) => sum + (ps.safeties || 0), 0),
        flags: statsToSend.reduce((sum, ps) => sum + (ps.flags || 0), 0),
        totalPoints: statsToSend.reduce((sum, ps) => sum + (ps.totalPoints || 0), 0)
      }

      // Update match via API - save to the selected team with calculated team stats
      const response = await fetch(`/api/match/${match._id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify({
          [selectedTeam]: {
            playerStats: statsToSend,
            teamStats: teamStats
          }
        }),
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || "Failed to save stats")
      }

      const result = await response.json()
      console.log("Stats saved successfully:", result)
      alert("Game stats saved successfully!")
      onSave()
    } catch (error: any) {
      console.error("Error saving stats:", error)
      alert(error.message || "Failed to save stats")
    } finally {
      setIsLoading(false)
    }
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto border-2 border-dashed border-blue-200">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
              Add Game Stats
            </h2>
            <p className="text-sm text-gray-600 mt-1" style={{ fontFamily: "Lato, sans-serif" }}>
              Stats helps you to analyze game in smooth or better way.
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg"
          >
            <X className="w-5 h-5 text-gray-600" />
          </button>
        </div>

        {/* Form */}
        <div className="space-y-4">
          {/* Select Team */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
              Select Team
            </label>
            <select
              value={selectedTeam}
              onChange={(e) => setSelectedTeam(e.target.value as "teamA" | "teamB")}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              <option value="">Select Team</option>
              <option value="teamA">{teamAName}</option>
              <option value="teamB">{teamBName}</option>
            </select>
          </div>

          {/* Select Player */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
              Select Player
            </label>
            <select
              value={selectedPlayerId}
              onChange={(e) => setSelectedPlayerId(e.target.value)}
              disabled={!selectedTeam}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              <option value="">Select Player</option>
              {availablePlayers.map((player: any) => {
                const playerId = typeof player.playerId === "object" ? player.playerId._id : player.playerId
                const playerName = typeof player.playerId === "object" && player.playerId
                  ? `${player.playerId.firstName || ""} ${player.playerId.lastName || ""}`.trim() || "Unknown Player"
                  : "Unknown Player"
                return (
                  <option key={playerId} value={playerId}>
                    {playerName}
                  </option>
                )
              })}
            </select>
          </div>

          {/* Stats Input Fields */}
          <div className="grid grid-cols-2 gap-4">
            {/* Catches & Catches Yards */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Catches
              </label>
              <input
                type="number"
                value={catches}
                onChange={(e) => setCatches(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Catches Yards
              </label>
              <input
                type="number"
                value={catchesYards}
                onChange={(e) => setCatchesYards(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>

            {/* Rushes & Rushes Yards */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Rushes
              </label>
              <input
                type="number"
                value={rushes}
                onChange={(e) => setRushes(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Rushes Yards
              </label>
              <input
                type="number"
                value={rushesYards}
                onChange={(e) => setRushesYards(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>

            {/* Pass Attempts & Pass Yards */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Pass Attempts
              </label>
              <input
                type="number"
                value={passAttempts}
                onChange={(e) => setPassAttempts(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Pass Yards
              </label>
              <input
                type="number"
                value={passYards}
                onChange={(e) => setPassYards(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>

            {/* Completions & TD's */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Completions
              </label>
              <input
                type="number"
                value={completions}
                onChange={(e) => setCompletions(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                TD's
              </label>
              <input
                type="number"
                value={tds}
                onChange={(e) => setTds(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>

            {/* Flag Pull & Sack */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Flag Pull
              </label>
              <input
                type="number"
                value={flagPull}
                onChange={(e) => setFlagPull(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Sack
              </label>
              <input
                type="number"
                value={sack}
                onChange={(e) => setSack(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>

            {/* INT & Safety */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                INT
              </label>
              <input
                type="number"
                value={int}
                onChange={(e) => setInt(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
                Safety
              </label>
              <input
                type="number"
                value={safety}
                onChange={(e) => setSafety(e.target.value)}
                placeholder="Enter here"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
                style={{ fontFamily: "Lato, sans-serif" }}
              />
            </div>
          </div>

          {/* Conversion Points */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2" style={{ fontFamily: "Lato, sans-serif" }}>
              Conversion Points
            </label>
            <input
              type="number"
              value={conversionPoints}
              onChange={(e) => setConversionPoints(e.target.value)}
              placeholder="Enter here"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
              style={{ fontFamily: "Lato, sans-serif" }}
            />
          </div>

          {/* Action Buttons */}
          <div className="flex gap-4 pt-4">
            <button
              onClick={onClose}
              disabled={isLoading}
              className="flex-1 px-4 py-3 border border-gray-300 rounded-lg text-gray-700 font-medium hover:bg-gray-50 transition-colors disabled:opacity-50"
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              disabled={isLoading || !selectedTeam || !selectedPlayerId}
              className="flex-1 px-4 py-3 bg-blue-900 text-white rounded-lg font-medium hover:bg-blue-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              style={{ fontFamily: "Lato, sans-serif" }}
            >
              {isLoading ? "Saving..." : "Save as Draft"}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

// Stat Row Component
function StatRow({ label, value }: { label: string; value: number | string }) {
  return (
    <div className="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0">
      <span className="text-sm text-gray-600" style={{ fontFamily: "Lato, sans-serif" }}>
        {label}
      </span>
      <span className="text-sm font-semibold text-gray-900" style={{ fontFamily: "Lato, sans-serif" }}>
        {value}
      </span>
    </div>
  )
}

