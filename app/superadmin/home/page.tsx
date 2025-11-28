"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Plus, Calendar, BarChart3, TrendingUp } from "lucide-react"
import BellNotificationButton from "@/components/layout/bell-notification-button"
import CreateLeagueForm from "@/components/forms/create-league-form"

interface DashboardStats {
  leagues: {
    total: number
    active: number
    thisMonth: number
  }
  games: {
    active: number
    today: number
  }
  users: {
    total: number
    thisWeek: number
    byRole: {
      [key: string]: number
    }
  }
  payments: {
    totalAmount: number
    count: number
  }
}

export default function SuperAdminHome() {
  const router = useRouter()
  const [showCreateLeague, setShowCreateLeague] = useState(false)
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const handleCreateLeague = () => {
    setShowCreateLeague(true)
  }

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const token = localStorage.getItem("token")
        if (!token) {
          console.error("No token found")
          setIsLoading(false)
          return
        }

        const response = await fetch("/api/superadmin/stats", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}))
          console.error("Failed to fetch stats:", response.status, errorData)
          setError(errorData.error || `Failed to fetch stats (${response.status})`)
          setIsLoading(false)
          return
        }

        const data = await response.json()
        console.log("Stats data received:", data)
        if (data.success && data.data) {
          setStats(data.data)
          setError(null)
        } else {
          console.error("Stats API returned success: false", data)
          setError(data.error || "Failed to load stats")
        }
      } catch (err: any) {
        console.error("Error fetching stats:", err)
        setError(err.message || "An error occurred while fetching stats")
      } finally {
        setIsLoading(false)
      }
    }

    fetchStats()
  }, [])

  if (showCreateLeague) {
    return <CreateLeagueForm onClose={() => setShowCreateLeague(false)} />
  }

  return (
    <>
      <div className="flex flex-col gap-3">
        {/* Welcome Section with Bell Icon */}
        <div className="flex items-start justify-between mb-4">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Welcome Tyler,</h1>
            <p className="text-muted-foreground mt-1">Phoenix Flag Football League</p>
          </div>
          <BellNotificationButton notificationRoute="/superadmin/settings/notifications" useSuperadminPayments={true} />
        </div>

        {/* Overview Section */}
        <div>
          <h2 className="text-[21px] font-bold text-[#111827] " >
            Overview
          </h2>
          {error && (
            <div className="mt-2 p-3 bg-red-50 border border-red-200 rounded-lg">
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}
        </div>

        {/* Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-2 mb-3">
          {/* Total Leagues */}
          <div 
            className="bg-white border rounded-xl p-3 cursor-pointer hover:bg-gray-50 transition-colors flex items-center justify-between min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.08)",
              borderWidth: "1px"
            }}
            onClick={() => router.push("/superadmin/leagues")}
          >
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Total Leagues</p>
              <p className="text-3xl font-bold text-foreground">
                {isLoading ? "..." : stats?.leagues.total || 0}
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                +{stats?.leagues.thisMonth || 0} this month
              </p>
            </div>
            <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
              <span className="text-orange-600 text-xl">🏆</span>
            </div>
          </div>

          {/* Active Games */}
          <div 
            className="bg-white border rounded-xl p-3 cursor-pointer hover:bg-gray-50 transition-colors flex items-center justify-between min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.08)",
              borderWidth: "1px"
            }}
            onClick={() => router.push("/superadmin/games")}
          >
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Active Games</p>
              <p className="text-3xl font-bold text-foreground">
                {isLoading ? "..." : stats?.games.active || 0}
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                {stats?.games.today || 0} today
              </p>
            </div>
            <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <Calendar className="w-5 h-5 text-blue-600" />
            </div>
          </div>

          {/* Registered Users */}
          <div 
            className="bg-white border rounded-xl p-3 cursor-pointer hover:bg-gray-50 transition-colors flex items-center justify-between min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.08)",
              borderWidth: "1px"
            }}
            onClick={() => router.push("/superadmin/users")}
          >
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Registered Users</p>
              <p className="text-3xl font-bold text-foreground">
                {isLoading ? "..." : stats?.users.total.toLocaleString() || 0}
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                +{stats?.users.thisWeek || 0} this week
              </p>
            </div>
            <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
              <span className="text-red-600 text-xl">👥</span>
            </div>
          </div>

          {/* Pending Payments */}
          <div 
            className="bg-white border rounded-xl p-3 cursor-pointer hover:bg-gray-50 transition-colors flex items-center justify-between min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.08)",
              borderWidth: "1px"
            }}
          >
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Pending payments</p>
              <p className="text-3xl font-bold text-foreground">
                {isLoading ? "..." : `$${stats?.payments.totalAmount.toLocaleString() || 0}`}
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                {stats?.payments.count || 0} pending
              </p>
            </div>
            <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
              <span className="text-green-600 text-xl">💰</span>
            </div>
          </div>
        </div>

        {/* Quick Actions Section */}
        <div>
          <h2 className="text-[21px] font-bold text-[#111827] " >
            Quick Actions
          </h2>
        </div>

        {/* Quick Actions Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
          <button
            onClick={handleCreateLeague}
            className="bg-white border rounded-xl p-6 flex flex-col items-center justify-center gap-3 hover:bg-gray-50 transition-colors min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.12)",
              borderWidth: "1px"
            }}
          >
            <Plus className="w-8 h-8 text-foreground" />
            <span className="font-medium text-foreground">Create League</span>
          </button>

          <button
            onClick={() => router.push("/superadmin/games/schedule")}
            className="bg-white border rounded-xl p-6 flex flex-col items-center justify-center gap-3 hover:bg-gray-50 transition-colors min-h-[120px] cursor-not-allowed"
            disabled
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.12)",
              borderWidth: "1px",
              filter: "blur(1px)",
              opacity: 0.5
            }}
          >
            <Calendar className="w-8 h-8 text-foreground" />
            <span className="font-medium text-foreground">Schedule Game</span>
          </button>
        </div>

        {/* Coming Soon Section */}
        <div>
          <h2 className="text-[21px] font-bold text-[#111827] " >
            Coming Soon
          </h2>
        </div>

        {/* Coming Soon Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
          <div
            className="bg-white border rounded-xl p-6 flex flex-col items-center justify-center gap-3 cursor-not-allowed min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.12)",
              borderWidth: "1px",
              filter: "blur(1px)",
              opacity: 0.5
            }}
          >
            <BarChart3 className="w-8 h-8 text-foreground" />
            <span className="font-medium text-foreground">Manage Stats</span>
          </div>

          <div
            className="bg-white border rounded-xl p-6 flex flex-col items-center justify-center gap-3 cursor-not-allowed min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.12)",
              borderWidth: "1px",
              filter: "blur(1px)",
              opacity: 0.5
            }}
          >
            <TrendingUp className="w-8 h-8 text-foreground" />
            <span className="font-medium text-foreground">View Reports</span>
          </div>
        </div>
      </div>

    </>
  )
}
