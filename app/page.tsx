"use client"

import { useState } from "react"
import { redirect } from "next/navigation"
import { Header } from "@/components/layout/header"
import { Sidebar } from "@/components/layout/sidebar"
import { NotificationCard } from "@/components/cards/notification-card"
import { PaymentCard } from "@/components/cards/payment-card"
import { LeagueCard } from "@/components/cards/league-card"
import { TeamCard } from "@/components/cards/team-card"
import { HomeIcon, CalendarIcon, UsersIcon, SettingsIcon } from "lucide-react"

export default function RootPage() {
  redirect("/superadmin")

  const [sidebarOpen, setSidebarOpen] = useState(true)

  const navItems = [
    { label: "Home", href: "/", icon: <HomeIcon size={20} />, active: true },
    { label: "Leagues", href: "/leagues", icon: <CalendarIcon size={20} /> },
    { label: "Teams", href: "/teams", icon: <UsersIcon size={20} /> },
    { label: "Settings", href: "/settings", icon: <SettingsIcon size={20} /> },
  ]

  const userInfo = {
    name: "Romail Ahmed",
    email: "romail@phoenix.com",
  }

  return (
    <div className="flex h-screen bg-background">
      {/* Sidebar */}
      <Sidebar logoText="PFFL" navItems={navItems} userInfo={userInfo} onLogout={() => console.log("Logout clicked")} />

      {/* Main Content */}
      <main className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <Header
          title="Welcome Tyler."
          subtitle="Phoenix Flag Football League"
          actionButton={{
            label: "+ Create League",
            onClick: () => console.log("Create league clicked"),
          }}
        />

        {/* Page Content */}
        <div className="flex-1 overflow-auto p-6">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Sample Notification */}
            <div>
              <h2 className="text-lg font-semibold text-foreground mb-4">Recent Notifications</h2>
              <NotificationCard
                type="payment-required"
                title="Payment Required"
                description="Your League Fee has not been paid. Please complete your payment to stay eligible for the upcoming league."
                date="09 Dec 2025"
                status="active"
                leagueInfo={{
                  name: "Phoenix Winter 2025",
                  format: "5v5",
                  startDate: "10 December 2025",
                  endDate: "25 February 2026",
                  leagueFee: "$250",
                }}
                action={{
                  label: "Pay Now",
                  onClick: () => console.log("Pay now clicked"),
                }}
              />
            </div>

            {/* Sample League Card */}
            <div>
              <h2 className="text-lg font-semibold text-foreground mb-4">Active Leagues</h2>
              <LeagueCard
                id="league-001"
                name="Phoenix Winter 2025"
                format="5v5"
                startDate="10 Dec 2025"
                endDate="25 Feb 2026"
                status="active"
                totalTeams={12}
                totalPlayers={85}
                entryFee={250}
                minPlayersRequired={5}
                onView={() => console.log("View league")}
              />
            </div>

            {/* Sample Payment Card */}
            <div>
              <h2 className="text-lg font-semibold text-foreground mb-4">Recent Payments</h2>
              <PaymentCard
                paymentId="Payment #01"
                amount={250}
                date="09 Dec 2025"
                method="stripe"
                status="paid"
                leagueName="Phoenix Winter 2025"
                leagueInfo={{
                  format: "5v5",
                  startDate: "10 December 2025",
                  endDate: "25 February 2026",
                  fee: 250,
                }}
                onViewReceipt={() => console.log("View receipt")}
              />
            </div>

            {/* Sample Team Card */}
            <div>
              <h2 className="text-lg font-semibold text-foreground mb-4">Your Teams</h2>
              <TeamCard
                id="team-001"
                name="STC"
                captain="Alex Morgan (C)"
                totalPlayers={8}
                format="5v5"
                status="active"
                onViewDetails={() => console.log("View team details")}
              />
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}
