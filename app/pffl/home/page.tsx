"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import PaymentReminderCard from "@/components/cards/payment-reminder-card"
import PageHeader from "@/components/layout/page-header"
import InvitationCard from "@/components/cards/invitation-card"
import LeagueInvitationCard from "@/components/cards/league-invitation-card"

interface PaymentReminder {
  _id: string
  id: string
  amount: string
  leagueDetails: {
    name: string
    logo: string
    format: string
    startDate: string
    endDate: string
    leagueFee: string
    status: "active" | "pending"
  }
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
  const [paymentReminders, setPaymentReminders] = useState<PaymentReminder[]>([])
  const [isLoadingPayments, setIsLoadingPayments] = useState(true)

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

  // Fetch invitation notifications for players, referees, stat keepers, and captains
  useEffect(() => {
    const fetchInvitations = async () => {
      try {
        const userData = JSON.parse(localStorage.getItem("user") || "{}")
        const userRole = userData.role
        
        // Fetch for players, free-agents, referees, stat-keepers, and captains
        // These roles can receive team or league invitations
        const allowedRoles = ["player", "free-agent", "referee", "stat-keeper", "captain"]
        if (!allowedRoles.includes(userRole)) {
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
        
        // Filter for pending team and league invitations based on user role
        const currentUserRole = userData.role
        const teamInvitations = allNotifications.filter((n: Notification) => {
          if (n.status !== "pending") return false
          
          // Players and free-agents can receive team invites
          if ((currentUserRole === "player" || currentUserRole === "free-agent") && n.type === "TEAM_INVITE") {
            return true
          }
          
          // Referees can receive league referee invites
          if (currentUserRole === "referee" && n.type === "LEAGUE_REFEREE_INVITE") {
            return true
          }
          
          // Stat keepers can receive league stat keeper invites
          if (currentUserRole === "stat-keeper" && n.type === "LEAGUE_STATKEEPER_INVITE") {
            return true
          }
          
          // Captains can receive league team invites
          if (currentUserRole === "captain" && n.type === "LEAGUE_TEAM_INVITE") {
            return true
          }
          
          return false
        })
        
        setInvitations(teamInvitations)
        setIsLoadingInvitations(false)
      } catch (err) {
        console.error("Error fetching invitations:", err)
        setIsLoadingInvitations(false)
      }
    }

    fetchInvitations()
  }, [])

  // Fetch payment reminders for players and captains
  useEffect(() => {
    const fetchPaymentReminders = async () => {
      try {
        const userData = JSON.parse(localStorage.getItem("user") || "{}")
        const userRole = userData.role
        
        // Only fetch for players and captains
        if (userRole !== "player" && userRole !== "captain") {
          setIsLoadingPayments(false)
          return
        }

        const token = localStorage.getItem("token")
        if (!token) {
          setIsLoadingPayments(false)
          return
        }

        const response = await fetch("/api/payment/reminders", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          setIsLoadingPayments(false)
          return
        }

        const data = await response.json()
        setPaymentReminders(data.data || [])
        setIsLoadingPayments(false)
      } catch (err) {
        console.error("Error fetching payment reminders:", err)
        setIsLoadingPayments(false)
      }
    }

    fetchPaymentReminders()
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

      {/* Team and League Invitations */}
      {invitations.length > 0 && (
        <div className="space-y-3 mb-4">
          <h2 className="text-xl font-bold text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
            {userRole === "stat-keeper" ? "League Stat Keeper Invitations" :
             userRole === "referee" ? "League Referee Invitations" :
             userRole === "captain" ? "League Team Invitations" :
             "Invitations"}
          </h2>
          {invitations.map((invitation) => {
            // Skip if sender is not populated
            if (!invitation.sender) {
              console.warn("Invitation missing sender:", invitation._id)
              return null
            }
            
            const senderName = invitation.sender
              ? `${invitation.sender.firstName || ""} ${invitation.sender.lastName || ""}`.trim() || "Unknown User"
              : "Unknown User"
            
            // Display team invitations
            if (invitation.type === "TEAM_INVITE" && invitation.team) {
              return (
                <InvitationCard
                  key={invitation._id}
                  id={invitation._id}
                  senderName={senderName}
                  teamName={invitation.team.teamName}
                  teamImage={invitation.team.image}
                  date={invitation.createdAt}
                  onAccept={handleAcceptInvite}
                  onDecline={handleDeclineInvite}
                  isProcessing={processingId === invitation._id}
                />
              )
            }
            
            // Display league invitations
            if (
              (invitation.type === "LEAGUE_REFEREE_INVITE" ||
                invitation.type === "LEAGUE_STATKEEPER_INVITE" ||
                invitation.type === "LEAGUE_TEAM_INVITE") &&
              invitation.league
            ) {
              return (
                <LeagueInvitationCard
                  key={invitation._id}
                  id={invitation._id}
                  senderName={senderName}
                  leagueName={invitation.league.leagueName}
                  leagueLogo={invitation.league.logo}
                  invitationType={invitation.type as "LEAGUE_REFEREE_INVITE" | "LEAGUE_STATKEEPER_INVITE" | "LEAGUE_TEAM_INVITE"}
                  teamName={invitation.team?.teamName}
                  date={invitation.createdAt}
                  onAccept={handleAcceptInvite}
                  onDecline={handleDeclineInvite}
                  isProcessing={processingId === invitation._id}
                />
              )
            }
            
            return null
          })}
        </div>
      )}

      {/* Payment Reminders */}
      {paymentReminders.length > 0 && (
        <div className="space-y-3">
          <h2 className="text-xl font-bold text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
            Payment Reminders
          </h2>
          {isLoadingPayments ? (
            <div className="text-center py-4 text-gray-500">Loading payment reminders...</div>
          ) : (
            paymentReminders.map((reminder) => (
              <PaymentReminderCard
                key={reminder._id}
                id={reminder._id}
                amount={reminder.amount}
                leagueDetails={reminder.leagueDetails}
                onPayNow={() => router.push(`/pffl/settings/payment/${reminder._id}`)}
              />
            ))
          )}
        </div>
      )}
    </div>
  )
}

