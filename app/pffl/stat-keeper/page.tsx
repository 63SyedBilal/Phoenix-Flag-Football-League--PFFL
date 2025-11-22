"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Search } from "lucide-react"
import Image from "next/image"
import UsersCard from "@/components/cards/userscard"

const mockUsers = [
  {
    id: "1",
    name: "Emily Chen",
    email: "emily.c@pffl.com",
    league: null,
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Emily",
    roles: ["Stat Keeper", "Active"],
    roleColors: ["#D1FAE5", "#D1FAE5"],
    roleBorders: ["#A7F3D0", "#A7F3D0"],
  },
]

const filterOptions = ["All Users", "Players", "Captains", "Referees", "Stat Keeper"]

export default function StatKeeperPage() {
  const router = useRouter()
  const [activeFilter, setActiveFilter] = useState("Stat Keeper")
  const [searchQuery, setSearchQuery] = useState("")

  return (
    <div className="flex flex-col gap-3">
      {/* Back Arrow */}
      <div className="mb-2">
        <button
          onClick={() => router.push("/superadmin/home")}
          className="w-[50px] h-[50px] p-[10px] rounded-full bg-[#F2F2F2] hover:bg-gray-200 transition-colors flex items-center justify-center flex-shrink-0 mb-2"
        >
          <Image src="/assets/image/Back arrow.svg" alt="Back" width={24} height={24} />
        </button>
      </div>

      {/* Header */}
      <div className="mb-4">
        <h1 className="text-3xl font-bold text-foreground">Stat Keepers</h1>
        <p className="text-muted-foreground mt-1">Manage all stat keepers.</p>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <input
          type="text"
          placeholder="Search users by name or email..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full h-[46.33px] px-4 rounded-xl border pr-10"
          style={{
            border: "0.67px solid #E5E7EB",
            borderTop: "0.67px solid #E5E7EB",
            borderRadius: "14px",
            backgroundColor: "#FFFFFF",
          }}
        />
        <Search className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
      </div>

      {/* Filter Buttons */}
      <div className="flex items-center gap-2 flex-wrap">
        {filterOptions.map((filter) => (
          <button
            key={filter}
            onClick={() => setActiveFilter(filter)}
            className="px-3 font-normal transition-colors whitespace-nowrap text-sm"
            style={{
              minWidth: "70px",
              paddingTop: "8px",
              paddingBottom: "8px",
              borderRadius: "8px",
              fontFamily: "Lato, sans-serif",
              fontWeight: 400,
              fontSize: "14px",
              lineHeight: "100%",
              backgroundColor: activeFilter === filter ? "#3B82F6" : "#FFFFFF",
              color: activeFilter === filter ? "#FFFFFF" : "#000000",
              border: activeFilter === filter ? "none" : "0.67px solid rgba(0, 0, 0, 0.12)",
            }}
          >
            {filter}
          </button>
        ))}
      </div>

      {/* User Cards */}
      <div className="space-y-3">
        {mockUsers.map((user) => (
          <UsersCard
            key={user.id}
            id={user.id}
            name={user.name}
            email={user.email}
            league={user.league}
            avatar={user.avatar}
            roles={user.roles}
            roleColors={user.roleColors}
            roleBorders={user.roleBorders}
          />
        ))}
      </div>
    </div>
  )
}

