"use client"

import { useRouter } from "next/navigation"
import Image from "next/image"
import ReceiptCard from "@/components/cards/receipt-card"

const mockPayments = [
  {
    id: "1",
    recordId: "Record #01",
    transactionId: "TXN-2025-001",
    date: "09 Dec 2025",
    email: "alex.morgan@example.com",
    playerName: "Alex Morgan",
    teamName: "Red Cobras",
    refundReason: null,
    leagueName: "Phoenix Winter 2025",
    totalAmount: "$250",
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
    transactionId: "TXN-2025-002",
    date: "08 Dec 2025",
    email: "john.doe@example.com",
    playerName: "John Doe",
    teamName: "Blue Eagles",
    refundReason: null,
    leagueName: "Phoenix Winter 2025",
    totalAmount: "$250",
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
    transactionId: "TXN-2025-003",
    date: "07 Dec 2025",
    email: "sarah.mitchell@example.com",
    playerName: "Sarah Mitchell",
    teamName: "Green Vipers",
    refundReason: null,
    leagueName: "Phoenix Winter 2025",
    totalAmount: "$250",
    method: "PayPal",
    status: "Pending" as const,
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

export default function PfflReceiptPage({ params }: { params: { id: string } }) {
  const router = useRouter()
  const { id } = params
  const payment = mockPayments.find((p) => p.id === id)

  if (!payment) {
    return <div className="text-center py-12">Payment not found.</div>
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
        <h1 className="text-3xl font-bold text-foreground">Payment Receipt</h1>
        <p className="text-muted-foreground mt-1">Details for your payment receipt.</p>
      </div>

      {/* Receipt Card */}
      <ReceiptCard
        id={payment.id}
        recordId={payment.recordId}
        transactionId={payment.transactionId}
        date={payment.date}
        email={payment.email}
        playerName={payment.playerName}
        teamName={payment.teamName}
        refundReason={payment.refundReason}
        leagueName={payment.leagueName}
        totalAmount={payment.totalAmount}
        method={payment.method}
        status={payment.status}
        leagueDetails={payment.leagueDetails}
        onDownloadReceipt={() => console.log("Download Receipt")}
        onRefundPayment={undefined}
      />
    </div>
  )
}





