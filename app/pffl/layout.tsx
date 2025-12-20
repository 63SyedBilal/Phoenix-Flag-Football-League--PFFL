"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import Image from "next/image"
import Link from "next/link"
import { usePathname } from "next/navigation"

const allNavigation = [
  { name: "Home", href: "/pffl/home", icon: "/assets/image/home.svg" },
  { name: "Games", href: "/pffl/games", icon: "/assets/image/games.svg", showForRoles: ["referee", "stat-keeper"] },
  { name: "Leagues", href: "/pffl/leagues", icon: "/assets/image/leagues.svg" },
  { name: "Team", href: "/pffl/team", icon: "/assets/image/users.svg", hideForRoles: ["stat-keeper", "referee"] },
  { name: "Settings", href: "/pffl/settings", icon: "/assets/image/setting.svg" },
]

export default function PfflLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const pathname = usePathname()
  const router = useRouter()
  const [userRole, setUserRole] = useState<string | null>(null)
  const [navigation, setNavigation] = useState(allNavigation)
  const [userName, setUserName] = useState<string>("User")
  const [userEmail, setUserEmail] = useState<string>("user@pffl.com")
  const [userInitials, setUserInitials] = useState<string>("U")
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null)

  // Check authentication on mount and when pathname changes
  useEffect(() => {
    const checkAuth = () => {
      // Check authentication
      const token = localStorage.getItem("token")
      const storedUser = localStorage.getItem("user")
      
      if (!token || !storedUser) {
        // Not authenticated - redirect to 404
        setIsAuthenticated(false)
        router.push("/not-found")
        return
      }

      try {
        const userData = JSON.parse(storedUser)
        setIsAuthenticated(true)
        setUserRole(userData.role)
        
        // Set user name and email
        const firstName = userData.firstName || ""
        const lastName = userData.lastName || ""
        const fullName = `${firstName} ${lastName}`.trim() || userData.email || "User"
        setUserName(fullName)
        setUserEmail(userData.email || "user@pffl.com")
        
        // Set user initials
        const initials = firstName && lastName 
          ? `${firstName[0]}${lastName[0]}`.toUpperCase()
          : (userData.email?.[0] || "U").toUpperCase()
        setUserInitials(initials)
        
        // Filter navigation based on user role
        const filteredNav = allNavigation.filter(item => {
          // Hide if role is in hideForRoles
          if (item.hideForRoles && userData.role) {
            if (item.hideForRoles.includes(userData.role)) {
              return false
            }
          }
          // Show only if role is in showForRoles (if specified)
          if (item.showForRoles && userData.role) {
            return item.showForRoles.includes(userData.role)
          }
          // Show if no showForRoles specified (default behavior)
          return true
        })
        setNavigation(filteredNav)
      } catch (error) {
        console.error("Error parsing user data:", error)
        setIsAuthenticated(false)
        router.push("/not-found")
      }
    }

    checkAuth()

    // Listen for storage changes (logout from other tabs/windows)
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === "token" || e.key === "user") {
        checkAuth()
      }
    }

    window.addEventListener("storage", handleStorageChange)

    return () => {
      window.removeEventListener("storage", handleStorageChange)
    }
  }, [router, pathname]) // Re-check on pathname changes

  // Double-check authentication before rendering (safety check)
  useEffect(() => {
    const token = localStorage.getItem("token")
    const storedUser = localStorage.getItem("user")
    
    if (!token || !storedUser) {
      if (isAuthenticated !== false) {
        setIsAuthenticated(false)
        router.push("/not-found")
      }
    }
  })

  // Don't render content if not authenticated
  if (isAuthenticated === false) {
    return null
  }

  // Show loading state while checking authentication
  if (isAuthenticated === null) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-8 h-8 border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin mx-auto"></div>
        </div>
      </div>
    )
  }

  return (
    <>
      <div className="flex h-screen bg-background">
        {/* Sidebar */}
        <aside className="w-[290px] bg-background">
          <div className="flex flex-col h-full justify-between pt-6 pb-6 px-[14px]">
            {/* Logo Section */}
            <div className="flex flex-col gap-3">
              <div className="flex items-center gap-3" style={{ width: "122px", height: "54px" }}>
                <Image
                  src="/assets/image/logo.svg"
                  alt="PFFL Logo"
                  width={54}
                  height={54}
                  className="w-[54px] h-[54px]"
                />
                <span className="text-[24px] font-bold leading-[100%] text-[#000000]" style={{ fontFamily: "Satoshi, sans-serif", width: "56px", height: "32px" }}>
                  PFFL
                </span>
              </div>

              {/* Navigation */}
              <nav className="w-[262px] flex flex-col gap-2 mt-2">
                {navigation.map((item) => {
                  const isActive = item.href === "/pffl/home"
                    ? pathname === item.href
                    : pathname === item.href || pathname?.startsWith(item.href + "/")

                  return (
                    <Link
                      key={item.name}
                      href={item.href}
                      className="w-[262px] h-[52px] px-[14px] flex items-center gap-3 transition-colors"
                    >
                      <div className="w-6 h-6 flex items-center justify-center">
                        <img
                          src={item.icon}
                          alt={item.name}
                          width={24}
                          height={24}
                          className="w-6 h-6"
                          style={{
                            filter: isActive
                              ? "brightness(0) saturate(100%) invert(48%) sepia(79%) saturate(2476%) hue-rotate(202deg) brightness(98%) contrast(96%)"
                              : "brightness(0) saturate(100%)",
                            opacity: isActive ? 1 : 0.7,
                          }}
                        />
                      </div>
                      <span
                        className={`font-medium ${
                          isActive ? "text-[#3B82F6]" : "text-[#111827]"
                        }`}
                      >
                        {item.name}
                      </span>
                    </Link>
                  )
                })}
              </nav>
            </div>

            {/* User Profile */}
            <div className="pt-4">
              <div className="flex items-center gap-3 px-[14px] py-2">
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
                  <span className="text-sm font-medium text-white">{userInitials}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-foreground truncate">{userName}</p>
                  <p className="text-xs text-muted-foreground truncate">{userEmail}</p>
                </div>
              </div>
            </div>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-auto bg-gray-50">
          <div className="p-6">{children}</div>
        </main>
      </div>
    </>
  )
}

