"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Search } from "lucide-react"
import Image from "next/image"
import PageHeader from "@/components/layout/page-header"
import PaymentHistoryCard from "@/components/cards/payment-history-card"

const mockPayments = [
  {
    id: "1",
    recordId: "Record #01",
    date: "09 Dec 2025",
    playerName: "Alex Morgan",
    teamName: "Red Cobras",
    leagueName: "Phoenix Winter 2025",
    amount: "$250",
    method: "Stripe",
    status: "Paid" as const,
    leagueDetails: {
      name: "Phoenix Winter 2025",
      logo: "/placeholder-logo.png",
      format: "5v5",
      startDate: "10 December 2025",
      endDate: "25 February 2026",
      leagueFee: "$250",
      status: "active" as const,
    },
  },
  {
    id: "2",
    recordId: "Record #02",
    date: "08 Dec 2025",
    playerName: "John Doe",
    teamName: "Blue Eagles",
    leagueName: "Phoenix Winter 2025",
    amount: "$250",
    method: "Stripe",
    status: "Paid" as const,
    leagueDetails: {
      name: "Phoenix Winter 2025",
      logo: "/placeholder-logo.png",
      format: "5v5",
      startDate: "10 December 2025",
      endDate: "25 February 2026",
      leagueFee: "$250",
      status: "active" as const,
    },
  },
  {
    id: "3",
    recordId: "Record #03",
    date: "07 Dec 2025",
    playerName: "Jane Smith",
    teamName: "Green Tigers",
    leagueName: "Champions Cup 2025",
    amount: "$250",
    method: "PayPal",
    status: "Pending" as const,
    leagueDetails: {
      name: "Champions Cup 2025",
      logo: "/placeholder-logo.png",
      format: "7v7",
      startDate: "10 December 2025",
      endDate: "25 February 2026",
      leagueFee: "$250",
      status: "active" as const,
    },
  },
  {
    id: "4",
    recordId: "Record #04",
    date: "06 Dec 2025",
    playerName: "Mike Johnson",
    teamName: "Yellow Lions",
    leagueName: "Phoenix Winter 2025",
    amount: "$250",
    method: "Stripe",
    status: "Refunded" as const,
    leagueDetails: {
      name: "Phoenix Winter 2025",
      logo: "/placeholder-logo.png",
      format: "5v5",
      startDate: "10 December 2025",
      endDate: "25 February 2026",
      leagueFee: "$250",
      status: "active" as const,
    },
  },
]

const filterOptions = ["Completed Payments", "Pending Payments", "Refunds Payments"]

export default function PaymentHistoryPage() {
  const router = useRouter()
  const [activeFilter, setActiveFilter] = useState("Completed Payments")
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedItem, setSelectedItem] = useState("Select Item")

  return (
    <div className="flex flex-col gap-3">
      <PageHeader
        title="Payment History"
        subtitle="Track all your league payment and receipts"
        showBell={false}
      />

      {/* Search Bar and Dropdown in Same Row */}
      <div className="flex items-center gap-3">
        <div className="relative flex-[4]">
          <input
            type="text"
            placeholder="Search users by name or email..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-[46.33px] px-4 rounded-xl border pr-10"
            style={{
              border: "0.67px solid #E5E7EB",
              borderTop: "0.67px solid #E5E7EB",
              borderRadius: "14px",
              backgroundColor: "#FFFFFF",
            }}
          />
          <Search className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
        </div>
        <div className="relative flex-[1]">
          <select
            value={selectedItem}
            onChange={(e) => setSelectedItem(e.target.value)}
            className="w-full h-[46.33px] px-4 pr-10 rounded-xl border-[0.67px] border-[#E5E7EB] bg-white appearance-none cursor-pointer"
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            <option>Select Item</option>
            <option>Option 1</option>
            <option>Option 2</option>
            <option>Option 3</option>
          </select>
          <Image
            src="/assets/image/arrow-down.svg"
            alt="dropdown"
            width={16}
            height={16}
            className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none"
          />
        </div>
      </div>

      {/* Filter Buttons */}
      <div className="flex items-center gap-2 flex-wrap">
        {filterOptions.map((filter) => (
          <button
            key={filter}
            onClick={() => setActiveFilter(filter)}
            className="px-3 font-normal transition-colors whitespace-nowrap text-sm"
            style={{
              minWidth: "70px",
              paddingTop: "8px",
              paddingBottom: "8px",
              borderRadius: "8px",
              fontFamily: "Lato, sans-serif",
              fontWeight: 400,
              fontSize: "14px",
              lineHeight: "100%",
              backgroundColor: activeFilter === filter ? "#3B82F6" : "#FFFFFF",
              color: activeFilter === filter ? "#FFFFFF" : "#000000",
              border: activeFilter === filter ? "none" : "0.67px solid rgba(0, 0, 0, 0.12)",
            }}
          >
            {filter}
          </button>
        ))}
      </div>

      {/* Payment History Cards */}
      <div className="space-y-3">
        {mockPayments.map((payment) => (
          <PaymentHistoryCard
            key={payment.id}
            id={payment.id}
            recordId={payment.recordId}
            date={payment.date}
            playerName={payment.playerName}
            teamName={payment.teamName}
            leagueName={payment.leagueName}
            amount={payment.amount}
            method={payment.method}
            status={payment.status}
            leagueDetails={payment.leagueDetails}
          />
        ))}
      </div>
    </div>
  )
}



