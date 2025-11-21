"use client"

import type React from "react"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { Home, Trophy, Gamepad2, Users, Settings, Bell } from "lucide-react"

const navigation = [
  { name: "Home", href: "/superadmin", icon: Home },
  { name: "Leagues", href: "/superadmin/leagues", icon: Trophy },
  { name: "Games", href: "/superadmin/games", icon: Gamepad2 },
  { name: "Users", href: "/superadmin/users", icon: Users },
  { name: "Settings", href: "/superadmin/settings", icon: Settings },
]

export default function SuperAdminLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const pathname = usePathname()

  return (
    <div className="flex h-screen bg-background">
      {/* Sidebar */}
      <aside className="w-64 border-r border-border bg-background">
        <div className="flex flex-col h-full p-6">
          {/* Logo */}
          <div className="flex items-center gap-3 mb-8">
            <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center text-white font-bold">
              PF
            </div>
            <span className="text-xl font-bold text-foreground">PFFL</span>
          </div>

          {/* Navigation */}
          <nav className="flex-1 space-y-2">
            {navigation.map((item) => {
              const isActive = pathname === item.href || (item.href !== "/superadmin" && pathname.startsWith(item.href))
              const Icon = item.icon
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`flex items-center gap-3 px-4 py-2.5 rounded-lg transition-colors ${
                    isActive ? "bg-primary text-white" : "text-muted-foreground hover:bg-muted"
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  <span className="font-medium">{item.name}</span>
                </Link>
              )
            })}
          </nav>

          {/* User Profile */}
          <div className="pt-4 border-t border-border">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-muted rounded-full" />
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">Admin User</p>
                <p className="text-xs text-muted-foreground">Super Admin</p>
              </div>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-auto">
        <div className="flex items-center justify-between p-6 border-b border-border bg-background sticky top-0 z-10">
          <div />
          <button className="p-2 hover:bg-muted rounded-lg transition-colors">
            <Bell className="w-5 h-5 text-foreground" />
          </button>
        </div>
        <div className="p-6">{children}</div>
      </main>
    </div>
  )
}
