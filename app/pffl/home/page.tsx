"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import PaymentReminderCard from "@/components/cards/payment-reminder-card"
import PageHeader from "@/components/layout/page-header"
import InvitationCard from "@/components/cards/invitation-card"

const mockPaymentReminder = {
  id: "1",
  amount: "$250",
  leagueDetails: {
    name: "Champions Cup 2025",
    logo: "/placeholder-logo.png",
    format: "5v5",
    startDate: "10 December 2025",
    endDate: "25 February 2026",
    leagueFee: "$250",
    status: "active" as const,
  },
}

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
  team: {
    _id: string
    teamName: string
    image?: string
  }
  type: string
  status: "pending" | "accepted" | "rejected"
  format?: string
  createdAt: string
  updatedAt: string
}

export default function PfflHomePage() {
  const router = useRouter()
  const [userName, setUserName] = useState("")
  const [userRole, setUserRole] = useState("")
  const [invitations, setInvitations] = useState<Notification[]>([])
  const [isLoadingInvitations, setIsLoadingInvitations] = useState(true)
  const [processingId, setProcessingId] = useState<string | null>(null)

  useEffect(() => {
    const userData = JSON.parse(localStorage.getItem("user") || "{}")
    if (userData.firstName) {
      setUserName(userData.firstName)
    }
    if (userData.role) {
      // Capitalize first letter of role
      const role = userData.role.charAt(0).toUpperCase() + userData.role.slice(1)
      setUserRole(role)
    }
  }, [])

  // Fetch invitation notifications for players
  useEffect(() => {
    const fetchInvitations = async () => {
      try {
        const userData = JSON.parse(localStorage.getItem("user") || "{}")
        // Only fetch for players and free-agents
        if (userData.role !== "player" && userData.role !== "free-agent") {
          setIsLoadingInvitations(false)
          return
        }

        const token = localStorage.getItem("token")
        if (!token) {
          setIsLoadingInvitations(false)
          return
        }

        const response = await fetch("/api/notification/all", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          setIsLoadingInvitations(false)
          return
        }

        const data = await response.json()
        const allNotifications = data.data || []
        
        // Filter for pending team invitations
        const teamInvitations = allNotifications.filter(
          (n: Notification) => n.type === "TEAM_INVITE" && n.status === "pending"
        )
        
        setInvitations(teamInvitations)
        setIsLoadingInvitations(false)
      } catch (err) {
        console.error("Error fetching invitations:", err)
        setIsLoadingInvitations(false)
      }
    }

    fetchInvitations()
  }, [])

  const handleAcceptInvite = async (notifId: string) => {
    try {
      const token = localStorage.getItem("token")
      if (!token) {
        alert("Please login")
        return
      }

      setProcessingId(notifId)

      const response = await fetch(`/api/notification/accept/${notifId}`, {
        method: "PUT",
        headers: {
          "Authorization": `Bearer ${token}`,
        },
      })

      const data = await response.json()

      if (response.ok) {
        // Remove the notification from the list
        setInvitations((prev) => prev.filter((inv) => inv._id !== notifId))
        alert("Invite accepted successfully! You have been added to the team.")
        // Optionally redirect to team page
        router.push("/pffl/team")
      } else {
        alert(data.error || "Failed to accept invite")
      }
    } catch (err) {
      console.error("Error accepting invite:", err)
      alert("An error occurred while accepting the invite")
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
        // Remove the notification from the list
        setInvitations((prev) => prev.filter((inv) => inv._id !== notifId))
        alert("Invite declined")
      } else {
        alert(data.error || "Failed to decline invite")
      }
    } catch (err) {
      console.error("Error declining invite:", err)
      alert("An error occurred while declining the invite")
    } finally {
      setProcessingId(null)
    }
  }

  return (
    <div className="flex flex-col gap-3">
      {/* Welcome Header */}
      <div className="mb-4">
        <h1 className="text-3xl font-bold text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
          Welcome {userName || "User"}
        </h1>
        {userRole && (
          <p 
            className="text-muted-foreground mt-1" 
            style={{ 
              fontFamily: "Lato, sans-serif",
              fontSize: "10px",
              lineHeight: "12px",
              color: "#6B7280"
            }}
          >
            {userRole}
          </p>
        )}
      </div>

      {/* Team Invitations - Only show for players */}
      {invitations.length > 0 && (
        <div className="space-y-3 mb-4">
          <h2 className="text-xl font-bold text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
            Team Invitations
          </h2>
          {invitations.map((invitation) => (
            <InvitationCard
              key={invitation._id}
              id={invitation._id}
              senderName={`${invitation.sender.firstName} ${invitation.sender.lastName}`}
              teamName={invitation.team.teamName}
              teamImage={invitation.team.image}
              date={invitation.createdAt}
              onAccept={handleAcceptInvite}
              onDecline={handleDeclineInvite}
              isProcessing={processingId === invitation._id}
            />
          ))}
        </div>
      )}

      {/* Payment Reminder Card */}
      <div className="space-y-3">
        <PaymentReminderCard
          id={mockPaymentReminder.id}
          amount={mockPaymentReminder.amount}
          leagueDetails={mockPaymentReminder.leagueDetails}
          onPayNow={() => router.push(`/pffl/settings/payment/${mockPaymentReminder.id}`)}
        />
      </div>
    </div>
  )
}

