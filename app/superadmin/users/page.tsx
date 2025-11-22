"use client"

import { useState } from "react"
import { Bell, Search, UserPlus } from "lucide-react"
import Image from "next/image"
import UsersCard from "@/components/cards/userscard"

const mockUsers = [
  {
    id: "1",
    name: "Marcus Johnson",
    email: "marcus.j@pffl.com",
    league: "Phoenix Falcons",
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus",
    roles: ["Captain", "Active"],
    roleColors: ["#FEF3C7", "#D1FAE5"],
    roleBorders: ["#FDE68A", "#A7F3D0"],
  },
  {
    id: "2",
    name: "Sarah Mitchell",
    email: "sarah.m@pffl.com",
    league: "Storm Riders",
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah",
    roles: ["Player", "Invited"],
    roleColors: ["#DBEAFE", "#DBEAFE"],
    roleBorders: ["#93C5FD", "#93C5FD"],
  },
  {
    id: "3",
    name: "James Richardson",
    email: "james.r@pffl.com",
    league: null,
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=James",
    roles: ["Referee", "Active"],
    roleColors: ["#E9D5FF", "#D1FAE5"],
    roleBorders: ["#C084FC", "#A7F3D0"],
  },
  {
    id: "4",
    name: "Emily Chen",
    email: "emily.c@pffl.com",
    league: null,
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Emily",
    roles: ["Stat Keeper", "Active"],
    roleColors: ["#D1FAE5", "#D1FAE5"],
    roleBorders: ["#A7F3D0", "#A7F3D0"],
  },
  {
    id: "5",
    name: "James Richardson",
    email: "james.r@pffl.com",
    league: null,
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=James2",
    roles: ["Referee", "Pending"],
    roleColors: ["#E9D5FF", "#FED7AA"],
    roleBorders: ["#C084FC", "#FDBA74"],
  },
]

const filterOptions = ["All Users", "Players", "Captains", "Referees", "Stat Keeper"]

export default function UsersPage() {
  const [activeFilter, setActiveFilter] = useState("All Users")
  const [searchQuery, setSearchQuery] = useState("")
  const [showInviteModal, setShowInviteModal] = useState(false)
  const [email, setEmail] = useState("")
  const [selectedRole, setSelectedRole] = useState("Captain")
  const [isRoleDropdownOpen, setIsRoleDropdownOpen] = useState(false)

  const roles = ["Captain", "Referee", "Stat Keeper", "Player", "Free Agent"]

  return (
    <div className="flex flex-col gap-3">
      {/* Header Section */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Users</h1>
          <p className="text-muted-foreground mt-1">Manage all users.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="w-[60px] h-[60px] p-3 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center">
            <Bell className="w-5 h-5 text-foreground" />
          </button>
          <button
            onClick={() => setShowInviteModal(true)}
            className="flex items-center justify-center gap-2 text-white font-medium rounded-xl"
            style={{
              width: "111px",
              height: "50px",
              gap: "8px",
              borderRadius: "14px",
              backgroundColor: "#3B82F6",
            }}
          >
            <UserPlus className="w-5 h-5" />
            <span>Invite</span>
          </button>
        </div>
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

      {/* Invite User Modal */}
      {showInviteModal && (
        <div
          className="fixed inset-0 flex items-center justify-center z-50"
          style={{ backgroundColor: "rgba(0, 0, 0, 0.2)" }}
          onClick={() => {
            setShowInviteModal(false)
            setIsRoleDropdownOpen(false)
          }}
        >
          <div
            className="bg-white rounded-[24px] relative"
            style={{
              width: "603px",
              padding: "20px 14px",
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div
              className="flex flex-col"
              style={{
                width: "575px",
                gap: "20px",
              }}
            >
              {/* Title */}
              <h2 className="text-2xl font-bold text-foreground text-center" style={{ fontFamily: "Lato, sans-serif" }}>
                Invite User
              </h2>

              {/* Email Input */}
              <div className="flex flex-col gap-2">
                <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
                  Email
                </label>
                <input
                  type="email"
                  placeholder="Enter email address"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white"
                  style={{ fontFamily: "Lato, sans-serif" }}
                />
              </div>

              {/* Role Dropdown */}
              <div className="flex flex-col gap-2">
                <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
                  Role
                </label>
                <div className="relative">
                  <button
                    onClick={() => setIsRoleDropdownOpen(!isRoleDropdownOpen)}
                    className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white flex items-center justify-between text-left"
                    style={{ fontFamily: "Lato, sans-serif" }}
                  >
                    <span>{selectedRole}</span>
                    <Image
                      src="/assets/image/arrow-down.svg"
                      alt="dropdown"
                      width={16}
                      height={16}
                      className={`transition-transform ${isRoleDropdownOpen ? "rotate-180" : ""}`}
                    />
                  </button>
                  {isRoleDropdownOpen && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E5E7EB] rounded-lg shadow-lg z-10 overflow-hidden">
                      {roles.map((role) => (
                        <button
                          key={role}
                          onClick={() => {
                            setSelectedRole(role)
                            setIsRoleDropdownOpen(false)
                          }}
                          className="w-full px-4 py-3 text-left text-sm transition-colors first:rounded-t-lg last:rounded-b-lg"
                          style={{
                            fontFamily: "Lato, sans-serif",
                            backgroundColor: selectedRole === role ? "#0F173E" : "transparent",
                            color: selectedRole === role ? "#FFFFFF" : "#000000",
                          }}
                          onMouseEnter={(e) => {
                            if (selectedRole !== role) {
                              e.currentTarget.style.backgroundColor = "#F3F4F6"
                            }
                          }}
                          onMouseLeave={(e) => {
                            if (selectedRole !== role) {
                              e.currentTarget.style.backgroundColor = "transparent"
                            }
                          }}
                        >
                          {role}
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              </div>

              {/* Invite Button */}
              <div className="flex items-center justify-center mt-auto pt-4">
                <button
                  onClick={() => {
                    // Handle invite logic here
                    console.log("Invite user:", email, selectedRole)
                    setShowInviteModal(false)
                    setEmail("")
                    setSelectedRole("Captain")
                  }}
                  className="w-full h-12 rounded-full text-sm font-medium text-white transition-colors"
                  style={{
                    backgroundColor: "#0F173E",
                    fontFamily: "Lato, sans-serif",
                  }}
                >
                  Invite
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

