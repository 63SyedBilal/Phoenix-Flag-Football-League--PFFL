"use client"

import { useRouter } from "next/navigation"
import PageHeader from "@/components/layout/page-header"
import SettingsList from "@/components/layout/settings-list"

const settingsOptions = [
  { name: "Notifications", href: "/superadmin/settings/notifications" },
  { name: "Payment History", href: "/superadmin/settings/payment-history" },
]

export default function SuperAdminSettingsPage() {
  const router = useRouter()

  const handleLogout = () => {
    // Clear localStorage
    localStorage.removeItem("token")
    localStorage.removeItem("user")
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
