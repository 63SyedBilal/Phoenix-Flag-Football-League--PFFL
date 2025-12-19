"use client"

import { useEffect, useState } from "react"
import BellNotificationButton from "@/components/layout/bell-notification-button"
import LeagueCard from "@/components/cards/league-card"
import LoadingSpinner from "@/components/ui/loading-spinner"
import CreateGameForm from "@/components/forms/create-game-form"
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

export default function LeaguesPage() {
  const [leagues, setLeagues] = useState<LeagueCardProps[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showCreateGameModal, setShowCreateGameModal] = useState(false)

  useEffect(() => {
    const fetchLeagues = async () => {
      try {
        setIsLoading(true)
        setError(null)

        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view leagues")
          setIsLoading(false)
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
            baseRoute: "/superadmin/leagues",
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
    <>
      <div className="flex flex-col gap-3">
        {/* Header Section with Bell Icon */}
        <div className="flex items-start justify-between mb-4">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Leagues.</h1>
            <p className="text-muted-foreground mt-1">All the leagues are listed below.</p>
          </div>
          <BellNotificationButton notificationRoute="/superadmin/settings/notifications" useSuperadminPayments={true} />
        </div>

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
                  baseRoute="/superadmin/leagues"
                />
              ))
            )}
          </div>
        )}
      </div>

      {/* Floating Action Button */}
      <button
        onClick={() => setShowCreateGameModal(true)}
        className="fixed bottom-8 right-8 w-14 h-14 rounded-full text-white font-medium shadow-lg hover:shadow-xl transition-shadow z-40 flex items-center justify-center"
        style={{
          backgroundColor: "#0F173E",
        }}
        aria-label="Create Game"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
      </button>

      {/* Create Game Modal */}
      {showCreateGameModal && (
        <CreateGameForm onClose={() => setShowCreateGameModal(false)} />
      )}
    </>
  )
}
