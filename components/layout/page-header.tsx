"use client"

import type React from "react"
import { usePathname } from "next/navigation"
import BellNotificationButton from "@/components/layout/bell-notification-button"

export interface PageHeaderProps {
  title: string
  subtitle?: string
  showBell?: boolean
  showNotificationDot?: boolean
  rightAction?: React.ReactNode
  notificationRoute?: string
  useSuperadminPayments?: boolean
}

export default function PageHeader({
  title,
  subtitle,
  showBell = true,
  showNotificationDot = false,
  rightAction,
  notificationRoute,
  useSuperadminPayments = false,
}: PageHeaderProps) {
  const pathname = usePathname()

  // Determine notification route based on current path
  const getNotificationRoute = () => {
    if (notificationRoute) return notificationRoute
    if (pathname?.startsWith("/superadmin")) {
      return "/superadmin/settings/notifications"
    }
    return "/pffl/settings/notifications"
  }

  return (
    <div className="flex items-start justify-between mb-4">
      <div>
        <h1 className="text-3xl font-bold text-foreground">{title}</h1>
        {subtitle && <p className="text-muted-foreground mt-1">{subtitle}</p>}
      </div>
      {rightAction || (
        showBell && (
          <BellNotificationButton
            notificationRoute={getNotificationRoute()}
            useSuperadminPayments={useSuperadminPayments || pathname?.startsWith("/superadmin")}
          />
        )
      )}
    </div>
  )
}








