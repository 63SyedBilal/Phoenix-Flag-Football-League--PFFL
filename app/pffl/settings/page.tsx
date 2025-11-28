"use client"

import { useRouter } from "next/navigation"
import PageHeader from "@/components/layout/page-header"
import SettingsList from "@/components/layout/settings-list"

const settingsOptions = [
  { name: "Payment History", href: "/pffl/settings/payment-history" },
  { name: "Notifications", href: "/pffl/settings/notifications" },
]

export default function PfflSettingsPage() {
  const router = useRouter()

  const handleLogout = () => {
    // Clear all session data
    localStorage.removeItem("token")
    localStorage.removeItem("user")
    // Redirect to login
    router.push("/login")
  }

  return (
    <div className="flex flex-col gap-3">
      <PageHeader
        title="Settings"
        subtitle="Manage your account and app."
        showNotificationDot={true}
      />

      <SettingsList
        options={settingsOptions}
        onLogout={handleLogout}
      />
    </div>
  )
}








