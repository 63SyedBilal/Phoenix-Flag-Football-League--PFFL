"use client"

import { useRouter } from "next/navigation"
import { ChevronRight } from "lucide-react"

export interface SettingsOption {
  name: string
  href: string
}

export interface SettingsListProps {
  options: SettingsOption[]
  onLogout?: () => void
  showLogout?: boolean
}

export default function SettingsList({
  options,
  onLogout,
  showLogout = true,
}: SettingsListProps) {
  const router = useRouter()

  const handleLogout = () => {
    if (onLogout) {
      onLogout()
    } else {
      router.push("/login")
    }
  }

  return (
    <>
      {/* Settings Options */}
      <div className="flex flex-col gap-3">
        {options.map((option) => (
          <button
            key={option.name}
            onClick={() => router.push(option.href)}
            className="w-full bg-white border rounded-xl p-6 flex items-center justify-between hover:bg-gray-50 transition-colors"
            style={{
              borderColor: "rgba(0, 0, 0, 0.12)",
              borderWidth: "1px",
            }}
          >
            <span
              className="font-medium text-foreground"
              style={{
                fontFamily: "Lato, sans-serif",
                fontWeight: 500,
                fontSize: "16px",
                color: "#111827",
              }}
            >
              {option.name}
            </span>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </button>
        ))}
      </div>

      {/* Log out Button */}
      {showLogout && (
        <button
          onClick={handleLogout}
          className="w-full h-[58px] rounded-xl text-white font-medium transition-colors mt-4"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          Log out
        </button>
      )}
    </>
  )
}



