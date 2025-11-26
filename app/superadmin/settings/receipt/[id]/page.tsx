"use client"

import { useRouter, useParams } from "next/navigation"
import Image from "next/image"
import ReceiptCard from "@/components/cards/receipt-card"

const mockReceipts = [
  {
    id: "1",
    recordId: "Record #01",
    transactionId: "STRP-98234723",
    date: "09 Dec 2025",
    email: "alexmorgan@pffl.com",
    playerName: "Alex Morgan",
    teamName: "Red Cobras",
    refundReason: "Others",
    leagueName: "Phoenix Winter 2025",
    totalAmount: "$25",
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
    recordId: "Record #01",
    transactionId: "STRP-98234724",
    date: "08 Dec 2025",
    email: "johndoe@pffl.com",
    playerName: "John Doe",
    teamName: "Blue Eagles",
    refundReason: undefined,
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
    recordId: "Record #01",
    transactionId: "STRP-98234725",
    date: "07 Dec 2025",
    email: "janesmith@pffl.com",
    playerName: "Jane Smith",
    teamName: "Green Tigers",
    refundReason: undefined,
    leagueName: "Champions Cup 2025",
    totalAmount: "$250",
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
]

export default function ReceiptPage() {
  const router = useRouter()
  const params = useParams()
  const receiptId = params?.id as string

  // Find the receipt by ID, or use the first one as default
  const receipt = mockReceipts.find((r) => r.id === receiptId) || mockReceipts[0]

  return (
    <div className="flex flex-col gap-3">
      {/* Back Arrow */}
      <div className="mb-2">
        <button
          onClick={() => router.back()}
          className="w-[50px] h-[50px] p-[10px] rounded-full bg-[#F2F2F2] hover:bg-gray-200 transition-colors flex items-center justify-center flex-shrink-0 mb-2"
        >
          <Image src="/assets/image/Back arrow.svg" alt="Back" width={24} height={24} />
        </button>
      </div>

      {/* Header */}
      <div className="mb-4">
        <h1 className="text-3xl font-bold text-foreground">Payment Receipt</h1>
        <p className="text-muted-foreground mt-1">Transaction details for your league payment</p>
      </div>

      {/* Receipt Cards */}
      <div className="space-y-3">
        {mockReceipts.map((receiptItem) => (
          <ReceiptCard
            key={receiptItem.id}
            id={receiptItem.id}
            recordId={receiptItem.recordId}
            transactionId={receiptItem.transactionId}
            date={receiptItem.date}
            email={receiptItem.email}
            playerName={receiptItem.playerName}
            teamName={receiptItem.teamName}
            refundReason={receiptItem.refundReason}
            leagueName={receiptItem.leagueName}
            totalAmount={receiptItem.totalAmount}
            method={receiptItem.method}
            status={receiptItem.status}
            leagueDetails={receiptItem.leagueDetails}
            onDownloadReceipt={() => console.log("Download receipt for", receiptItem.id)}
            onRefundPayment={() => console.log("Refund payment for", receiptItem.id)}
          />
        ))}
      </div>
    </div>
  )
}








