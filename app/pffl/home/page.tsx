"use client"

import { useRouter } from "next/navigation"
import PaymentReminderCard from "@/components/cards/payment-reminder-card"
import PageHeader from "@/components/layout/page-header"

const mockPaymentReminder = {
  id: "1",
  amount: "$250",
  leagueDetails: {
    name: "Champions Cup 2025",
    logo: "/placeholder-logo.png",
    format: "5v5",
    startDate: "10 December 2025",
    endDate: "25 February 2026",
    leagueFee: "$250",
    status: "active" as const,
  },
}

export default function PfflHomePage() {
  const router = useRouter()

  return (
    <div className="flex flex-col gap-3">
      <PageHeader
        title="Welcome,"
        subtitle="Phoenix Flag Football League"
      />

      {/* Payment Reminder Card */}
      <div className="space-y-3">
        <PaymentReminderCard
          id={mockPaymentReminder.id}
          amount={mockPaymentReminder.amount}
          leagueDetails={mockPaymentReminder.leagueDetails}
          onPayNow={() => router.push(`/pffl/settings/payment/${mockPaymentReminder.id}`)}
        />
      </div>
    </div>
  )
}

