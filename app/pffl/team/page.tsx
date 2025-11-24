"use client"

import { useState } from "react"
import { Bell, UserPlus, MoreVertical } from "lucide-react"
import Image from "next/image"
import TeamUsersCard from "@/components/cards/team-users-card"
import PageHeader from "@/components/layout/page-header"

const mockTeamMembers = [
  {
    id: "1",
    name: "#10 James Richardson",
    email: "james.r@pffl.com",
    position: "Rusher +5 more",
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=James",
    role: "Captain" as const,
    paymentStatus: "Paid" as const,
    showClockIcon: false,
  },
  {
    id: "2",
    name: "#10 George Martin",
    email: "georgemartin.j@pffl.com",
    position: "Rusher +5 more",
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=George",
    role: "Player" as const,
    paymentStatus: "Paid" as const,
    showClockIcon: true,
  },
  {
    id: "3",
    name: "#10 George Martin",
    email: "georgemartin.j@pffl.com",
    position: "Rusher +5 more",
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=George2",
    role: "Player" as const,
    paymentStatus: "Paid" as const,
    showClockIcon: true,
  },
  {
    id: "4",
    name: "#27 George Lee",
    email: "georgelee.j@pffl.com",
    position: "Rusher +5 more",
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=GeorgeLee",
    role: "Player" as const,
    paymentStatus: "Unpaid" as const,
    showClockIcon: true,
  },
  {
    id: "5",
    name: "#10 George Martin",
    email: "georgemartin.j@pffl.com",
    position: "Rusher +5 more",
    avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=George3",
    role: "Player" as const,
    paymentStatus: "Paid" as const,
    showClockIcon: true,
  },
]

export default function PfflTeamPage() {
  const [showInviteModal, setShowInviteModal] = useState(false)
  const [selectedFormat, setSelectedFormat] = useState("5v5")
  const currentRoster = 5
  const maxRoster = 8

  return (
    <div className="flex flex-col gap-3">
      {/* Header Section */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-3xl font-bold text-foreground">My Team</h1>
          <p className="text-muted-foreground mt-1">View your team roster and player details.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="w-[60px] h-[60px] p-3 rounded-xl border border-[#0000001F] bg-white hover:bg-gray-50 transition-colors flex items-center justify-center relative">
            <Bell className="w-5 h-5 text-foreground" />
            <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
          </button>
          <button
            onClick={() => setShowInviteModal(true)}
            className="flex items-center justify-center gap-2 text-white font-medium rounded-xl"
            style={{
              width: "111px",
              height: "50px",
              gap: "8px",
              borderRadius: "14px",
              backgroundColor: "#3B82F6",
            }}
          >
            <UserPlus className="w-5 h-5" />
            <span>Invite</span>
          </button>
        </div>
      </div>

      {/* Team Information Section */}
      <div className="mb-4">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            {/* Team Logo */}
            <div className="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 overflow-hidden border-2 border-dashed border-gray-300">
              <Image
                src="/placeholder-logo.png"
                alt="Team Logo"
                width={48}
                height={48}
                className="w-12 h-12 rounded-full object-cover"
              />
            </div>
            {/* Team Name */}
            <h2 className="text-2xl font-bold text-foreground">STA</h2>
          </div>
          <div className="flex items-center gap-3">
            {/* Roster Count */}
            <span className="text-lg font-medium text-foreground">
              {currentRoster}/{maxRoster}
            </span>
            {/* 3-dot Menu */}
            <button className="p-2 hover:bg-gray-100 rounded transition-colors">
              <MoreVertical className="w-5 h-5 text-gray-400" />
            </button>
          </div>
        </div>

        {/* Format Buttons */}
        <div className="flex items-center gap-2">
          <button
            onClick={() => setSelectedFormat("7v7")}
            className="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
            style={{
              backgroundColor: selectedFormat === "7v7" ? "#3B82F6" : "#FFFFFF",
              color: selectedFormat === "7v7" ? "#FFFFFF" : "#000000",
              border: selectedFormat === "7v7" ? "none" : "0.67px solid rgba(0, 0, 0, 0.12)",
            }}
          >
            7v7
          </button>
          <button
            onClick={() => setSelectedFormat("5v5")}
            className="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
            style={{
              backgroundColor: selectedFormat === "5v5" ? "#3B82F6" : "#FFFFFF",
              color: selectedFormat === "5v5" ? "#FFFFFF" : "#000000",
              border: selectedFormat === "5v5" ? "none" : "0.67px solid rgba(0, 0, 0, 0.12)",
            }}
          >
            5v5
          </button>
        </div>
      </div>

      {/* Team Member Cards */}
      <div className="space-y-3">
        {mockTeamMembers.map((member) => (
          <TeamUsersCard
            key={member.id}
            id={member.id}
            name={member.name}
            email={member.email}
            position={member.position}
            avatar={member.avatar}
            role={member.role}
            paymentStatus={member.paymentStatus}
            showClockIcon={member.showClockIcon}
          />
        ))}
      </div>

      {/* Invite User Modal */}
      {showInviteModal && (
        <div
          className="fixed inset-0 flex items-center justify-center z-50"
          style={{ backgroundColor: "rgba(0, 0, 0, 0.2)" }}
          onClick={() => setShowInviteModal(false)}
        >
          <div
            className="bg-white rounded-[24px] relative"
            style={{
              width: "603px",
              padding: "20px 14px",
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div
              className="flex flex-col"
              style={{
                width: "575px",
                gap: "20px",
              }}
            >
              {/* Title */}
              <h2 className="text-2xl font-bold text-foreground text-center" style={{ fontFamily: "Lato, sans-serif" }}>
                Invite Player
              </h2>

              {/* Email Input */}
              <div className="flex flex-col gap-2">
                <label className="text-sm font-medium text-foreground" style={{ fontFamily: "Lato, sans-serif" }}>
                  Email
                </label>
                <input
                  type="email"
                  placeholder="Enter email address"
                  className="w-full h-12 px-4 rounded-lg border border-[#E5E7EB] bg-white"
                  style={{ fontFamily: "Lato, sans-serif" }}
                />
              </div>

              {/* Invite Button */}
              <div className="flex items-center justify-center mt-auto pt-4">
                <button
                  onClick={() => {
                    // Handle invite logic here
                    setShowInviteModal(false)
                  }}
                  className="w-full h-12 rounded-full text-sm font-medium text-white transition-colors"
                  style={{
                    backgroundColor: "#0F173E",
                    fontFamily: "Lato, sans-serif",
                  }}
                >
                  Invite
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}



