"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Bell, Plus, Calendar, BarChart3, TrendingUp } from "lucide-react"
import CreateLeagueForm from "@/components/forms/create-league-form"

export default function SuperAdminHome() {
  const router = useRouter()
  const [showCreateLeague, setShowCreateLeague] = useState(false)

  const handleCreateLeague = () => {
    setShowCreateLeague(true)
  }

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
          <button className="w-[60px] h-[60px] p-3 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center">
            <Bell className="w-5 h-5 text-foreground" />
          </button>
        </div>

        {/* Overview Section */}
        <div>
          <h2 className="text-[21px] font-bold text-[#111827] " >
            Overview
          </h2>
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
              <p className="text-3xl font-bold text-foreground">12</p>
              <p className="text-xs text-muted-foreground mt-1">+2 this month</p>
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
              <p className="text-3xl font-bold text-foreground">48</p>
              <p className="text-xs text-muted-foreground mt-1">8 today</p>
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
              <p className="text-3xl font-bold text-foreground">2,847</p>
              <p className="text-xs text-muted-foreground mt-1">+156 this week</p>
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
              <p className="text-3xl font-bold text-foreground">$12,540</p>
              <p className="text-xs text-muted-foreground mt-1">23 pending</p>
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
            className="bg-white border rounded-xl p-6 flex flex-col items-center justify-center gap-3 hover:bg-gray-50 transition-colors min-h-[120px]"
            style={{ 
              borderColor: "rgba(0, 0, 0, 0.12)",
              borderWidth: "1px"
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
