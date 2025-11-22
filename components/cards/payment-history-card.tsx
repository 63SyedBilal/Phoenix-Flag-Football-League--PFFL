"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { ChevronDown, ChevronUp } from "lucide-react"
import Image from "next/image"

interface PaymentHistoryCardProps {
  id: string
  recordId: string
  date: string
  playerName: string
  teamName: string
  leagueName: string
  amount: string
  method: string
  status: "Paid" | "Pending" | "Refunded"
  leagueDetails?: {
    name: string
    logo: string
    format: string
    startDate: string
    endDate: string
    leagueFee: string
    status: "active" | "pending"
  }
  onViewReceipt?: () => void
}

export default function PaymentHistoryCard({
  id,
  recordId,
  date,
  playerName,
  teamName,
  leagueName,
  amount,
  method,
  status,
  leagueDetails,
  onViewReceipt,
}: PaymentHistoryCardProps) {
  const router = useRouter()
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div className="bg-white border-[0.67px] border-[#E5E7EB] border-t-[0.67px] border-t-[#E5E7EB] rounded-[14px] p-3 w-full relative shadow-[0px_1px_2px_-1px_rgba(0,0,0,0.1),0px_1px_3px_0px_rgba(0,0,0,0.1)]">
      {/* Record ID and Date */}
      <div className="flex items-start justify-between mb-4">
        <h2 className="font-bold  text-[22px] text-[#0F173E]">
          {recordId}
        </h2>
        <span
          className="px-3 py-2 rounded-full text-[12px]  text-white"
          style={{ backgroundColor: "#0F173E" }}
        >
          {date}
        </span>
      </div>

      {/* Payment Details */}
      <div className="flex items-start justify-between gap-4 mb-2">
        {/* Left Column */}
        <div className="flex flex-col gap-1">
          <p className="font-medium text-sm leading-[18px] text-[#6A7282]">
            Player: {playerName}
          </p>
          <p className="font-medium text-sm leading-[18px] text-[#6A7282]">
            Team: {teamName}
          </p>
        </div>
        
        {/* Middle Column */}
        <div className="flex flex-col gap-1">
          <p className="font-medium text-sm leading-[18px] text-[#6A7282]">
            League: {leagueName}
          </p>
          <p className="font-medium text-sm leading-[18px] text-[#6A7282]">
            Amount: {amount}
          </p>
        </div>
        
        {/* Right Column */}
        <div className="flex flex-col gap-1 items-end">
          <p className="font-medium text-sm leading-[18px] text-[#6A7282]">
            Method: {method}
          </p>
          <p className="font-medium text-sm leading-[18px]">
            <span className="text-[#6A7282]">Status: </span>
            <span
              style={{
                color: status === "Paid" ? "#3B82F6" : status === "Pending" ? "#F59E0B" : "#EF4444",
              }}
            >
              {status}
            </span>
          </p>
        </div>
      </div>

      {/* View League Details */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full flex items-center justify-between mb-4 py-2 hover:bg-gray-50 rounded transition-colors"
      >
        <span className="text-sm text-muted-foreground">View League Details</span>
        {isExpanded ? (
          <ChevronUp className="w-4 h-4 text-muted-foreground" />
        ) : (
          <ChevronDown className="w-4 h-4 text-muted-foreground" />
        )}
      </button>

      {/* Expanded League Details */}
      {isExpanded && leagueDetails && (
        <div className="mb-4 p-4 bg-gray-50 rounded-xl border border-[#E5E7EB]">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 overflow-hidden border-2 border-dashed border-gray-300">
              <Image
                src={leagueDetails.logo}
                alt={leagueDetails.name}
                width={48}
                height={48}
                className="w-12 h-12 rounded-full object-cover"
              />
            </div>
            <div className="flex-1">
              <h4 className="font-semibold text-foreground text-lg">{leagueDetails.name}</h4>
            </div>
            <button
              className="text-white text-sm font-medium flex-shrink-0 w-[77px] h-9 px-3 rounded-full"
              style={{
                backgroundColor: leagueDetails.status === "active" ? "#0F173E" : "#A855F7",
              }}
            >
              {leagueDetails.status === "active" ? "Active" : "Pending"}
            </button>
          </div>
          <div className="flex flex-col gap-2  w-full">
            <div className="flex justify-between w-full">
              <p className="text-sm text-[#111827]">Format: {leagueDetails.format}</p>
              <p className="text-sm text-[#111827]">League Fee: {leagueDetails.leagueFee}</p>
            </div>
            <div className="flex justify-between w-full">
              <p className="text-sm text-[#111827]">Start Date: {leagueDetails.startDate}</p>
              <p className="text-sm text-[#111827]">End Date: {leagueDetails.endDate}</p>
            </div>
          </div>
        </div>
      )}

      {/* View Receipt Button */}
      <button
        onClick={() => {
          if (onViewReceipt) {
            onViewReceipt()
          } else {
            router.push(`/superadmin/settings/receipt/${id}`)
          }
        }}
        className="w-full py-3 px-4 rounded-md text-sm font-medium text-white transition-colors"
        style={{ backgroundColor: "#0F173E" }}
      >
        View Receipt
      </button>
    </div>
  )
}

