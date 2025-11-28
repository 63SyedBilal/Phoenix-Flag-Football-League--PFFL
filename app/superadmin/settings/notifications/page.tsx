"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Search } from "lucide-react"
import Image from "next/image"
import PageHeader from "@/components/layout/page-header"
import NotificationCardPayment from "@/components/cards/notification-card-payment"
import LoadingSpinner from "@/components/ui/loading-spinner"

const filterOptions = ["All Notifications", "Payment Required", "League Updates", "Team Updates"]

interface Payment {
  _id: string
  amount: number
  status: "paid" | "unpaid"
  leagueId: {
    _id: string
    leagueName: string
    logo: string
    format: string
    startDate: string
    endDate: string
    status: "active" | "pending"
  }
  userId: {
    _id: string
    firstName: string
    lastName: string
    email: string
  }
  createdAt: string
  updatedAt: string
}

export default function SuperAdminNotificationsPage() {
  const router = useRouter()
  const [activeFilter, setActiveFilter] = useState("All Notifications")
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedItem, setSelectedItem] = useState("Select Item")
  const [unpaidPayments, setUnpaidPayments] = useState<Payment[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState("")

  // Fetch unpaid payments
  useEffect(() => {
    const fetchUnpaidPayments = async () => {
      try {
        setIsLoading(true)
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view notifications")
          setIsLoading(false)
          return
        }

        // Fetch all unpaid payments for superadmin
        const response = await fetch("/api/superadmin/payments/unpaid", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}))
          throw new Error(errorData.error || "Failed to fetch payments")
        }

        const data = await response.json()
        if (data.success) {
          setUnpaidPayments(data.data || [])
        }
      } catch (err: any) {
        console.error("Error fetching unpaid payments:", err)
        setError(err.message || "Failed to fetch payments")
      } finally {
        setIsLoading(false)
      }
    }

    fetchUnpaidPayments()
  }, [])

  const handlePayNow = (id: string) => {
    router.push(`/superadmin/settings/payment/${id}`)
  }

  // Filter payments based on active filter and search
  const filteredPayments = unpaidPayments.filter((payment) => {
    // Filter by active filter
    if (activeFilter === "Payment Required") {
      // Already filtered to unpaid payments
    } else if (activeFilter !== "All Notifications") {
      return false
    }

    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      return (
        (payment.leagueId?.leagueName && payment.leagueId.leagueName.toLowerCase().includes(query)) ||
        (payment.userId?.firstName && payment.userId.firstName.toLowerCase().includes(query)) ||
        (payment.userId?.lastName && payment.userId.lastName.toLowerCase().includes(query)) ||
        (payment.userId?.email && payment.userId.email.toLowerCase().includes(query))
      )
    }

    return true
  })

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
      {isLoading ? (
        <LoadingSpinner fullScreen text="Loading notifications..." />
      ) : error ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ fontFamily: "Lato, sans-serif", color: "#EF4444" }}>{error}</p>
        </div>
      ) : filteredPayments.length === 0 ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>No notifications found</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filteredPayments.map((payment) => {
            const dueDate = payment.createdAt 
              ? new Date(payment.createdAt).toLocaleDateString("en-US", { day: "numeric", month: "short", year: "numeric" })
              : new Date().toLocaleDateString("en-US", { day: "numeric", month: "short", year: "numeric" })
            
            return (
              <NotificationCardPayment
                key={payment._id}
                id={payment._id}
                title="Payment Required"
                dueDate={dueDate}
                message={`${payment.userId?.firstName || ""} ${payment.userId?.lastName || ""}`.trim() 
                  ? `Payment required for ${payment.userId.firstName} ${payment.userId.lastName} - ${payment.leagueId?.leagueName || "League"}. Please complete the payment.`
                  : `Your League Fee has not been paid. Please complete your payment to stay eligible for the upcoming league.`}
                leagueDetails={{
                  name: payment.leagueId?.leagueName || "Unknown League",
                  logo: payment.leagueId?.logo || "/placeholder-logo.png",
                  format: payment.leagueId?.format || "5v5",
                  startDate: payment.leagueId?.startDate 
                    ? new Date(payment.leagueId.startDate).toLocaleDateString("en-US", { day: "numeric", month: "long", year: "numeric" })
                    : "N/A",
                  endDate: payment.leagueId?.endDate
                    ? new Date(payment.leagueId.endDate).toLocaleDateString("en-US", { day: "numeric", month: "long", year: "numeric" })
                    : "N/A",
                  leagueFee: `$${payment.amount || 0}`,
                  status: payment.leagueId?.status === "active" ? "active" : "pending",
                }}
                onPayNow={() => handlePayNow(payment._id)}
              />
            )
          })}
        </div>
      )}
    </div>
  )
}





