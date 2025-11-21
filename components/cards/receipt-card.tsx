"use client"

import type React from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export interface ReceiptCardProps {
  paymentId: string
  date: string
  amount: number
  method: string
  leagueName: string
  leagueFormat: string
  leagueStartDate: string
  leagueEndDate: string
  status: "paid" | "pending" | "failed"
  transactionId?: string
  onDownload?: () => void
  onPrint?: () => void
}

export const ReceiptCard: React.FC<ReceiptCardProps> = ({
  paymentId,
  date,
  amount,
  method,
  leagueName,
  leagueFormat,
  leagueStartDate,
  leagueEndDate,
  status,
  transactionId,
  onDownload,
  onPrint,
}) => {
  return (
    <Card className="p-6 max-w-lg mx-auto">
      <div className="text-center mb-6 pb-6 border-b border-border">
        <h2 className="text-2xl font-bold text-foreground">Receipt</h2>
        <p className="text-sm text-muted-foreground mt-1">Invoice #{paymentId}</p>
      </div>

      <div className="space-y-4 mb-6">
        <div className="flex justify-between">
          <span className="text-muted-foreground">Date</span>
          <span className="font-medium text-foreground">{date}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-muted-foreground">Payment Method</span>
          <span className="font-medium text-foreground">{method}</span>
        </div>
        {transactionId && (
          <div className="flex justify-between">
            <span className="text-muted-foreground">Transaction ID</span>
            <span className="font-medium text-foreground text-xs">{transactionId}</span>
          </div>
        )}
        <div className="flex justify-between pt-4 border-t border-border">
          <span className="text-muted-foreground">Status</span>
          <span className={`font-medium ${status === "paid" ? "text-green-600" : "text-yellow-600"}`}>
            {status.toUpperCase()}
          </span>
        </div>
      </div>

      <div className="bg-muted/50 p-4 rounded-lg mb-6">
        <h3 className="font-semibold text-foreground mb-3">{leagueName}</h3>
        <div className="space-y-2 text-sm text-muted-foreground">
          <div className="flex justify-between">
            <span>Format:</span>
            <span className="font-medium text-foreground">{leagueFormat}</span>
          </div>
          <div className="flex justify-between">
            <span>Start Date:</span>
            <span className="font-medium text-foreground">{leagueStartDate}</span>
          </div>
          <div className="flex justify-between">
            <span>End Date:</span>
            <span className="font-medium text-foreground">{leagueEndDate}</span>
          </div>
        </div>
      </div>

      <div className="border-t border-b border-border py-4 mb-6">
        <div className="flex justify-between items-center">
          <span className="text-lg text-muted-foreground">Total Amount</span>
          <span className="text-3xl font-bold text-foreground">${amount}</span>
        </div>
      </div>

      <div className="flex gap-2">
        {onDownload && (
          <Button onClick={onDownload} variant="outline" className="flex-1 bg-transparent">
            Download
          </Button>
        )}
        {onPrint && (
          <Button onClick={onPrint} className="flex-1">
            Print
          </Button>
        )}
      </div>
    </Card>
  )
}
