"use client"

import { useState } from "react"
import Link from "next/link"
import { Plus, Calendar, BarChart3, TrendingUp, Trophy } from "lucide-react"
import CreateLeagueForm from "@/components/forms/create-league-form"

export default function SuperAdminHome() {
  const [showCreateLeague, setShowCreateLeague] = useState(false)

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Welcome Tyler,</h1>
        <p className="text-muted-foreground mt-1">Phoenix Flag Football League</p>
      </div>

      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Total Leagues */}
        <div className="bg-card border border-border rounded-lg p-6">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Total Leagues</p>
              <p className="text-3xl font-bold text-foreground">12</p>
              <p className="text-xs text-muted-foreground mt-1">vs last month</p>
            </div>
            <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
              <Trophy className="w-5 h-5 text-orange-600" />
            </div>
          </div>
        </div>

        {/* Active Games */}
        <div className="bg-card border border-border rounded-lg p-6">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Active Games</p>
              <p className="text-3xl font-bold text-foreground">48</p>
              <p className="text-xs text-muted-foreground mt-1">6 today</p>
            </div>
            <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <Calendar className="w-5 h-5 text-blue-600" />
            </div>
          </div>
        </div>

        {/* Registered Users */}
        <div className="bg-card border border-border rounded-lg p-6">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Registered Users</p>
              <p className="text-3xl font-bold text-foreground">2,847</p>
              <p className="text-xs text-muted-foreground mt-1">120 this week</p>
            </div>
            <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
              <BarChart3 className="w-5 h-5 text-red-600" />
            </div>
          </div>
        </div>

        {/* Pending Payments */}
        <div className="bg-card border border-border rounded-lg p-6">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Pending Payments</p>
              <p className="text-3xl font-bold text-foreground">$12,540</p>
              <p className="text-xs text-muted-foreground mt-1">23 pending</p>
            </div>
            <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
              <TrendingUp className="w-5 h-5 text-green-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div>
        <h2 className="text-xl font-bold text-foreground mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <button
            onClick={() => setShowCreateLeague(true)}
            className="bg-card border border-border rounded-lg p-8 flex flex-col items-center justify-center gap-3 hover:bg-muted transition-colors text-left"
          >
            <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
              <Plus className="w-6 h-6 text-primary" />
            </div>
            <span className="font-medium text-foreground">Create League</span>
          </button>

          <Link
            href="/superadmin/games/schedule"
            className="bg-card border border-border rounded-lg p-8 flex flex-col items-center justify-center gap-3 hover:bg-muted transition-colors"
          >
            <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
              <Calendar className="w-6 h-6 text-primary" />
            </div>
            <span className="font-medium text-foreground">Schedule Game</span>
          </Link>
        </div>
      </div>

      {/* Coming Soon */}
      <div>
        <h2 className="text-xl font-bold text-foreground mb-4">Coming Soon</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-card border border-border rounded-lg p-8 flex flex-col items-center justify-center gap-3 opacity-50 cursor-not-allowed">
            <div className="w-12 h-12 bg-muted rounded-lg flex items-center justify-center">
              <BarChart3 className="w-6 h-6 text-muted-foreground" />
            </div>
            <span className="font-medium text-muted-foreground">Manage Stats</span>
          </div>

          <div className="bg-card border border-border rounded-lg p-8 flex flex-col items-center justify-center gap-3 opacity-50 cursor-not-allowed">
            <div className="w-12 h-12 bg-muted rounded-lg flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-muted-foreground" />
            </div>
            <span className="font-medium text-muted-foreground">View Reports</span>
          </div>
        </div>
      </div>

      {showCreateLeague && (
        <div className="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
          <CreateLeagueForm onClose={() => setShowCreateLeague(false)} />
        </div>
      )}
    </div>
  )
}
