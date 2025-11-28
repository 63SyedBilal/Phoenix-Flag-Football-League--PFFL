"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Bell } from "lucide-react"

interface BellNotificationButtonProps {
  notificationRoute?: string
  useSuperadminPayments?: boolean
}

export default function BellNotificationButton({
  notificationRoute,
  useSuperadminPayments = false,
}: BellNotificationButtonProps) {
  const router = useRouter()
  const [notificationCount, setNotificationCount] = useState(0)
  const [isLoading, setIsLoading] = useState(true)
  const [showTooltip, setShowTooltip] = useState(false)

  useEffect(() => {
    const fetchNotificationCount = async () => {
      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setIsLoading(false)
          return
        }

        let count = 0

        // Fetch notifications
        const notificationsResponse = await fetch("/api/notification/all", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (notificationsResponse.ok) {
          const notificationsData = await notificationsResponse.json()
          const notifications = notificationsData.data || []
          count += notifications.filter((n: any) => n.status === "pending").length
        }

        // Fetch unpaid payments
        const paymentsEndpoint = useSuperadminPayments
          ? "/api/superadmin/payments/unpaid"
          : "/api/payments/unpaid"

        const paymentsResponse = await fetch(paymentsEndpoint, {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (paymentsResponse.ok) {
          const paymentsData = await paymentsResponse.json()
          if (paymentsData.success) {
            const payments = paymentsData.data || []
            count += payments.length
          }
        }

        setNotificationCount(count)
      } catch (err) {
        console.error("Error fetching notification count:", err)
      } finally {
        setIsLoading(false)
      }
    }

    fetchNotificationCount()
    
    // Refresh count every 30 seconds
    const interval = setInterval(fetchNotificationCount, 30000)
    return () => clearInterval(interval)
  }, [useSuperadminPayments])

  const handleBellClick = () => {
    const route = notificationRoute || "/pffl/settings/notifications"
    router.push(route)
  }

  return (
    <div className="relative">
      <button
        onClick={handleBellClick}
        onMouseEnter={() => setShowTooltip(true)}
        onMouseLeave={() => setShowTooltip(false)}
        className="w-[48px] h-[48px] p-2.5 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center relative"
      >
        <Bell className="w-5 h-5 text-foreground" />
        {!isLoading && notificationCount > 0 && (
          <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
        )}
      </button>
      {showTooltip && notificationCount > 0 && (
        <div className="absolute right-0 top-full mt-2 px-3 py-1.5 bg-gray-900 text-white text-xs rounded-lg shadow-lg z-50 whitespace-nowrap">
          {notificationCount} {notificationCount === 1 ? "notification" : "notifications"}
        </div>
      )}
    </div>
  )
}

