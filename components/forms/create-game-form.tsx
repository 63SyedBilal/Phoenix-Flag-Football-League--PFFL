"use client"

import { useEffect, useState } from "react"
import Image from "next/image"
import { Calendar, Clock, ChevronDown } from "lucide-react"

interface Team {
  _id: string
  teamName: string
  enterCode: string
}

interface Referee {
  _id: string
  firstName: string
  lastName: string
  email: string
}

interface StatKeeper {
  _id: string
  firstName: string
  lastName: string
  email: string
}

interface League {
  _id: string
  leagueName: string
  format: "5v5" | "7v7"
}

interface CreateGameFormProps {
  onClose: () => void
  leagueId?: string
}

export default function CreateGameForm({ onClose, leagueId: initialLeagueId }: CreateGameFormProps) {
  const [leagues, setLeagues] = useState<League[]>([])
  const [selectedLeagueId, setSelectedLeagueId] = useState<string>(initialLeagueId || "")
  const [teams, setTeams] = useState<Team[]>([])
  const [referees, setReferees] = useState<Referee[]>([])
  const [statKeepers, setStatKeepers] = useState<StatKeeper[]>([])
  
  // Form state
  const [teamAId, setTeamAId] = useState<string>("")
  const [teamBId, setTeamBId] = useState<string>("")
  const [gameDate, setGameDate] = useState<string>("")
  const [gameTime, setGameTime] = useState<string>("")
  const [venue, setVenue] = useState<string>("")
  const [refereeId, setRefereeId] = useState<string>("")
  const [statKeeperId, setStatKeeperId] = useState<string>("")
  
  // UI state
  const [isLeagueDropdownOpen, setIsLeagueDropdownOpen] = useState(false)
  const [isTeamADropdownOpen, setIsTeamADropdownOpen] = useState(false)
  const [isTeamBDropdownOpen, setIsTeamBDropdownOpen] = useState(false)
  const [isVenueDropdownOpen, setIsVenueDropdownOpen] = useState(false)
  const [isRefereeDropdownOpen, setIsRefereeDropdownOpen] = useState(false)
  const [isStatKeeperDropdownOpen, setIsStatKeeperDropdownOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string>("")
  const [isLoadingData, setIsLoadingData] = useState(false)

  const venues = [
    "Main Stadium",
    "Training Ground A",
    "Training Ground B",
    "City Arena",
    "Community Field",
  ]

  // Fetch leagues
  useEffect(() => {
    const fetchLeagues = async () => {
      try {
        const token = localStorage.getItem("token")
        if (!token) return

        const response = await fetch("/api/league", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        if (response.ok) {
          const data = await response.json()
          setLeagues(data.data || [])
        }
      } catch (err) {
        console.error("Error fetching leagues:", err)
      }
    }

    fetchLeagues()
  }, [])

  // Fetch league details (teams, referees, stat keepers) when league is selected
  useEffect(() => {
    if (!selectedLeagueId) {
      setTeams([])
      setReferees([])
      setStatKeepers([])
      return
    }

    const fetchLeagueData = async () => {
      try {
        setIsLoadingData(true)
        const token = localStorage.getItem("token")
        if (!token) return

        const response = await fetch(`/api/league/${selectedLeagueId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        if (response.ok) {
          const data = await response.json()
          const league = data.data
          
          setTeams(league.teams || [])
          setReferees(league.referees || [])
          setStatKeepers(league.statKeepers || [])
        }
      } catch (err) {
        console.error("Error fetching league data:", err)
      } finally {
        setIsLoadingData(false)
      }
    }

    fetchLeagueData()
  }, [selectedLeagueId])

  const selectedLeague = leagues.find(l => l._id === selectedLeagueId)
  const selectedTeamA = teams.find(t => t._id === teamAId)
  const selectedTeamB = teams.find(t => t._id === teamBId)
  const selectedReferee = referees.find(r => r._id === refereeId)
  const selectedStatKeeper = statKeepers.find(s => s._id === statKeeperId)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")

    // Validation
    if (!selectedLeagueId) {
      setError("Please select a league")
      return
    }
    if (!teamAId || !teamBId) {
      setError("Please select both teams")
      return
    }
    if (teamAId === teamBId) {
      setError("Team A and Team B must be different")
      return
    }
    if (!gameDate) {
      setError("Please select a game date")
      return
    }
    if (!gameTime) {
      setError("Please select a game time")
      return
    }
    if (!selectedLeague) {
      setError("Please select a league")
      return
    }

    try {
      setIsLoading(true)
      const token = localStorage.getItem("token")
      if (!token) {
        setError("Please login to create a game")
        return
      }

      const response = await fetch("/api/match", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          leagueId: selectedLeagueId,
          teamA: teamAId,
          teamB: teamBId,
          format: selectedLeague.format,
          gameDate: gameDate,
          gameTime: gameTime,
          venue: venue || undefined,
          refereeId: refereeId || undefined,
          statKeeperId: statKeeperId || undefined,
        }),
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || "Failed to create game")
      }

      // Success - close modal
      onClose()
      // Optionally reload the page or refresh data
      window.location.reload()
    } catch (err: any) {
      console.error("Error creating game:", err)
      setError(err.message || "Failed to create game")
    } finally {
      setIsLoading(false)
    }
  }


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
        <form 
          onSubmit={handleSubmit} 
          className="flex flex-col" 
          style={{ width: "575px", gap: "20px" }}
          onClick={() => {
            // Close all dropdowns when clicking on form
            setIsLeagueDropdownOpen(false)
            setIsTeamADropdownOpen(false)
            setIsTeamBDropdownOpen(false)
            setIsVenueDropdownOpen(false)
            setIsRefereeDropdownOpen(false)
            setIsStatKeeperDropdownOpen(false)
          }}
        >
          {/* Title */}
          <div>
            <h2 className="text-2xl font-bold text-foreground text-center" style={{ fontFamily: "Lato, sans-serif" }}>
              Create New Game
            </h2>
            <p className="text-sm text-muted-foreground text-center mt-1" style={{ fontFamily: "Lato, sans-serif" }}>
              Schedule a new game for this league by filling out the details below.
            </p>
          </div>

          {/* League Selection */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              League
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation()
                  setIsLeagueDropdownOpen(!isLeagueDropdownOpen)
                }}
                className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                <span>{selectedLeague ? selectedLeague.leagueName : "Select League"}</span>
                <ChevronDown className={`w-4 h-4 transition-transform ${isLeagueDropdownOpen ? "rotate-180" : ""}`} />
              </button>
              {isLeagueDropdownOpen && (
                <div 
                  className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto"
                  onClick={(e) => e.stopPropagation()}
                >
                  {leagues.map((league) => (
                    <button
                      key={league._id}
                      type="button"
                      onClick={() => {
                        setSelectedLeagueId(league._id)
                        setIsLeagueDropdownOpen(false)
                        setTeamAId("")
                        setTeamBId("")
                      }}
                      className="w-full px-4 py-3 text-left text-sm transition-colors"
                      style={{
                        fontFamily: "Lato, sans-serif",
                        backgroundColor: selectedLeagueId === league._id ? "#0F173E" : "transparent",
                        color: selectedLeagueId === league._id ? "#FFFFFF" : "#000000",
                      }}
                      onMouseEnter={(e) => {
                        if (selectedLeagueId !== league._id) {
                          e.currentTarget.style.backgroundColor = "#F3F4F6"
                        }
                      }}
                      onMouseLeave={(e) => {
                        if (selectedLeagueId !== league._id) {
                          e.currentTarget.style.backgroundColor = "transparent"
                        }
                      }}
                    >
                      {league.leagueName}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Team Selection - Two columns */}
          <div className="grid grid-cols-2 gap-4">
            {/* Team A */}
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
                Select Team A
              </label>
              <div className="relative">
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation()
                    setIsTeamADropdownOpen(!isTeamADropdownOpen)
                  }}
                  disabled={!selectedLeagueId || isLoadingData}
                  className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left disabled:opacity-50 disabled:cursor-not-allowed"
                  style={{ fontFamily: "Lato, sans-serif" }}
                >
                  <span>{selectedTeamA ? selectedTeamA.teamName : "Team A"}</span>
                  <ChevronDown className={`w-4 h-4 transition-transform ${isTeamADropdownOpen ? "rotate-180" : ""}`} />
                </button>
                {isTeamADropdownOpen && teams.length > 0 && (
                  <div 
                    className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto"
                    onClick={(e) => e.stopPropagation()}
                  >
                    {teams
                      .filter(team => team._id !== teamBId)
                      .map((team) => (
                        <button
                          key={team._id}
                          type="button"
                          onClick={() => {
                            setTeamAId(team._id)
                            setIsTeamADropdownOpen(false)
                          }}
                          className="w-full px-4 py-3 text-left text-sm transition-colors"
                          style={{
                            fontFamily: "Lato, sans-serif",
                            backgroundColor: teamAId === team._id ? "#0F173E" : "transparent",
                            color: teamAId === team._id ? "#FFFFFF" : "#000000",
                          }}
                          onMouseEnter={(e) => {
                            if (teamAId !== team._id) {
                              e.currentTarget.style.backgroundColor = "#F3F4F6"
                            }
                          }}
                          onMouseLeave={(e) => {
                            if (teamAId !== team._id) {
                              e.currentTarget.style.backgroundColor = "transparent"
                            }
                          }}
                        >
                          {team.teamName}
                        </button>
                      ))}
                  </div>
                )}
              </div>
            </div>

            {/* Team B */}
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
                Select Team B
              </label>
              <div className="relative">
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation()
                    setIsTeamBDropdownOpen(!isTeamBDropdownOpen)
                  }}
                  disabled={!selectedLeagueId || isLoadingData}
                  className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left disabled:opacity-50 disabled:cursor-not-allowed"
                  style={{ fontFamily: "Lato, sans-serif" }}
                >
                  <span>{selectedTeamB ? selectedTeamB.teamName : "Team B"}</span>
                  <ChevronDown className={`w-4 h-4 transition-transform ${isTeamBDropdownOpen ? "rotate-180" : ""}`} />
                </button>
                {isTeamBDropdownOpen && teams.length > 0 && (
                  <div 
                    className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto"
                    onClick={(e) => e.stopPropagation()}
                  >
                    {teams
                      .filter(team => team._id !== teamAId)
                      .map((team) => (
                        <button
                          key={team._id}
                          type="button"
                          onClick={() => {
                            setTeamBId(team._id)
                            setIsTeamBDropdownOpen(false)
                          }}
                          className="w-full px-4 py-3 text-left text-sm transition-colors"
                          style={{
                            fontFamily: "Lato, sans-serif",
                            backgroundColor: teamBId === team._id ? "#0F173E" : "transparent",
                            color: teamBId === team._id ? "#FFFFFF" : "#000000",
                          }}
                          onMouseEnter={(e) => {
                            if (teamBId !== team._id) {
                              e.currentTarget.style.backgroundColor = "#F3F4F6"
                            }
                          }}
                          onMouseLeave={(e) => {
                            if (teamBId !== team._id) {
                              e.currentTarget.style.backgroundColor = "transparent"
                            }
                          }}
                        >
                          {team.teamName}
                        </button>
                      ))}
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Game Date */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Game Date
            </label>
            <div className="relative">
              <input
                type="date"
                value={gameDate}
                onChange={(e) => setGameDate(e.target.value)}
                className="w-full h-12 px-4 pr-10 rounded-lg border border-[#E5E7EB] bg-white"
                style={{ fontFamily: "Lato, sans-serif" }}
                placeholder="Select Game Date"
              />
              <Calendar className="absolute right-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
          </div>

          {/* Game Time */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Game Time
            </label>
            <div className="relative">
              <input
                type="time"
                value={gameTime}
                onChange={(e) => setGameTime(e.target.value)}
                className="w-full h-12 px-4 pr-10 rounded-lg border border-[#E5E7EB] bg-white"
                style={{ fontFamily: "Lato, sans-serif" }}
                placeholder="Edit Game Time"
              />
              <Clock className="absolute right-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
          </div>

          {/* Venue (optional) */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Venue (optional)
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation()
                  setIsVenueDropdownOpen(!isVenueDropdownOpen)
                }}
                className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                <span>{venue || "Select Venue"}</span>
                <ChevronDown className={`w-4 h-4 transition-transform ${isVenueDropdownOpen ? "rotate-180" : ""}`} />
              </button>
              {isVenueDropdownOpen && (
                <div 
                  className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto"
                  onClick={(e) => e.stopPropagation()}
                >
                  <button
                    type="button"
                    onClick={() => {
                      setVenue("")
                      setIsVenueDropdownOpen(false)
                    }}
                    className="w-full px-4 py-3 text-left text-sm transition-colors"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      backgroundColor: !venue ? "#0F173E" : "transparent",
                      color: !venue ? "#FFFFFF" : "#000000",
                    }}
                    onMouseEnter={(e) => {
                      if (venue) {
                        e.currentTarget.style.backgroundColor = "#F3F4F6"
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (venue) {
                        e.currentTarget.style.backgroundColor = "transparent"
                      }
                    }}
                  >
                    None
                  </button>
                  {venues.map((v) => (
                    <button
                      key={v}
                      type="button"
                      onClick={() => {
                        setVenue(v)
                        setIsVenueDropdownOpen(false)
                      }}
                      className="w-full px-4 py-3 text-left text-sm transition-colors"
                      style={{
                        fontFamily: "Lato, sans-serif",
                        backgroundColor: venue === v ? "#0F173E" : "transparent",
                        color: venue === v ? "#FFFFFF" : "#000000",
                      }}
                      onMouseEnter={(e) => {
                        if (venue !== v) {
                          e.currentTarget.style.backgroundColor = "#F3F4F6"
                        }
                      }}
                      onMouseLeave={(e) => {
                        if (venue !== v) {
                          e.currentTarget.style.backgroundColor = "transparent"
                        }
                      }}
                    >
                      {v}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Assign Referee (optional) */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Assign Referee (optional)
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation()
                  setIsRefereeDropdownOpen(!isRefereeDropdownOpen)
                }}
                disabled={!selectedLeagueId || isLoadingData}
                className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left disabled:opacity-50 disabled:cursor-not-allowed"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                <span>
                  {selectedReferee ? `${selectedReferee.firstName} ${selectedReferee.lastName}` : "Select Referee"}
                </span>
                <ChevronDown className={`w-4 h-4 transition-transform ${isRefereeDropdownOpen ? "rotate-180" : ""}`} />
              </button>
              {isRefereeDropdownOpen && referees.length > 0 && (
                <div 
                  className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto"
                  onClick={(e) => e.stopPropagation()}
                >
                  <button
                    type="button"
                    onClick={() => {
                      setRefereeId("")
                      setIsRefereeDropdownOpen(false)
                    }}
                    className="w-full px-4 py-3 text-left text-sm transition-colors"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      backgroundColor: !refereeId ? "#0F173E" : "transparent",
                      color: !refereeId ? "#FFFFFF" : "#000000",
                    }}
                    onMouseEnter={(e) => {
                      if (refereeId) {
                        e.currentTarget.style.backgroundColor = "#F3F4F6"
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (refereeId) {
                        e.currentTarget.style.backgroundColor = "transparent"
                      }
                    }}
                  >
                    None
                  </button>
                  {referees.map((referee) => (
                    <button
                      key={referee._id}
                      type="button"
                      onClick={() => {
                        setRefereeId(referee._id)
                        setIsRefereeDropdownOpen(false)
                      }}
                      className="w-full px-4 py-3 text-left text-sm transition-colors"
                      style={{
                        fontFamily: "Lato, sans-serif",
                        backgroundColor: refereeId === referee._id ? "#0F173E" : "transparent",
                        color: refereeId === referee._id ? "#FFFFFF" : "#000000",
                      }}
                      onMouseEnter={(e) => {
                        if (refereeId !== referee._id) {
                          e.currentTarget.style.backgroundColor = "#F3F4F6"
                        }
                      }}
                      onMouseLeave={(e) => {
                        if (refereeId !== referee._id) {
                          e.currentTarget.style.backgroundColor = "transparent"
                        }
                      }}
                    >
                      {referee.firstName} {referee.lastName}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Assign Stat Keeper (optional) */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Assign Stat Keeper (optional)
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation()
                  setIsStatKeeperDropdownOpen(!isStatKeeperDropdownOpen)
                }}
                disabled={!selectedLeagueId || isLoadingData}
                className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left disabled:opacity-50 disabled:cursor-not-allowed"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                <span>
                  {selectedStatKeeper ? `${selectedStatKeeper.firstName} ${selectedStatKeeper.lastName}` : "Select Stat Keeper"}
                </span>
                <ChevronDown className={`w-4 h-4 transition-transform ${isStatKeeperDropdownOpen ? "rotate-180" : ""}`} />
              </button>
              {isStatKeeperDropdownOpen && statKeepers.length > 0 && (
                <div 
                  className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto"
                  onClick={(e) => e.stopPropagation()}
                >
                  <button
                    type="button"
                    onClick={() => {
                      setStatKeeperId("")
                      setIsStatKeeperDropdownOpen(false)
                    }}
                    className="w-full px-4 py-3 text-left text-sm transition-colors"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      backgroundColor: !statKeeperId ? "#0F173E" : "transparent",
                      color: !statKeeperId ? "#FFFFFF" : "#000000",
                    }}
                    onMouseEnter={(e) => {
                      if (statKeeperId) {
                        e.currentTarget.style.backgroundColor = "#F3F4F6"
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (statKeeperId) {
                        e.currentTarget.style.backgroundColor = "transparent"
                      }
                    }}
                  >
                    None
                  </button>
                  {statKeepers.map((keeper) => (
                    <button
                      key={keeper._id}
                      type="button"
                      onClick={() => {
                        setStatKeeperId(keeper._id)
                        setIsStatKeeperDropdownOpen(false)
                      }}
                      className="w-full px-4 py-3 text-left text-sm transition-colors"
                      style={{
                        fontFamily: "Lato, sans-serif",
                        backgroundColor: statKeeperId === keeper._id ? "#0F173E" : "transparent",
                        color: statKeeperId === keeper._id ? "#FFFFFF" : "#000000",
                      }}
                      onMouseEnter={(e) => {
                        if (statKeeperId !== keeper._id) {
                          e.currentTarget.style.backgroundColor = "#F3F4F6"
                        }
                      }}
                      onMouseLeave={(e) => {
                        if (statKeeperId !== keeper._id) {
                          e.currentTarget.style.backgroundColor = "transparent"
                        }
                      }}
                    >
                      {keeper.firstName} {keeper.lastName}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Error Message */}
          {error && (
            <div className="p-3 rounded-md bg-red-50 border border-red-200">
              <p className="text-sm text-red-600" style={{ fontFamily: "Lato, sans-serif" }}>
                {error}
              </p>
            </div>
          )}

          {/* Create Game Button */}
          <div className="flex items-center justify-center mt-auto pt-4">
            <button
              type="submit"
              disabled={isLoading}
              className="w-full h-12 rounded-full text-sm font-medium text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              style={{
                backgroundColor: "#0F173E",
                fontFamily: "Lato, sans-serif",
              }}
            >
              {isLoading ? "Creating..." : "Create Game"}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

