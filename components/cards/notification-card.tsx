"use client"

import type React from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export interface NotificationCardProps {
  type: "payment-required" | "invite" | "team-accepted" | "payment-confirmation"
  title: string
  description: string
  leagueInfo?: {
    name: string
    format: string
    startDate: string
    endDate: string
    leagueFee: string
  }
  date: string
  status?: "pending" | "active" | "completed"
  action?: {
    label: string
    onClick: () => void
  }
  actionSecondary?: {
    label: string
    onClick: () => void
  }
}

export const NotificationCard: React.FC<NotificationCardProps> = ({
  type,
  title,
  description,
  leagueInfo,
  date,
  status,
  action,
  actionSecondary,
}) => {
  return (
    <Card className="p-4 mb-4">
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <h3 className="font-semibold text-foreground">{title}</h3>
          <p className="text-sm text-muted-foreground mt-1">{description}</p>
        </div>
        <div className="text-xs font-medium bg-primary text-primary-foreground px-3 py-1 rounded-full ml-2 whitespace-nowrap">
          {date}
        </div>
      </div>

      {status && (
        <div className="mb-3 inline-block">
          <span
            className={`text-xs font-medium px-2 py-1 rounded-full ${
              status === "active"
                ? "bg-green-100 text-green-700"
                : status === "pending"
                  ? "bg-yellow-100 text-yellow-700"
                  : "bg-gray-100 text-gray-700"
            }`}
          >
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </span>
        </div>
      )}

      {leagueInfo && (
        <div className="bg-muted/50 p-3 rounded-lg mb-4 text-sm">
          <div className="flex items-center gap-2 mb-2">
            <span className="font-semibold">🏆 {leagueInfo.name}</span>
          </div>
          <div className="grid grid-cols-2 gap-2 text-muted-foreground">
            <div>Format: {leagueInfo.format}</div>
            <div>League Fee: {leagueInfo.leagueFee}</div>
            <div>Start: {leagueInfo.startDate}</div>
            <div>End: {leagueInfo.endDate}</div>
          </div>
        </div>
      )}

      <div className="flex gap-2 pt-3 border-t border-border">
        {action && (
          <Button onClick={action.onClick} className="flex-1">
            {action.label}
          </Button>
        )}
        {actionSecondary && (
          <Button onClick={actionSecondary.onClick} variant="outline" className="flex-1 bg-transparent">
            {actionSecondary.label}
          </Button>
        )}
      </div>
    </Card>
  )
}
