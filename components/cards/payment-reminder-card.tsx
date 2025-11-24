"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { ChevronDown, ChevronUp, AlertTriangle } from "lucide-react"
import Image from "next/image"

interface PaymentReminderCardProps {
  id: string
  amount: string
  leagueDetails: {
    name: string
    logo: string
    format: string
    startDate: string
    endDate: string
    leagueFee: string
    status: "active" | "pending"
  }
  onPayNow?: () => void
}

export default function PaymentReminderCard({
  id,
  amount,
  leagueDetails,
  onPayNow,
}: PaymentReminderCardProps) {
  const router = useRouter()
  const [isExpanded, setIsExpanded] = useState(false)

  const handlePayNow = () => {
    if (onPayNow) {
      onPayNow()
    } else {
      router.push(`/pffl/captain/settings/payment/${id}`)
    }
  }

  return (
    <div className="bg-white border-[0.67px] border-[#E5E7EB] border-t-[0.67px] border-t-[#E5E7EB] rounded-[14px] p-3 w-full relative shadow-[0px_1px_2px_-1px_rgba(0,0,0,0.1),0px_1px_3px_0px_rgba(0,0,0,0.1)]">
      {/* Payment Reminder Header */}
      <div className="relative mb-4">
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-bold text-[22px] text-[#0F173E]">
            Payment Reminder
          </h2>
          <div className="w-6 h-6 flex items-center justify-center text-red-500">
            <AlertTriangle className="w-6 h-6" />
          </div>
        </div>
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="text-3xl font-bold text-[#0F173E] mb-1">{amount}</div>
            <div className="text-sm text-muted-foreground">League Fee Due</div>
          </div>
          <button
            onClick={handlePayNow}
            className="px-4 py-2 rounded-md text-sm font-medium text-white transition-colors"
            style={{ backgroundColor: "#0F173E" }}
          >
            Pay Now
          </button>
        </div>
      </div>

      {/* Border before View League Details */}
      <div
        className="w-full mb-1"
        style={{
          height: "0px",
          borderTop: "1px solid rgba(0, 0, 0, 0.12)",
        }}
      />

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
          <div className="flex flex-col gap-2 w-full">
            <div className="flex justify-between w-full">
              <p className="text-sm text-[#111827]">Format: {leagueDetails.format}</p>
            </div>
            <div className="flex justify-between w-full">
              <p className="text-sm text-[#111827]">Start Date: {leagueDetails.startDate}</p>
              <p className="text-sm text-[#111827]">End Date: {leagueDetails.endDate}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

