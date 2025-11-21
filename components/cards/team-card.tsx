"use client"

import type React from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export interface TeamCardProps {
  id: string
  name: string
  captain: string
  captainImage?: string
  logo?: string
  totalPlayers: number
  format: string
  status?: "active" | "pending" | "invited"
  onViewDetails?: () => void
  onInvite?: () => void
  onRemove?: () => void
  onAccept?: () => void
  onDecline?: () => void
}

export const TeamCard: React.FC<TeamCardProps> = ({
  id,
  name,
  captain,
  captainImage,
  logo,
  totalPlayers,
  format,
  status,
  onViewDetails,
  onInvite,
  onRemove,
  onAccept,
  onDecline,
}) => {
  return (
    <Card className="p-4">
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3 flex-1">
          {logo && <img src={logo || "/placeholder.svg"} alt={name} className="w-10 h-10 rounded-lg" />}
          <div className="flex-1">
            <h3 className="font-semibold text-foreground">{name}</h3>
            <p className="text-xs text-muted-foreground">Captain: {captain}</p>
          </div>
        </div>
        {status && (
          <span
            className={`text-xs font-medium px-2 py-1 rounded-full ${
              status === "active"
                ? "bg-green-100 text-green-700"
                : status === "pending"
                  ? "bg-yellow-100 text-yellow-700"
                  : "bg-blue-100 text-blue-700"
            }`}
          >
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </span>
        )}
      </div>

      <div className="bg-muted/50 p-3 rounded-lg mb-4 text-sm">
        <div className="flex justify-between">
          <span className="text-muted-foreground">Players</span>
          <span className="font-medium">{totalPlayers}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-muted-foreground">Format</span>
          <span className="font-medium">{format}</span>
        </div>
      </div>

      <div className="flex gap-2 pt-3 border-t border-border">
        {onViewDetails && (
          <Button onClick={onViewDetails} variant="outline" className="flex-1 bg-transparent">
            View Details
          </Button>
        )}
        {onInvite && (
          <Button onClick={onInvite} className="flex-1">
            Invite
          </Button>
        )}
        {onRemove && (
          <Button onClick={onRemove} variant="destructive" className="flex-1">
            Remove
          </Button>
        )}
        {onAccept && (
          <Button onClick={onAccept} className="flex-1">
            Accept
          </Button>
        )}
        {onDecline && (
          <Button onClick={onDecline} variant="outline" className="flex-1 bg-transparent">
            Decline
          </Button>
        )}
      </div>
    </Card>
  )
}
