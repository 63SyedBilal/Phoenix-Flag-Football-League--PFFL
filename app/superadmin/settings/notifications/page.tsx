"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Search } from "lucide-react"
import Image from "next/image"
import PageHeader from "@/components/layout/page-header"
import NotificationCardPayment from "@/components/cards/notification-card-payment"

const mockNotifications = [
  {
    id: "1",
    title: "Payment Required",
    dueDate: "09 Dec 2025",
    message: "Your League Fee has not been paid. Please complete your payment to stay eligible for the upcoming league.",
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
    title: "Payment Required",
    dueDate: "10 Dec 2025",
    message: "Your League Fee has not been paid. Please complete your payment to stay eligible for the upcoming league.",
    leagueDetails: {
      name: "Champions Cup 2025",
      logo: "/placeholder-logo.png",
      format: "7v7",
      startDate: "15 December 2025",
      endDate: "28 February 2026",
      leagueFee: "$300",
      status: "active" as const,
    },
  },
  {
    id: "3",
    title: "Payment Required",
    dueDate: "11 Dec 2025",
    message: "Your League Fee has not been paid. Please complete your payment to stay eligible for the upcoming league.",
    leagueDetails: {
      name: "Summer League 2026",
      logo: "/placeholder-logo.png",
      format: "5v5",
      startDate: "01 January 2026",
      endDate: "31 March 2026",
      leagueFee: "$200",
      status: "pending" as const,
    },
  },
]

const filterOptions = ["All Notifications", "Payment Required", "League Updates", "Team Updates"]

export default function SuperAdminNotificationsPage() {
  const router = useRouter()
  const [activeFilter, setActiveFilter] = useState("All Notifications")
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedItem, setSelectedItem] = useState("Select Item")

  const handlePayNow = (id: string) => {
    router.push(`/superadmin/settings/payment/${id}`)
  }

  return (
    <div className="flex flex-col gap-3">
      <PageHeader
        title="Notifications"
        subtitle="View and manage your notifications"
        showBell={false}
      />

      {/* Search Bar and Dropdown in Same Row */}
      <div className="flex items-center gap-3">
        <div className="relative flex-[4]">
          <input
            type="text"
            placeholder="Search notifications..."
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

      {/* Notification Cards */}
      <div className="space-y-3">
        {mockNotifications.map((notification) => (
          <NotificationCardPayment
            key={notification.id}
            id={notification.id}
            title={notification.title}
            dueDate={notification.dueDate}
            message={notification.message}
            leagueDetails={notification.leagueDetails}
            onPayNow={() => handlePayNow(notification.id)}
          />
        ))}
      </div>
    </div>
  )
}


