"use client"

import { useState } from "react"
import Image from "next/image"
import { ChevronDown } from "lucide-react"

interface LeagueInvitationCardProps {
  id: string
  senderName: string
  leagueName: string
  leagueLogo?: string
  invitationType: "LEAGUE_REFEREE_INVITE" | "LEAGUE_STATKEEPER_INVITE" | "LEAGUE_TEAM_INVITE"
  teamName?: string
  date: string
  onAccept: (id: string) => void
  onDecline: (id: string) => void
  isProcessing?: boolean
}

export default function LeagueInvitationCard({
  id,
  senderName,
  leagueName,
  leagueLogo,
  invitationType,
  teamName,
  date,
  onAccept,
  onDecline,
  isProcessing = false,
}: LeagueInvitationCardProps) {
  const [showLeagueDetails, setShowLeagueDetails] = useState(false)

  const formatDate = (dateString: string) => {
    try {
      const date = new Date(dateString)
      const day = date.getDate().toString().padStart(2, "0")
      const month = date.toLocaleString("en-US", { month: "short" })
      const year = date.getFullYear()
      return `${day} ${month} ${year}`
    } catch {
      return dateString
    }
  }

  const getInvitationTitle = () => {
    switch (invitationType) {
      case "LEAGUE_REFEREE_INVITE":
        return "League Referee Invitation"
      case "LEAGUE_STATKEEPER_INVITE":
        return "League Stat Keeper Invitation"
      case "LEAGUE_TEAM_INVITE":
        return "League Team Invitation"
      default:
        return "League Invitation"
    }
  }

  const getInvitationMessage = () => {
    switch (invitationType) {
      case "LEAGUE_REFEREE_INVITE":
        return `You've been invited by <span class="font-semibold text-[#111827]">${senderName}</span> to be a referee for the league <span class="font-semibold text-[#111827]">${leagueName}</span>.`
      case "LEAGUE_STATKEEPER_INVITE":
        return `You've been invited by <span class="font-semibold text-[#111827]">${senderName}</span> to be a stat keeper for the league <span class="font-semibold text-[#111827]">${leagueName}</span>.`
      case "LEAGUE_TEAM_INVITE":
        return teamName
          ? `Your team <span class="font-semibold text-[#111827]">${teamName}</span> has been invited by <span class="font-semibold text-[#111827]">${senderName}</span> to participate in the league <span class="font-semibold text-[#111827]">${leagueName}</span>.`
          : `Your team has been invited by <span class="font-semibold text-[#111827]">${senderName}</span> to participate in the league <span class="font-semibold text-[#111827]">${leagueName}</span>.`
      default:
        return `You've been invited to join the league <span class="font-semibold text-[#111827]">${leagueName}</span>.`
    }
  }

  return (
    <div
      className="bg-white border-[0.67px] border-[#E5E7EB] rounded-[14px] p-5 w-full shadow-sm"
      style={{ fontFamily: "Lato, sans-serif" }}
    >
      {/* Header with Title and Date */}
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-bold text-[#111827]">{getInvitationTitle()}</h3>
        <span
          className="px-3 py-1 rounded-lg text-xs font-medium text-white"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          {formatDate(date)}
        </span>
      </div>

      {/* Message */}
      <p
        className="text-sm text-[#6B7280] mb-4"
        style={{ fontFamily: "Lato, sans-serif" }}
        dangerouslySetInnerHTML={{ __html: getInvitationMessage() }}
      />

      {/* Divider */}
      <div className="border-t border-[#E5E7EB] my-4"></div>

      {/* View League Details */}
      <button
        onClick={() => setShowLeagueDetails(!showLeagueDetails)}
        className="flex items-center justify-between w-full text-sm text-[#6B7280] hover:text-[#111827] transition-colors mb-4"
        style={{ fontFamily: "Lato, sans-serif" }}
      >
        <span>View League Details</span>
        <ChevronDown
          className={`w-4 h-4 transition-transform ${showLeagueDetails ? "rotate-180" : ""}`}
        />
      </button>

      {/* League Details (Expandable) */}
      {showLeagueDetails && (
        <div className="mb-4 p-3 bg-[#F9FAFB] rounded-lg">
          <div className="flex items-center gap-3 mb-3">
            {leagueLogo ? (
              <img
                src={leagueLogo}
                alt={leagueName}
                className="w-12 h-12 rounded-full object-cover"
              />
            ) : (
              <div className="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center">
                <span className="text-lg">🏈</span>
              </div>
            )}
            <div>
              <p className="font-semibold text-[#111827]">{leagueName}</p>
              <p className="text-xs text-[#6B7280]">League</p>
            </div>
          </div>
          <p className="text-xs text-[#6B7280]">
            {invitationType === "LEAGUE_REFEREE_INVITE" &&
              "Join as a referee to officiate matches in this league."}
            {invitationType === "LEAGUE_STATKEEPER_INVITE" &&
              "Join as a stat keeper to track and record match statistics."}
            {invitationType === "LEAGUE_TEAM_INVITE" &&
              "Join this league with your team to participate in matches and tournaments."}
          </p>
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => onDecline(id)}
          disabled={isProcessing}
          className="flex-1 px-4 py-3 rounded-full text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style={{
            backgroundColor: "#FFFFFF",
            border: "1px solid #000000",
            color: "#000000",
            fontFamily: "Lato, sans-serif",
          }}
        >
          Decline
        </button>
        <button
          onClick={() => onAccept(id)}
          disabled={isProcessing}
          className="flex-1 px-4 py-3 rounded-full text-sm font-medium text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          {isProcessing ? "Processing..." : "Accept Invite"}
        </button>
      </div>
    </div>
  )
}

