"use client"

import { useState, useEffect } from "react"
import { Search, UserPlus } from "lucide-react"
import Image from "next/image"
import UsersCard from "@/components/cards/userscard"
import BellNotificationButton from "@/components/layout/bell-notification-button"
import LoadingSpinner from "@/components/ui/loading-spinner"

const filterOptions = ["All Users", "Players", "Captains", "Referees", "Stat Keeper"]

interface User {
  _id: string
  firstName: string
  lastName: string
  email: string
  role: string
  profile?: {
    image?: string
    paymentStatus?: string
  }
  team?: {
    teamName?: string
    league?: {
      leagueName?: string
    }
  }
}

export default function UsersPage() {
  const [activeFilter, setActiveFilter] = useState("All Users")
  const [searchQuery, setSearchQuery] = useState("")
  const [showInviteModal, setShowInviteModal] = useState(false)
  const [email, setEmail] = useState("")
  const [selectedRole, setSelectedRole] = useState("Captain")
  const [isRoleDropdownOpen, setIsRoleDropdownOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [success, setSuccess] = useState("")
  const [users, setUsers] = useState<User[]>([])
  const [isLoadingUsers, setIsLoadingUsers] = useState(true)

  const roles = ["Captain", "Referee", "Stat Keeper", "Player", "Free Agent"]

  // Map UI role names to backend schema values
  const roleMap: { [key: string]: string } = {
    "Captain": "captain",
    "Player": "player",
    "Referee": "referee",
    "Stat Keeper": "stat-keeper",
    "Free Agent": "free-agent",
  }

  // Map backend roles to UI role names
  const backendToUIRole: { [key: string]: string } = {
    "captain": "Captain",
    "player": "Player",
    "referee": "Referee",
    "stat-keeper": "Stat Keeper",
    "free-agent": "Free Agent",
  }

  // Map UI filter to backend role
  const filterToRole: { [key: string]: string | null } = {
    "All Users": null,
    "Players": "player",
    "Captains": "captain",
    "Referees": "referee",
    "Stat Keeper": "stat-keeper",
  }

  // Role colors and borders mapping
  const roleStyleMap: { [key: string]: { color: string; border: string } } = {
    "Captain": { color: "#FEF3C7", border: "#FDE68A" },
    "Player": { color: "#DBEAFE", border: "#93C5FD" },
    "Referee": { color: "#E9D5FF", border: "#C084FC" },
    "Stat Keeper": { color: "#D1FAE5", border: "#A7F3D0" },
    "Free Agent": { color: "#FED7AA", border: "#FDBA74" },
  }

  // Filter users based on search query and active filter
  const filteredUsers = users.filter((user) => {
    // Filter by role
    const roleFilter = filterToRole[activeFilter]
    if (roleFilter && user.role !== roleFilter) {
      return false
    }

    // Filter by search query (name or email)
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      const fullName = `${user.firstName} ${user.lastName}`.toLowerCase()
      const email = user.email.toLowerCase()
      if (!fullName.includes(query) && !email.includes(query)) {
        return false
      }
    }

    return true
  })

  // Fetch users from API
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setIsLoadingUsers(true)
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login")
          setIsLoadingUsers(false)
          return
        }

        // Fetch all users
        const response = await fetch("/api/user", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}))
          throw new Error(errorData.error || "Failed to fetch users")
        }

        const data = await response.json()
        const usersData = data.data || []

        // Fetch profiles for all users to get images
        const profilesResponse = await fetch("/api/profile", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        const profilesData = profilesResponse.ok ? await profilesResponse.json() : { data: [] }
        const profiles = profilesData.data || []

        // Create a map of userId to profile
        const profileMap = new Map()
        profiles.forEach((profile: any) => {
          if (profile.userId) {
            profileMap.set(profile.userId.toString(), profile)
          }
        })

        // Combine users with their profiles
        const usersWithProfiles = usersData.map((user: any) => {
          const profile = profileMap.get(user._id.toString())
          return {
            ...user,
            profile: profile ? { 
              image: profile.image,
              paymentStatus: profile.paymentStatus 
            } : undefined,
          }
        })

        setUsers(usersWithProfiles)
      } catch (err: any) {
        console.error("Error fetching users:", err)
        setError(err.message || "Failed to fetch users")
      } finally {
        setIsLoadingUsers(false)
      }
    }

    fetchUsers()
  }, [])

  const handleInvite = async () => {
    if (!email || !selectedRole) {
      setError("Please fill in all fields")
      return
    }

    setIsLoading(true)
    setError("")
    setSuccess("")

    try {
      // Map the UI role to backend role format
      const backendRole = roleMap[selectedRole] || selectedRole.toLowerCase().replace(/\s+/g, "-")
      
      const response = await fetch("/api/invite", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email.trim(),
          role: backendRole, // Send the mapped role to backend
        }),
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "Failed to invite user")
        setIsLoading(false)
        return
      }

      setSuccess("User invited successfully! Password sent to email.")
      setTimeout(() => {
        setShowInviteModal(false)
        setEmail("")
        setSelectedRole("Captain")
        setError("")
        setSuccess("")
        // Refresh user list
        window.location.reload()
      }, 2000)
    } catch (error) {
      console.error("Invite error:", error)
      setError("An error occurred. Please try again.")
      setIsLoading(false)
    }
  }

  return (
    <div className="flex flex-col gap-3">
      {/* Header Section */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Users</h1>
          <p className="text-muted-foreground mt-1">Manage all users.</p>
        </div>
        <div className="flex items-center gap-3">
          <BellNotificationButton notificationRoute="/superadmin/settings/notifications" useSuperadminPayments={true} />
          <button
            onClick={() => setShowInviteModal(true)}
            className="flex items-center justify-center gap-2 text-white font-medium rounded-xl"
            style={{
              width: "100px",
              height: "44px",
              gap: "7px",
              borderRadius: "14px",
              backgroundColor: "#3B82F6",
            }}
          >
            <UserPlus className="w-4 h-4" />
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
      {isLoadingUsers ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ color: "#6B7280" }}>Loading users...</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filteredUsers.length === 0 ? (
            <div className="flex items-center justify-center py-8">
              <p style={{ color: "#6B7280" }}>No users found</p>
            </div>
          ) : (
            filteredUsers.map((user) => {
              const fullName = `${user.firstName} ${user.lastName}`
              const uiRole = backendToUIRole[user.role] || user.role
              const roleStyle = roleStyleMap[uiRole] || { color: "#F3F4F6", border: "#D1D5DB" }
              
              // Generate avatar URL from name if no profile image
              const avatar = user.profile?.image || `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(fullName)}`
              
              // Build dynamic roles array - only include the main role
              const roles = [uiRole]
              const roleColors = [roleStyle.color]
              const roleBorders = [roleStyle.border]
              
              // Optionally add status badges based on user data
              // You can add more logic here based on profile status, payment status, etc.
              if (user.profile?.paymentStatus === "paid") {
                roles.push("Paid")
                roleColors.push("#D1FAE5")
                roleBorders.push("#A7F3D0")
              } else if (user.profile?.paymentStatus === "pending") {
                roles.push("Pending")
                roleColors.push("#FED7AA")
                roleBorders.push("#FDBA74")
              }
              
              return (
                <UsersCard
                  key={user._id}
                  id={user._id}
                  name={fullName}
                  email={user.email}
                  league={user.team?.league?.leagueName || user.team?.teamName || null}
                  avatar={avatar}
                  roles={roles}
                  roleColors={roleColors}
                  roleBorders={roleBorders}
                />
              )
            })
          )}
        </div>
      )}

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

              {/* Error Message */}
              {error && (
                <div className="p-3 rounded-md bg-red-50 border border-red-200">
                  <p className="text-sm text-red-600" style={{ fontFamily: "Lato, sans-serif" }}>
                    {error}
                  </p>
                </div>
              )}

              {/* Success Message */}
              {success && (
                <div className="p-3 rounded-md bg-green-50 border border-green-200">
                  <p className="text-sm text-green-600" style={{ fontFamily: "Lato, sans-serif" }}>
                    {success}
                  </p>
                </div>
              )}

              {/* Invite Button */}
              <div className="flex items-center justify-center mt-auto pt-4">
                <button
                  onClick={handleInvite}
                  disabled={isLoading}
                  className="w-full h-12 rounded-full text-sm font-medium text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  style={{
                    backgroundColor: "#0F173E",
                    fontFamily: "Lato, sans-serif",
                  }}
                >
                  {isLoading ? "Sending..." : "Invite"}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

