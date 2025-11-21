"use client"

import { useState } from "react"
import { Plus, Mail, Trash2 } from "lucide-react"

// League detail view
export default function LeaguesPage() {
  const [activeTab, setActiveTab] = useState("teams")

  const tabs = [
    { id: "overview", label: "Overview" },
    { id: "games", label: "Games" },
    { id: "leaderboard", label: "Leaderboard" },
    { id: "teams", label: "Teams" },
    { id: "officials", label: "Officials" },
    { id: "stats", label: "Stats" },
  ]

  // Sample data
  const teams = [
    {
      id: 1,
      name: "STC",
      logo: "🏈",
      players: [
        { number: "01", name: "Alex Morgan (C)", status: "Paid" },
        { number: "02", name: "John Carter", status: "Paid" },
        { number: "03", name: "Michael Lee", status: "Paid" },
        { number: "04", name: "Rebecca Torres", status: "Paid" },
      ],
    },
    {
      id: 2,
      name: "GEO",
      logo: "🏈",
      players: [
        { number: "01", name: "Sarah Johnson", status: "Pending" },
        { number: "02", name: "Mark Wilson", status: "Paid" },
      ],
    },
  ]

  const referees = [
    { id: 1, name: "John Carter", status: "Active" },
    { id: 2, name: "Michael Lee", status: "Active" },
    { id: 3, name: "Anthony Brooks", status: "Active" },
  ]

  const statKeepers = [
    { id: 1, name: "Alex Morgan", status: "Active" },
    { id: 2, name: "David Brooks", status: "Active" },
    { id: 3, name: "Rebecca Torres", status: "Active" },
  ]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-3xl font-bold text-foreground flex items-center gap-3">
            <span className="text-2xl">🏈</span>
            Phoenix Winter 2025
          </h1>
          <p className="text-muted-foreground mt-1">Stay updated with all details, Games, and stats for this league.</p>
        </div>
        <button className="bg-primary text-white px-4 py-2 rounded-lg font-medium hover:bg-primary/90 transition-colors flex items-center gap-2">
          <Plus className="w-5 h-5" />
          Create Game
        </button>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 border-b border-border">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-3 font-medium text-sm transition-colors ${
              activeTab === tab.id
                ? "text-primary border-b-2 border-primary"
                : "text-muted-foreground hover:text-foreground"
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Content */}
      {activeTab === "teams" && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-bold text-foreground">Teams</h2>
            <button className="bg-primary text-white px-4 py-2 rounded-lg font-medium hover:bg-primary/90 transition-colors flex items-center gap-2">
              <Plus className="w-5 h-5" />
              Add Teams
            </button>
          </div>

          {teams.map((team) => (
            <div key={team.id} className="bg-card border border-border rounded-lg overflow-hidden">
              {/* Team Header */}
              <div className="p-4 flex items-center justify-between hover:bg-muted transition-colors cursor-pointer">
                <div className="flex items-center gap-3">
                  <div className="text-2xl">{team.logo}</div>
                  <div>
                    <h3 className="font-bold text-foreground">{team.name}</h3>
                    <p className="text-sm text-muted-foreground">View Team Overview ({team.players.length}/8)</p>
                  </div>
                </div>
              </div>

              {/* Team Players */}
              <div className="border-t border-border p-4">
                <div className="grid grid-cols-4 gap-4 text-sm font-medium text-muted-foreground mb-3">
                  <div># Jersey Number</div>
                  <div>Player Name</div>
                  <div>Payment Status</div>
                  <div />
                </div>
                {team.players.map((player) => (
                  <div
                    key={player.number}
                    className="grid grid-cols-4 gap-4 items-center py-3 border-t border-border/50"
                  >
                    <div className="font-medium text-foreground">{player.number}</div>
                    <div className="text-foreground">{player.name}</div>
                    <div className="flex">
                      <span
                        className={`px-3 py-1 rounded-full text-xs font-medium ${
                          player.status === "Paid" ? "bg-green-100 text-green-700" : "bg-yellow-100 text-yellow-700"
                        }`}
                      >
                        {player.status}
                      </span>
                    </div>
                    <div className="flex justify-end">
                      <button className="p-1 hover:bg-muted rounded transition-colors">
                        <Trash2 className="w-4 h-4 text-muted-foreground" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {activeTab === "officials" && (
        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-6">
            {/* Referees */}
            <div>
              <h2 className="text-lg font-bold text-foreground mb-4">Referees</h2>
              <div className="space-y-3">
                {referees.map((ref) => (
                  <div
                    key={ref.id}
                    className="bg-card border border-border rounded-lg p-4 flex items-center justify-between hover:bg-muted transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-muted rounded-full" />
                      <div>
                        <p className="font-medium text-foreground">{ref.name}</p>
                        <p className="text-xs text-muted-foreground">{ref.status}</p>
                      </div>
                    </div>
                    <button className="p-2 hover:bg-muted-foreground/10 rounded transition-colors">
                      <Mail className="w-4 h-4 text-muted-foreground" />
                    </button>
                  </div>
                ))}
              </div>
            </div>

            {/* Stat Keepers */}
            <div>
              <h2 className="text-lg font-bold text-foreground mb-4">Stat Keepers</h2>
              <div className="space-y-3">
                {statKeepers.map((keeper) => (
                  <div
                    key={keeper.id}
                    className="bg-card border border-border rounded-lg p-4 flex items-center justify-between hover:bg-muted transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-muted rounded-full" />
                      <div>
                        <p className="font-medium text-foreground">{keeper.name}</p>
                        <p className="text-xs text-muted-foreground">{keeper.status}</p>
                      </div>
                    </div>
                    <button className="p-2 hover:bg-muted-foreground/10 rounded transition-colors">
                      <Mail className="w-4 h-4 text-muted-foreground" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {activeTab !== "teams" && activeTab !== "officials" && (
        <div className="bg-card border border-border rounded-lg p-12 text-center">
          <p className="text-muted-foreground">Coming soon...</p>
        </div>
      )}
    </div>
  )
}
