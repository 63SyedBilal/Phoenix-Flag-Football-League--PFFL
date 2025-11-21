"use client"

import type React from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export interface PaymentCardProps {
  paymentId: string
  amount: number
  date: string
  method: "stripe" | "paypal" | "cash"
  status: "paid" | "pending" | "failed"
  leagueName?: string
  leagueInfo?: {
    format: string
    startDate: string
    endDate: string
    fee: number
  }
  onViewReceipt?: () => void
  onViewDetails?: () => void
}

export const PaymentCard: React.FC<PaymentCardProps> = ({
  paymentId,
  amount,
  date,
  method,
  status,
  leagueName,
  leagueInfo,
  onViewReceipt,
  onViewDetails,
}) => {
  const statusStyles = {
    paid: "bg-green-100 text-green-700",
    pending: "bg-yellow-100 text-yellow-700",
    failed: "bg-red-100 text-red-700",
  }

  const methodDisplay = {
    stripe: "Stripe",
    paypal: "PayPal",
    cash: "Cash",
  }

  return (
    <Card className="p-4 mb-4">
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <h3 className="font-semibold text-foreground">{paymentId}</h3>
          <p className="text-sm text-muted-foreground">Amount: ${amount}</p>
        </div>
        <span className={`text-xs font-medium px-3 py-1 rounded-full whitespace-nowrap ${statusStyles[status]}`}>
          {status.charAt(0).toUpperCase() + status.slice(1)}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-4 text-sm mb-4 pb-4 border-b border-border">
        <div>
          <p className="text-muted-foreground">Method</p>
          <p className="font-medium">{methodDisplay[method]}</p>
        </div>
        <div className="text-right">
          <p className="text-muted-foreground">Date</p>
          <p className="font-medium">{date}</p>
        </div>
      </div>

      {leagueName && (
        <div className="mb-4">
          <p className="text-sm font-medium text-foreground mb-2">League Details</p>
          <p className="text-sm font-semibold text-muted-foreground">{leagueName}</p>
        </div>
      )}

      {leagueInfo && (
        <div className="bg-muted/50 p-3 rounded-lg mb-4 text-sm">
          <div className="grid grid-cols-2 gap-2">
            <div>Format: {leagueInfo.format}</div>
            <div>Fee: ${leagueInfo.fee}</div>
            <div>Start: {leagueInfo.startDate}</div>
            <div>End: {leagueInfo.endDate}</div>
          </div>
        </div>
      )}

      <div className="flex gap-2 pt-3 border-t border-border">
        {onViewDetails && (
          <Button onClick={onViewDetails} variant="outline" className="flex-1 bg-transparent">
            View Details
          </Button>
        )}
        {onViewReceipt && (
          <Button onClick={onViewReceipt} className="flex-1">
            View Receipt
          </Button>
        )}
      </div>
    </Card>
  )
}
