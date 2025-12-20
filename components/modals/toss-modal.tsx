"use client"

import { useState, useEffect } from "react"
import { X, ChevronDown } from "lucide-react"

interface Team {
  _id: string
  teamName: string
  enterCode?: string
}

interface TossModalProps {
  isOpen: boolean
  onClose: () => void
  teamA: Team
  teamB: Team
  onStartMatch: (tossWinner: string, decision: "offense" | "defense") => void
}

export default function TossModal({ isOpen, onClose, teamA, teamB, onStartMatch }: TossModalProps) {
  const [selectedTeam, setSelectedTeam] = useState<string | null>(null)
  const [selectedDecision, setSelectedDecision] = useState<"offense" | "defense" | null>(null)
  const [isDecisionDropdownOpen, setIsDecisionDropdownOpen] = useState(false)

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = () => {
      setIsDecisionDropdownOpen(false)
    }

    if (isDecisionDropdownOpen) {
      document.addEventListener("click", handleClickOutside)
      return () => {
        document.removeEventListener("click", handleClickOutside)
      }
    }
  }, [isDecisionDropdownOpen])

  // Reset state when modal closes
  useEffect(() => {
    if (!isOpen) {
      setSelectedTeam(null)
      setSelectedDecision(null)
      setIsDecisionDropdownOpen(false)
    }
  }, [isOpen])

  if (!isOpen) return null

  // Get team initials for logo
  const getTeamInitials = (teamName: string) => {
    const words = teamName.split(" ")
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase()
    }
    return teamName.substring(0, 2).toUpperCase()
  }

  const handleStartMatch = () => {
    if (selectedTeam && selectedDecision) {
      onStartMatch(selectedTeam, selectedDecision)
      // Reset state
      setSelectedTeam(null)
      setSelectedDecision(null)
      onClose()
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
        className="bg-white rounded-[24px] relative"
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
              Toss
            </h2>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 rounded-full transition-colors"
            >
              <X className="w-5 h-5 text-gray-600" />
            </button>
          </div>

          {/* Select Toss Winner */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Select Toss Winner
            </label>
            <div className="flex gap-3">
              {/* Team A Button */}
              <button
                onClick={() => setSelectedTeam(teamA._id)}
                className={`flex-1 flex items-center gap-3 px-4 py-3 rounded-lg border-2 transition-colors ${
                  selectedTeam === teamA._id
                    ? "border-blue-600 bg-blue-50"
                    : "border-gray-200 bg-white hover:bg-gray-50"
                }`}
              >
                <div className="w-12 h-12 rounded-lg bg-red-600 flex items-center justify-center flex-shrink-0">
                  <span className="text-white font-bold text-sm">
                    {getTeamInitials(teamA.teamName)}
                  </span>
                </div>
                <span
                  className={`text-sm font-medium ${
                    selectedTeam === teamA._id ? "text-blue-600" : "text-gray-700"
                  }`}
                  style={{ fontFamily: "Lato, sans-serif" }}
                >
                  {teamA.teamName}
                </span>
              </button>

              {/* Team B Button */}
              <button
                onClick={() => setSelectedTeam(teamB._id)}
                className={`flex-1 flex items-center gap-3 px-4 py-3 rounded-lg border-2 transition-colors ${
                  selectedTeam === teamB._id
                    ? "border-blue-600 bg-blue-50"
                    : "border-gray-200 bg-white hover:bg-gray-50"
                }`}
              >
                <div className="w-12 h-12 rounded-lg bg-yellow-400 flex items-center justify-center flex-shrink-0">
                  <span className="text-gray-900 font-bold text-sm">
                    {getTeamInitials(teamB.teamName)}
                  </span>
                </div>
                <span
                  className={`text-sm font-medium ${
                    selectedTeam === teamB._id ? "text-blue-600" : "text-gray-700"
                  }`}
                  style={{ fontFamily: "Lato, sans-serif" }}
                >
                  {teamB.teamName}
                </span>
              </button>
            </div>
          </div>

          {/* Select Decision */}
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
              Select Decision
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation()
                  setIsDecisionDropdownOpen(!isDecisionDropdownOpen)
                }}
                className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                <span>{selectedDecision ? selectedDecision.charAt(0).toUpperCase() + selectedDecision.slice(1) : "Select Decision"}</span>
                <ChevronDown className={`w-4 h-4 transition-transform ${isDecisionDropdownOpen ? "rotate-180" : ""}`} />
              </button>
              {isDecisionDropdownOpen && (
                <div
                  className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 overflow-hidden"
                  onClick={(e) => e.stopPropagation()}
                >
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedDecision("offense")
                      setIsDecisionDropdownOpen(false)
                    }}
                    className="w-full px-4 py-3 text-left text-sm transition-colors"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      backgroundColor: selectedDecision === "offense" ? "#0F173E" : "transparent",
                      color: selectedDecision === "offense" ? "#FFFFFF" : "#000000",
                    }}
                    onMouseEnter={(e) => {
                      if (selectedDecision !== "offense") {
                        e.currentTarget.style.backgroundColor = "#F3F4F6"
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (selectedDecision !== "offense") {
                        e.currentTarget.style.backgroundColor = "transparent"
                      }
                    }}
                  >
                    Offense
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedDecision("defense")
                      setIsDecisionDropdownOpen(false)
                    }}
                    className="w-full px-4 py-3 text-left text-sm transition-colors"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      backgroundColor: selectedDecision === "defense" ? "#0F173E" : "transparent",
                      color: selectedDecision === "defense" ? "#FFFFFF" : "#000000",
                    }}
                    onMouseEnter={(e) => {
                      if (selectedDecision !== "defense") {
                        e.currentTarget.style.backgroundColor = "#F3F4F6"
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (selectedDecision !== "defense") {
                        e.currentTarget.style.backgroundColor = "transparent"
                      }
                    }}
                  >
                    Defense
                  </button>
                </div>
              )}
            </div>
          </div>

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
              onClick={handleStartMatch}
              disabled={!selectedTeam || !selectedDecision}
              className="flex-1 px-4 py-3 rounded-lg text-sm font-medium text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              style={{
                backgroundColor: "#0F173E",
                fontFamily: "Lato, sans-serif",
              }}
            >
              Start Match
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

