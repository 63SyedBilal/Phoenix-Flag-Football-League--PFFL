"use client"

import type React from "react"
import Image from "next/image"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { Bell } from "lucide-react"

const navigation = [
  { name: "Home", href: "/pffl/captain/home", icon: "/assets/image/home.svg" },
  { name: "Leagues", href: "/pffl/captain/leagues", icon: "/assets/image/leagues.svg" },
  { name: "Games", href: "/pffl/captain/games", icon: "/assets/image/games.svg" },
  { name: "Team", href: "/pffl/captain/team", icon: "/assets/image/users.svg" },
  { name: "Settings", href: "/pffl/captain/settings", icon: "/assets/image/setting.svg" },
]

export default function CaptainLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const pathname = usePathname()

  return (
    <>
      <div className="flex h-screen bg-background">
        {/* Sidebar */}
        <aside className="w-[290px] border-r border-border bg-background">
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
                  const isActive = item.href === "/pffl/captain/home"
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
            <div className="pt-4 border-t border-border">
              <div className="flex items-center gap-3 px-[14px] py-2">
                <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                  <span className="text-sm font-medium text-gray-600">C</span>
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-foreground">Captain</p>
                  <p className="text-xs text-muted-foreground">captain@pffl.com</p>
                </div>
              </div>
            </div>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-auto bg-gray-50">
          {pathname !== "/pffl/captain/home" && pathname !== "/pffl/captain/leagues" && pathname !== "/pffl/captain/team" && pathname !== "/pffl/captain/settings" && !pathname?.startsWith("/pffl/captain/settings/") && !pathname?.startsWith("/pffl/captain/signup") && !pathname?.startsWith("/pffl/captain/complete-profile") && !pathname?.startsWith("/pffl/captain/complete-captain-profile") && (
            <div className="flex items-center justify-between p-6 border-b border-border bg-background sticky top-0 z-10">
              <div />
              <button className="p-2 hover:bg-muted rounded-lg transition-colors">
                <Bell className="w-5 h-5 text-foreground" />
              </button>
            </div>
          )}
          <div className={pathname === "/pffl/captain/home" || pathname === "/pffl/captain/leagues" || pathname === "/pffl/captain/team" || pathname === "/pffl/captain/settings" || pathname?.startsWith("/pffl/captain/settings/") || pathname?.startsWith("/pffl/captain/signup") || pathname?.startsWith("/pffl/captain/complete-profile") || pathname?.startsWith("/pffl/captain/complete-captain-profile") ? "p-6" : "p-6"}>{children}</div>
        </main>
      </div>
    </>
  )
}

