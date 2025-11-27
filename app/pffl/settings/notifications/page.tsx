"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Search } from "lucide-react"
import Image from "next/image"
import NotificationCardPayment from "@/components/cards/notification-card-payment"
import InvitationCard from "@/components/cards/invitation-card"
import LeagueInvitationCard from "@/components/cards/league-invitation-card"

interface Notification {
  _id: string
  sender: {
    _id: string
    firstName: string
    lastName: string
    email: string
  }
  receiver: {
    _id: string
    firstName: string
    lastName: string
    email: string
  }
  team?: {
    _id: string
    teamName: string
    image?: string
  }
  league?: {
    _id: string
    leagueName: string
    logo?: string
  }
  type: string
  status: "pending" | "accepted" | "rejected"
  createdAt: string
  updatedAt: string
}

const filterOptions = ["All Notifications", "Team Invitations", "League Invitations", "Payment Required"]

export default function PfflNotificationsPage() {
  const router = useRouter()
  const [activeFilter, setActiveFilter] = useState("All Notifications")
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedItem, setSelectedItem] = useState("Select Item")
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState("")
  const [processingId, setProcessingId] = useState<string | null>(null)

  // Fetch notifications
  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to view notifications")
          setIsLoading(false)
          return
        }

        const response = await fetch("/api/notification/all", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: "Unknown error" }))
          throw new Error(errorData.error || "Failed to fetch notifications")
        }

        const data = await response.json()
        setNotifications(data.data || [])
        setIsLoading(false)
      } catch (err: any) {
        console.error("Error fetching notifications:", err)
        setError(err.message || "An error occurred while fetching notifications")
        setIsLoading(false)
      }
    }

    fetchNotifications()
  }, [])

  const handlePayNow = (id: string) => {
    router.push(`/pffl/settings/payment/${id}`)
  }

  const handleAcceptInvite = async (notifId: string) => {
    try {
      const token = localStorage.getItem("token")
      if (!token) {
        alert("Please login")
        return
      }

      setProcessingId(notifId)

      console.log("Accepting invite with ID:", notifId)

      const response = await fetch(`/api/notification/accept/${notifId}`, {
        method: "PUT",
        headers: {
          "Authorization": `Bearer ${token}`,
        },
      })

      const data = await response.json()
      console.log("Accept invite response:", data)

      if (response.ok) {
        // Remove accepted notification from list
        setNotifications((prev) => prev.filter((n) => n._id !== notifId))
        
        // Get the notification type to show appropriate message
        const acceptedNotification = notifications.find((n) => n._id === notifId)
        if (acceptedNotification) {
          if (acceptedNotification.type === "TEAM_INVITE") {
            alert("Invite accepted! You have been added to the team.")
            router.push("/pffl/team")
          } else if (
            acceptedNotification.type === "LEAGUE_REFEREE_INVITE" ||
            acceptedNotification.type === "LEAGUE_STATKEEPER_INVITE" ||
            acceptedNotification.type === "LEAGUE_TEAM_INVITE"
          ) {
            alert(data.message || "Invite accepted successfully!")
            // Refresh to show updated state
            router.refresh()
          } else {
            alert("Invite accepted successfully!")
          }
        } else {
          alert("Invite accepted successfully!")
        }
      } else {
        console.error("Failed to accept invite:", data)
        alert(data.error || "Failed to accept invite")
      }
    } catch (err) {
      console.error("Error accepting invite:", err)
      alert("An error occurred while accepting invite")
    } finally {
      setProcessingId(null)
    }
  }

  const handleDeclineInvite = async (notifId: string) => {
    try {
      const token = localStorage.getItem("token")
      if (!token) {
        alert("Please login")
        return
      }

      setProcessingId(notifId)

      const response = await fetch(`/api/notification/reject/${notifId}`, {
        method: "PUT",
        headers: {
          "Authorization": `Bearer ${token}`,
        },
      })

      const data = await response.json()

      if (response.ok) {
        // Remove rejected notification from list
        setNotifications((prev) => prev.filter((n) => n._id !== notifId))
        alert("Invite declined")
      } else {
        alert(data.error || "Failed to decline invite")
      }
    } catch (err) {
      console.error("Error declining invite:", err)
      alert("An error occurred while declining invite")
    } finally {
      setProcessingId(null)
    }
  }

  // Filter notifications based on active filter
  const filteredNotifications = notifications.filter((notification) => {
    if (activeFilter === "Team Invitations") {
      return notification.type === "TEAM_INVITE" && notification.status === "pending"
    }
    if (activeFilter === "League Invitations") {
      return (
        (notification.type === "LEAGUE_REFEREE_INVITE" ||
          notification.type === "LEAGUE_STATKEEPER_INVITE" ||
          notification.type === "LEAGUE_TEAM_INVITE") &&
        notification.status === "pending"
      )
    }
    if (activeFilter === "Payment Required") {
      return false // Payment notifications would be handled separately
    }
    return true // All Notifications
  })

  // Filter by search query
  const searchFilteredNotifications = filteredNotifications.filter((notification) => {
    if (!searchQuery) return true
    const searchLower = searchQuery.toLowerCase()
    return (
      (notification.sender && notification.sender.firstName && notification.sender.firstName.toLowerCase().includes(searchLower)) ||
      (notification.sender && notification.sender.lastName && notification.sender.lastName.toLowerCase().includes(searchLower)) ||
      (notification.team && notification.team.teamName && notification.team.teamName.toLowerCase().includes(searchLower)) ||
      (notification.league && notification.league.leagueName && notification.league.leagueName.toLowerCase().includes(searchLower))
    )
  })

  return (
    <div className="flex flex-col gap-3">
      {/* Back Arrow */}
      <button
        onClick={() => router.back()}
        className="w-[50px] h-[50px] p-[10px] rounded-full bg-[#F2F2F2] hover:bg-gray-200 transition-colors flex items-center justify-center flex-shrink-0 mb-2"
      >
        <Image src="/assets/image/Back arrow.svg" alt="Back" width={24} height={24} />
      </button>

      {/* Header */}
      <div className="mb-4">
        <h1 className="text-3xl font-bold text-foreground">Notifications</h1>
        <p className="text-muted-foreground mt-1">View and manage your notifications</p>
      </div>

      {/* Search Bar and Dropdown in Same Row */}
      <div className="flex items-center gap-3">
        <div className="relative flex-[4]">
          <input
            type="text"
            placeholder="Search notifications..."
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
        <div className="relative flex-[1]">
          <select
            value={selectedItem}
            onChange={(e) => setSelectedItem(e.target.value)}
            className="w-full h-[46.33px] px-4 pr-10 rounded-xl border-[0.67px] border-[#E5E7EB] bg-white appearance-none cursor-pointer"
            style={{ fontFamily: "Lato, sans-serif" }}
          >
            <option>Select Item</option>
            <option>Option 1</option>
            <option>Option 2</option>
            <option>Option 3</option>
          </select>
          <Image
            src="/assets/image/arrow-down.svg"
            alt="dropdown"
            width={16}
            height={16}
            className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none"
          />
        </div>
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

      {/* Notification Cards */}
      {isLoading ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>Loading notifications...</p>
        </div>
      ) : error ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ fontFamily: "Lato, sans-serif", color: "#EF4444" }}>{error}</p>
        </div>
      ) : searchFilteredNotifications.length === 0 ? (
        <div className="flex items-center justify-center py-8">
          <p style={{ fontFamily: "Lato, sans-serif", color: "#6B7280" }}>No notifications found</p>
        </div>
      ) : (
        <div className="space-y-3">
          {searchFilteredNotifications.map((notification) => {
            const notificationId = notification._id?.toString() || notification._id
            
            // Skip if sender is not populated
            if (!notification.sender) {
              console.warn("Notification missing sender:", notificationId)
              return null
            }
            
            const senderName = notification.sender
              ? `${notification.sender.firstName || ""} ${notification.sender.lastName || ""}`.trim() || "Unknown User"
              : "Unknown User"
            
            // Show invitation cards for team invites
            if (notification.type === "TEAM_INVITE" && notification.status === "pending" && notification.team) {
              return (
                <InvitationCard
                  key={notificationId}
                  id={notificationId}
                  senderName={senderName}
                  teamName={notification.team.teamName}
                  teamImage={notification.team.image}
                  date={notification.createdAt}
                  onAccept={handleAcceptInvite}
                  onDecline={handleDeclineInvite}
                  isProcessing={processingId === notificationId}
                />
              )
            }
            
            // Show league invitation cards
            if (
              (notification.type === "LEAGUE_REFEREE_INVITE" ||
                notification.type === "LEAGUE_STATKEEPER_INVITE" ||
                notification.type === "LEAGUE_TEAM_INVITE") &&
              notification.status === "pending" &&
              notification.league
            ) {
              return (
                <LeagueInvitationCard
                  key={notificationId}
                  id={notificationId}
                  senderName={senderName}
                  leagueName={notification.league.leagueName}
                  leagueLogo={notification.league.logo}
                  invitationType={notification.type as "LEAGUE_REFEREE_INVITE" | "LEAGUE_STATKEEPER_INVITE" | "LEAGUE_TEAM_INVITE"}
                  teamName={notification.team?.teamName}
                  date={notification.createdAt}
                  onAccept={handleAcceptInvite}
                  onDecline={handleDeclineInvite}
                  isProcessing={processingId === notificationId}
                />
              )
            }
            
            // Add other notification types here (payment, etc.)
            return null
          })}
        </div>
      )}
    </div>
  )
}
