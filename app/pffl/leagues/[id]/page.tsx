"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import Image from "next/image"
import PageHeader from "@/components/layout/page-header"
import { ArrowLeft } from "lucide-react"

interface League {
  _id: string
  leagueName: string
  logo: string
  format: "5v5" | "7v7"
  startDate: string
  endDate: string
  minimumPlayers: number
  entryFeeType: "stripe" | "paypal"
  perPlayerLeagueFee: number
  status: "active" | "pending"
  referees: Array<{
    _id: string
    firstName: string
    lastName: string
    email: string
    role: string
  }>
  statKeepers: Array<{
    _id: string
    firstName: string
    lastName: string
    email: string
    role: string
  }>
  teams: Array<{
    _id: string
    teamName: string
    enterCode: string
    location: string
    skillLevel: string
  }>
  createdAt: string
  updatedAt: string
}

export default function LeagueDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [league, setLeague] = useState<League | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchLeague = async () => {
      try {
        setIsLoading(true)
        setError(null)

        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view league details")
          setIsLoading(false)
          return
        }

        const leagueId = params.id as string
        const response = await fetch(`/api/league/${leagueId}`, {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || "Failed to fetch league")
        }

        const data = await response.json()
        setLeague(data.data)
      } catch (err: any) {
        console.error("Error fetching league:", err)
        setError(err.message || "Failed to load league")
      } finally {
        setIsLoading(false)
      }
    }

    if (params.id) {
      fetchLeague()
    }
  }, [params.id])

  if (isLoading) {
    return (
      <div className="flex flex-col gap-3">
        <PageHeader title="Loading..." subtitle="Fetching league details..." />
        <div className="text-center py-8 text-gray-500">Loading league details...</div>
      </div>
    )
  }

  if (error || !league) {
    return (
      <div className="flex flex-col gap-3">
        <PageHeader title="Error" subtitle={error || "League not found"} />
        <div className="text-center py-8 text-red-500">{error || "League not found"}</div>
        <button
          onClick={() => router.push("/pffl/leagues")}
          className="flex items-center gap-2 text-blue-600 hover:text-blue-800"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Leagues
        </button>
      </div>
    )
  }

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

  const logo = league.logo || "/placeholder-logo.png"

  return (
    <div className="flex flex-col gap-6">
      {/* Back Button */}
      <button
        onClick={() => router.push("/pffl/leagues")}
        className="flex items-center gap-2 text-gray-600 hover:text-gray-800 w-fit"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Leagues
      </button>

      {/* Header */}
      <div className="flex items-center gap-6">
        <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 overflow-hidden border-2 border-dashed border-gray-300">
          <Image
            src={logo}
            alt={league.leagueName}
            width={80}
            height={80}
            className="w-20 h-20 rounded-full object-cover"
          />
        </div>
        <div className="flex-1">
          <h1 className="text-3xl font-bold text-foreground">{league.leagueName}</h1>
          <p className="text-muted-foreground mt-1">
            {league.format} • {league.status === "active" ? "Active" : "Pending"}
          </p>
        </div>
        <div
          className="text-white text-sm font-medium flex-shrink-0 px-4 py-2 rounded-full"
          style={{
            backgroundColor: league.status === "active" ? "#0F173E" : "#A855F7",
          }}
        >
          {league.status === "active" ? "Active" : "Pending"}
        </div>
      </div>

      {/* League Details */}
      <div className="bg-white border rounded-xl p-6 space-y-6">
        <h2 className="text-xl font-semibold text-foreground">League Information</h2>

        <div className="grid grid-cols-2 gap-6">
          <div>
            <p className="text-sm text-muted-foreground">Start Date</p>
            <p className="text-base font-medium text-foreground">{startDate}</p>
          </div>
          <div>
            <p className="text-sm text-muted-foreground">End Date</p>
            <p className="text-base font-medium text-foreground">{endDate}</p>
          </div>
          <div>
            <p className="text-sm text-muted-foreground">Format</p>
            <p className="text-base font-medium text-foreground">{league.format}</p>
          </div>
          <div>
            <p className="text-sm text-muted-foreground">Minimum Players</p>
            <p className="text-base font-medium text-foreground">{league.minimumPlayers}</p>
          </div>
          <div>
            <p className="text-sm text-muted-foreground">League Fee (Per Player)</p>
            <p className="text-base font-medium text-foreground">${league.perPlayerLeagueFee || 0}</p>
          </div>
          <div>
            <p className="text-sm text-muted-foreground">Payment Method</p>
            <p className="text-base font-medium text-foreground capitalize">{league.entryFeeType}</p>
          </div>
        </div>
      </div>

      {/* Referees */}
      <div className="bg-white border rounded-xl p-6 space-y-4">
        <h2 className="text-xl font-semibold text-foreground">
          Referees ({league.referees?.length || 0})
        </h2>
        {league.referees && league.referees.length > 0 ? (
          <div className="space-y-3">
            {league.referees.map((referee) => (
              <div key={referee._id} className="flex items-center gap-4 p-3 border rounded-lg">
                <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                  <span className="text-sm font-medium">
                    {referee.firstName?.[0] || ""}{referee.lastName?.[0] || ""}
                  </span>
                </div>
                <div className="flex-1">
                  <p className="font-medium">
                    {referee.firstName} {referee.lastName}
                  </p>
                  <p className="text-sm text-muted-foreground">{referee.email}</p>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-muted-foreground">No referees assigned yet</p>
        )}
      </div>

      {/* Stat Keepers */}
      <div className="bg-white border rounded-xl p-6 space-y-4">
        <h2 className="text-xl font-semibold text-foreground">
          Stat Keepers ({league.statKeepers?.length || 0})
        </h2>
        {league.statKeepers && league.statKeepers.length > 0 ? (
          <div className="space-y-3">
            {league.statKeepers.map((keeper) => (
              <div key={keeper._id} className="flex items-center gap-4 p-3 border rounded-lg">
                <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                  <span className="text-sm font-medium">
                    {keeper.firstName?.[0] || ""}{keeper.lastName?.[0] || ""}
                  </span>
                </div>
                <div className="flex-1">
                  <p className="font-medium">
                    {keeper.firstName} {keeper.lastName}
                  </p>
                  <p className="text-sm text-muted-foreground">{keeper.email}</p>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-muted-foreground">No stat keepers assigned yet</p>
        )}
      </div>

      {/* Teams */}
      <div className="bg-white border rounded-xl p-6 space-y-4">
        <h2 className="text-xl font-semibold text-foreground">
          Teams ({league.teams?.length || 0})
        </h2>
        {league.teams && league.teams.length > 0 ? (
          <div className="space-y-3">
            {league.teams.map((team) => (
              <div key={team._id} className="flex items-center gap-4 p-3 border rounded-lg">
                <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                  <span className="text-sm font-medium">{team.teamName?.[0] || "T"}</span>
                </div>
                <div className="flex-1">
                  <p className="font-medium">{team.teamName}</p>
                  <p className="text-sm text-muted-foreground">
                    {team.location} • {team.skillLevel}
                  </p>
                </div>
                <div className="text-sm text-muted-foreground">Code: {team.enterCode}</div>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-muted-foreground">No teams joined yet</p>
        )}
      </div>
    </div>
  )
}

