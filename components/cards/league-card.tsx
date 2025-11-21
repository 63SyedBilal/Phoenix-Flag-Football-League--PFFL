"use client"

import type React from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export interface LeagueCardProps {
  id: string
  name: string
  logo?: string
  format: string // e.g., "5v5", "7v7"
  startDate: string
  endDate: string
  status: "upcoming" | "active" | "completed"
  totalTeams?: number
  totalPlayers?: number
  entryFee?: number
  minPlayersRequired?: number
  onView?: () => void
  onJoin?: () => void
  onManage?: () => void
  isManaging?: boolean
}

export const LeagueCard: React.FC<LeagueCardProps> = ({
  id,
  name,
  logo,
  format,
  startDate,
  endDate,
  status,
  totalTeams,
  totalPlayers,
  entryFee,
  minPlayersRequired,
  onView,
  onJoin,
  onManage,
  isManaging,
}) => {
  const statusStyles = {
    upcoming: "bg-blue-100 text-blue-700",
    active: "bg-green-100 text-green-700",
    completed: "bg-gray-100 text-gray-700",
  }

  return (
    <Card className="p-4 flex flex-col h-full">
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2 flex-1">
          {logo && <img src={logo || "/placeholder.svg"} alt={name} className="w-10 h-10 rounded-lg" />}
          <div className="flex-1">
            <h3 className="font-semibold text-foreground text-lg">{name}</h3>
            <p className="text-xs text-muted-foreground">{format} Format</p>
          </div>
        </div>
        <span className={`text-xs font-medium px-2 py-1 rounded-full whitespace-nowrap ${statusStyles[status]}`}>
          {status.charAt(0).toUpperCase() + status.slice(1)}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-2 text-sm mb-4 pb-4 border-b border-border">
        <div>
          <p className="text-muted-foreground">Starts</p>
          <p className="font-medium text-sm">{startDate}</p>
        </div>
        <div>
          <p className="text-muted-foreground">Ends</p>
          <p className="font-medium text-sm">{endDate}</p>
        </div>
        {totalTeams !== undefined && (
          <div>
            <p className="text-muted-foreground">Teams</p>
            <p className="font-medium text-sm">{totalTeams}</p>
          </div>
        )}
        {entryFee !== undefined && (
          <div>
            <p className="text-muted-foreground">Fee</p>
            <p className="font-medium text-sm">${entryFee}</p>
          </div>
        )}
      </div>

      {(totalPlayers !== undefined || minPlayersRequired !== undefined) && (
        <div className="bg-muted/50 p-2 rounded mb-4 text-xs">
          {totalPlayers !== undefined && <p>Players: {totalPlayers}</p>}
          {minPlayersRequired !== undefined && <p>Min Required: {minPlayersRequired}</p>}
        </div>
      )}

      <div className="flex gap-2 mt-auto pt-3 border-t border-border">
        {onView && (
          <Button onClick={onView} variant="outline" className="flex-1 bg-transparent">
            View
          </Button>
        )}
        {!isManaging && onJoin && (
          <Button onClick={onJoin} className="flex-1">
            Join
          </Button>
        )}
        {isManaging && onManage && (
          <Button onClick={onManage} className="flex-1">
            Manage
          </Button>
        )}
      </div>
    </Card>
  )
}
