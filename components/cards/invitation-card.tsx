"use client"

import { useState } from "react"
import Image from "next/image"
import { ChevronDown } from "lucide-react"

interface InvitationCardProps {
  id: string
  senderName: string
  teamName: string
  teamImage?: string
  date: string
  onAccept: (id: string) => void
  onDecline: (id: string) => void
  isProcessing?: boolean
}

export default function InvitationCard({
  id,
  senderName,
  teamName,
  teamImage,
  date,
  onAccept,
  onDecline,
  isProcessing = false,
}: InvitationCardProps) {
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

  return (
    <div
      className="bg-white border-[0.67px] border-[#E5E7EB] rounded-[14px] p-5 w-full shadow-sm"
      style={{ fontFamily: "Lato, sans-serif" }}
    >
      {/* Header with Title and Date */}
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-bold text-[#111827]">Team Invitation Received</h3>
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
      <p className="text-sm text-[#6B7280] mb-4" style={{ fontFamily: "Lato, sans-serif" }}>
        You&apos;ve been invited by <span className="font-semibold text-[#111827]">{senderName}</span> to join the team{" "}
        <span className="font-semibold text-[#111827]">{teamName}</span> for the upcoming league.
      </p>

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
            {teamImage ? (
              <img
                src={teamImage}
                alt={teamName}
                className="w-12 h-12 rounded-full object-cover"
              />
            ) : (
              <div className="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center">
                <span className="text-lg">🏈</span>
              </div>
            )}
            <div>
              <p className="font-semibold text-[#111827]">{teamName}</p>
              <p className="text-xs text-[#6B7280]">Team</p>
            </div>
          </div>
          <p className="text-xs text-[#6B7280]">
            Join this team to participate in upcoming league matches and tournaments.
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


