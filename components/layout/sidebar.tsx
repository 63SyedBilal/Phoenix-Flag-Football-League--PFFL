"use client"

import type React from "react"
import Link from "next/link"

export interface SidebarNavItem {
  label: string
  href: string
  icon: React.ReactNode
  active?: boolean
}

export interface SidebarProps {
  logo?: string
  logoText: string
  navItems: SidebarNavItem[]
  userInfo?: {
    name: string
    email: string
    avatar?: string
  }
  onLogout?: () => void
}

export const Sidebar: React.FC<SidebarProps> = ({ logo, logoText, navItems, userInfo, onLogout }) => {
  return (
    <aside className="w-48 bg-sidebar border-r border-sidebar-border flex flex-col h-screen">
      {/* Logo */}
      <div className="p-6 border-b border-sidebar-border">
        <div className="flex items-center gap-2">
          {logo && <img src={logo || "/placeholder.svg"} alt={logoText} className="w-8 h-8" />}
          <span className="font-bold text-sidebar-foreground">{logoText}</span>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4">
        <ul className="space-y-2">
          {navItems.map((item) => (
            <li key={item.href}>
              <Link
                href={item.href}
                className={`flex items-center gap-3 px-4 py-2 rounded-lg transition ${
                  item.active
                    ? "bg-sidebar-primary text-sidebar-primary-foreground"
                    : "text-sidebar-foreground hover:bg-sidebar-accent"
                }`}
              >
                {item.icon}
                <span className="text-sm font-medium">{item.label}</span>
              </Link>
            </li>
          ))}
        </ul>
      </nav>

      {/* User Info */}
      {userInfo && (
        <div className="p-4 border-t border-sidebar-border">
          <div className="flex items-center gap-3 mb-4">
            {userInfo.avatar && (
              <img src={userInfo.avatar || "/placeholder.svg"} alt={userInfo.name} className="w-10 h-10 rounded-full" />
            )}
            <div className="flex-1 text-sm">
              <p className="font-medium text-sidebar-foreground">{userInfo.name}</p>
              <p className="text-xs text-gray-500">{userInfo.email}</p>
            </div>
          </div>
          {onLogout && (
            <button
              onClick={onLogout}
              className="w-full px-4 py-2 text-sm text-sidebar-foreground hover:bg-sidebar-accent rounded-lg transition"
            >
              Logout
            </button>
          )}
        </div>
      )}
    </aside>
  )
}
