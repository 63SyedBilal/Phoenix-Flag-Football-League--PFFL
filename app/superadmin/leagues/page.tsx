"use client"

import { Bell } from "lucide-react"
import LeagueCard from "@/components/cards/league-card"

import type { LeagueCardProps } from "@/components/cards/league-card"

const mockLeagues: Omit<LeagueCardProps, "id">[] = [
  {
    name: "Phoenix Winter 2025",
    logo: "/placeholder-logo.png",
    format: "5v5",
    startDate: "10 December 2025",
    endDate: "25 February 2026",
    leagueFee: "$250",
    status: "active",
  },
  {
    name: "Champions Cup 2025",
    logo: "/placeholder-logo.png",
    format: "7v7",
    startDate: "10 December 2025",
    endDate: "25 February 2026",
    leagueFee: "$250",
    status: "active",
  },
  {
    name: "Phoenix Winter 2025",
    logo: "/placeholder-logo.png",
    format: "5v5",
    startDate: "10 December 2025",
    endDate: "25 February 2026",
    leagueFee: "$250",
    status: "active",
  },
  {
    name: "Phoenix Winter 2025",
    logo: "/placeholder-logo.png",
    format: "5v5",
    startDate: "10 December 2025",
    endDate: "25 February 2026",
    leagueFee: "$250",
    status: "pending",
  },
]

export default function LeaguesPage() {
  return (
    <div className="flex flex-col gap-3">
      {/* Header Section with Bell Icon */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Leagues.</h1>
          <p className="text-muted-foreground mt-1">All the leagues are listed below.</p>
        </div>
        <button className="w-[60px] h-[60px] p-3 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center">
          <Bell className="w-5 h-5 text-foreground" />
        </button>
      </div>

      {/* League Cards */}
      <div className="space-y-3">
        {mockLeagues.map((league, index) => (
          <LeagueCard
            key={index}
            id={String(index + 1)}
            name={league.name}
            logo={league.logo}
            format={league.format}
            startDate={league.startDate}
            endDate={league.endDate}
            leagueFee={league.leagueFee}
            status={league.status}
          />
        ))}
      </div>
    </div>
  )
}
