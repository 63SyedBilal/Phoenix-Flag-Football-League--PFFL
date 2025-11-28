"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Search } from "lucide-react"
import Image from "next/image"
import PaymentHistoryCard from "@/components/cards/payment-history-card"
import LoadingSpinner from "@/components/ui/loading-spinner"

const filterOptions = ["All Payments", "Completed Payments", "Pending Payments"]

interface PaymentData {
  _id: string
  amount: number
  status: "paid" | "unpaid"
  transactionId?: string
  paymentMethod?: "stripe" | "paypal"
  teamName?: string
  playerName?: string
  captainName?: string
  freeAgentName?: string
  createdAt: string
  updatedAt: string
  userId: {
    _id: string
    firstName: string
    lastName: string
    email: string
    role: string
  }
  leagueId: {
    _id: string
    leagueName: string
    logo?: string
    format: string
    startDate: string
    endDate: string
    status: string
  }
}

export default function PfflPaymentHistoryPage() {
  const router = useRouter()
  const [activeFilter, setActiveFilter] = useState("All Payments")
  const [searchQuery, setSearchQuery] = useState("")
  const [payments, setPayments] = useState<PaymentData[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchPayments = async () => {
      try {
        setIsLoading(true)
        setError(null)

        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view payment history")
          setIsLoading(false)
          return
        }

        // Determine status filter
        let statusParam = "all"
        if (activeFilter === "Completed Payments") {
          statusParam = "paid"
        } else if (activeFilter === "Pending Payments") {
          statusParam = "unpaid"
        }

        const response = await fetch(`/api/payments/all?status=${statusParam}`, {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || "Failed to fetch payments")
        }

        const data = await response.json()
        if (data.success && data.data) {
          setPayments(data.data)
        } else {
          setPayments([])
        }
      } catch (err: any) {
        console.error("Error fetching payments:", err)
        setError(err.message || "Failed to load payment history")
        setPayments([])
      } finally {
        setIsLoading(false)
      }
    }

    fetchPayments()
  }, [activeFilter])

  // Format date helper
  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    const day = date.getDate()
    const month = date.toLocaleString("en-US", { month: "short" })
    const year = date.getFullYear()
    return `${day} ${month} ${year}`
  }

  // Format date for league details
  const formatLeagueDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("en-US", {
      day: "numeric",
      month: "long",
      year: "numeric",
    })
  }

  // Map payment data to card format
  const mapPaymentToCard = (payment: PaymentData, index: number) => {
    const userName = payment.playerName || 
                    payment.captainName || 
                    payment.freeAgentName || 
                    `${payment.userId.firstName} ${payment.userId.lastName}`.trim() ||
                    payment.userId.email

    const status = payment.status === "paid" ? "Paid" as const : "Pending" as const
    const paymentMethod = payment.paymentMethod 
      ? payment.paymentMethod.charAt(0).toUpperCase() + payment.paymentMethod.slice(1)
      : "N/A"

    return {
      id: payment._id,
      recordId: `Record #${String(index + 1).padStart(2, "0")}`,
      date: formatDate(payment.createdAt),
      playerName: userName,
      teamName: payment.teamName || "N/A",
      leagueName: payment.leagueId.leagueName,
      amount: `$${payment.amount.toFixed(2)}`,
      method: paymentMethod,
      status,
      leagueDetails: {
        name: payment.leagueId.leagueName,
        logo: payment.leagueId.logo || "/placeholder-logo.png",
        format: payment.leagueId.format || "N/A",
        startDate: formatLeagueDate(payment.leagueId.startDate),
        endDate: formatLeagueDate(payment.leagueId.endDate),
        leagueFee: `$${payment.amount.toFixed(2)}`,
        status: payment.leagueId.status === "active" ? "active" as const : "pending" as const,
      },
    }
  }

  // Filter payments by search query
  const filteredPayments = payments.filter((payment) => {
    if (!searchQuery.trim()) return true

    const query = searchQuery.toLowerCase()
    const leagueName = payment.leagueId.leagueName.toLowerCase()
    const userName = (
      payment.playerName || 
      payment.captainName || 
      payment.freeAgentName || 
      `${payment.userId.firstName} ${payment.userId.lastName}`.trim() ||
      payment.userId.email
    ).toLowerCase()
    const teamName = (payment.teamName || "").toLowerCase()

    return (
      leagueName.includes(query) ||
      userName.includes(query) ||
      teamName.includes(query)
    )
  })

  if (isLoading) {
    return (
      <div className="flex flex-col gap-3">
        <LoadingSpinner fullScreen text="Loading payment history..." />
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex flex-col gap-3">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md">
          <p>{error}</p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-3">
      {/* Back Arrow */}
      <button
        onClick={() => router.back()}
        className="w-[50px] h-[50px] p-[10px] rounded-full bg-[#F2F2F2] hover:bg-gray-200 transition-colors flex items-center justify-center flex-shrink-0 mb-2"
      >
        <Image src="/assets/image/Back arrow.svg" alt="Back" width={24} height={24} />
      </button>

      {/* Header */}
      <div className="mb-4">
        <h1 className="text-3xl font-bold text-foreground">Payment History</h1>
        <p className="text-muted-foreground mt-1">Track all your league payment and receipts</p>
      </div>

      {/* Search Bar */}
      <div className="flex items-center gap-3">
        <div className="relative flex-[4]">
          <input
            type="text"
            placeholder="Search by league name, player name, or team..."
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
      {filteredPayments.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-12">
          <p className="text-muted-foreground text-lg">
            {searchQuery ? "No payments found matching your search" : "No payments found"}
          </p>
          {searchQuery && (
            <button
              onClick={() => setSearchQuery("")}
              className="mt-4 text-blue-600 hover:underline"
            >
              Clear search
            </button>
          )}
        </div>
      ) : (
        <div className="space-y-3">
          {filteredPayments.map((payment, index) => {
            const cardData = mapPaymentToCard(payment, index)
            return (
              <PaymentHistoryCard
                key={payment._id}
                id={cardData.id}
                recordId={cardData.recordId}
                date={cardData.date}
                playerName={cardData.playerName}
                teamName={cardData.teamName}
                leagueName={cardData.leagueName}
                amount={cardData.amount}
                method={cardData.method}
                status={cardData.status}
                leagueDetails={cardData.leagueDetails}
                onViewReceipt={() => router.push(`/pffl/settings/receipt/${payment._id}`)}
              />
            )
          })}
        </div>
      )}
    </div>
  )
}
