"use client"

import LeagueCard from "@/components/cards/league-card"
import PageHeader from "@/components/layout/page-header"
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

export default function PfflLeaguesPage() {
  return (
    <div className="flex flex-col gap-3">
      <PageHeader
        title="Leagues."
        subtitle="All the leagues are listed below."
      />

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
            baseRoute="/pffl/leagues"
          />
        ))}
      </div>
    </div>
  )
}





