"use client"

import { Bell } from "lucide-react"

export default function CaptainHomePage() {
  return (
    <div className="flex flex-col gap-3">
      {/* Welcome Section with Bell Icon */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Welcome Captain,</h1>
          <p className="text-muted-foreground mt-1">Phoenix Flag Football League</p>
        </div>
        <button className="w-[60px] h-[60px] p-3 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center">
          <Bell className="w-5 h-5 text-foreground" />
        </button>
      </div>

      {/* Overview Section */}
      <div>
        <h2 className="text-[21px] font-bold text-[#111827]">
          Overview
        </h2>
      </div>

      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-2 mb-3">
        <div
          className="bg-white border rounded-xl p-6 flex flex-col gap-3"
          style={{
            borderColor: "rgba(0, 0, 0, 0.12)",
            borderWidth: "1px",
          }}
        >
          <p className="text-sm text-muted-foreground">Active Leagues</p>
          <p className="text-2xl font-bold text-foreground">0</p>
        </div>
        <div
          className="bg-white border rounded-xl p-6 flex flex-col gap-3"
          style={{
            borderColor: "rgba(0, 0, 0, 0.12)",
            borderWidth: "1px",
          }}
        >
          <p className="text-sm text-muted-foreground">Upcoming Games</p>
          <p className="text-2xl font-bold text-foreground">0</p>
        </div>
        <div
          className="bg-white border rounded-xl p-6 flex flex-col gap-3"
          style={{
            borderColor: "rgba(0, 0, 0, 0.12)",
            borderWidth: "1px",
          }}
        >
          <p className="text-sm text-muted-foreground">Team Members</p>
          <p className="text-2xl font-bold text-foreground">0</p>
        </div>
        <div
          className="bg-white border rounded-xl p-6 flex flex-col gap-3"
          style={{
            borderColor: "rgba(0, 0, 0, 0.12)",
            borderWidth: "1px",
          }}
        >
          <p className="text-sm text-muted-foreground">Total Points</p>
          <p className="text-2xl font-bold text-foreground">0</p>
        </div>
      </div>
    </div>
  )
}

