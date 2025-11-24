"use client"

import { Bell } from "lucide-react"
import type React from "react"

export interface PageHeaderProps {
  title: string
  subtitle?: string
  showBell?: boolean
  showNotificationDot?: boolean
  rightAction?: React.ReactNode
}

export default function PageHeader({
  title,
  subtitle,
  showBell = true,
  showNotificationDot = false,
  rightAction,
}: PageHeaderProps) {
  return (
    <div className="flex items-start justify-between mb-4">
      <div>
        <h1 className="text-3xl font-bold text-foreground">{title}</h1>
        {subtitle && <p className="text-muted-foreground mt-1">{subtitle}</p>}
      </div>
      {rightAction || (
        showBell && (
          <button className="w-[60px] h-[60px] p-3 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center relative">
            <Bell className="w-5 h-5 text-foreground" />
            {showNotificationDot && (
              <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
            )}
          </button>
        )
      )}
    </div>
  )
}



