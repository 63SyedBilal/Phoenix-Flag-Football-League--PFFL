"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import LeagueCard from "@/components/cards/league-card"
import PageHeader from "@/components/layout/page-header"
import LoadingSpinner from "@/components/ui/loading-spinner"
import type { LeagueCardProps } from "@/components/cards/league-card"

interface League {
  _id: string
  leagueName: string
  logo: string
  format: "5v5" | "7v7"
  startDate: string
  endDate: string
  perPlayerLeagueFee: number
  status: "active" | "pending"
}

export default function PfflLeaguesPage() {
  const router = useRouter()
  const [leagues, setLeagues] = useState<LeagueCardProps[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchLeagues = async () => {
      try {
        setIsLoading(true)
        setError(null)

        const token = localStorage.getItem("token")
        if (!token) {
          router.push("/not-found")
          return
        }

        const response = await fetch("/api/league", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || "Failed to fetch leagues")
        }

        const data = await response.json()
        const leaguesData: League[] = data.data || []

        // Format leagues for LeagueCard component
        const formattedLeagues: LeagueCardProps[] = leaguesData.map((league) => {
          // Format dates
          const startDate = new Date(league.startDate).toLocaleDateString("en-US", {
            day: "numeric",
            month: "long",
            year: "numeric",
          })
          const endDate = new Date(league.endDate).toLocaleDateString("en-US", {
            day: "numeric",
            month: "long",
            year: "numeric",
          })

          // Format league fee
          const leagueFee = `$${league.perPlayerLeagueFee || 0}`

          // Use logo or placeholder
          const logo = league.logo || "/placeholder-logo.png"

          return {
            id: league._id,
            name: league.leagueName,
            logo,
            format: league.format,
            startDate,
            endDate,
            leagueFee,
            status: league.status || "pending",
            baseRoute: "/pffl/leagues",
          }
        })

        setLeagues(formattedLeagues)
      } catch (err: any) {
        console.error("Error fetching leagues:", err)
        setError(err.message || "Failed to load leagues")
      } finally {
        setIsLoading(false)
      }
    }

    fetchLeagues()
  }, [])

  return (
    <div className="flex flex-col gap-3">
      <PageHeader
        title="Leagues."
        subtitle="All the leagues are listed below."
      />

      {/* Loading State */}
      {isLoading && (
        <LoadingSpinner fullScreen text="Loading leagues..." />
      )}

      {/* Error State */}
      {error && !isLoading && (
        <div className="text-center py-8 text-red-500">{error}</div>
      )}

      {/* League Cards */}
      {!isLoading && !error && (
        <div className="space-y-3">
          {leagues.length === 0 ? (
            <div className="text-center py-8 text-gray-500">No leagues found</div>
          ) : (
            leagues.map((league) => (
              <LeagueCard
                key={league.id}
                id={league.id}
                name={league.name}
                logo={league.logo}
                format={league.format}
                startDate={league.startDate}
                endDate={league.endDate}
                leagueFee={league.leagueFee}
                status={league.status}
                baseRoute="/pffl/leagues"
              />
            ))
          )}
        </div>
      )}
    </div>
  )
}






