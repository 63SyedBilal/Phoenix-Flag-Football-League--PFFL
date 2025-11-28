"use client"

import { MoreVertical } from "lucide-react"
import Image from "next/image"

interface UserCardProps {
  id: string
  name: string
  email: string
  league: string | null
  avatar: string
  roles: string[]
  roleColors: string[]
  roleBorders: string[]
}

export default function UsersCard({
  id,
  name,
  email,
  league,
  avatar,
  roles,
  roleColors,
  roleBorders,
}: UserCardProps) {
  return (
    <div
      className="bg-white border-[0.67px] border-[#E5E7EB] border-t-[0.67px] border-t-[#E5E7EB] rounded-[14px] p-6 w-full h-[152.83px] relative shadow-[0px_1px_2px_-1px_rgba(0,0,0,0.1),0px_1px_3px_0px_rgba(0,0,0,0.1)]"
    >
      {/* 3-dot menu at top right */}
      <button className="absolute top-6 right-6 p-1 hover:bg-gray-100 rounded transition-colors">
        <MoreVertical className="w-5 h-5 text-gray-400" />
      </button>

      <div className="flex items-start gap-3">
        {/* Logo/Avatar */}
        <div className="w-12 h-12 rounded-full flex-shrink-0 overflow-hidden">
          <img
            src={avatar}
            alt={name}
            className="w-12 h-12 rounded-full object-cover"
          />
        </div>

        {/* Detail Section */}
        <div className="flex flex-col flex-1 w-full h-[104.83px] gap-3">
          {/* Info Section */}
          <div className="flex flex-col gap-1">
            <h3 className="font-bold text-base leading-6 text-[#101828]" style={{ fontFamily: "Lato, sans-serif" }}>
              {name}
            </h3>
            <p className="font-medium text-xs leading-[18px] text-[#4A5565]" style={{ fontFamily: "Lato, sans-serif" }}>
              {email}
            </p>
            {league && (
              <p
                className="font-medium flex items-center gap-1 text-xs leading-[18px] text-[#4A5565]"
                style={{ fontFamily: "Lato, sans-serif" }}
              >
                <Image
                  src="/assets/image/users.svg"
                  alt="users"
                  width={12}
                  height={12}
                  className="w-3 h-3"
                />
                {league}
              </p>
            )}

            {/* Role Badges - dynamic badges */}
            <div className="flex items-center gap-2 flex-wrap mt-1">
              {roles.map((role, index) => {
                // Skip status badges like "Active" or "Invited" if they don't have proper styling
                if (index >= roleColors.length || index >= roleBorders.length) {
                  return null
                }
                
                return (
                  <span
                    key={index}
                    className="px-2 py-1 rounded-lg text-xs font-medium border-[0.67px] text-black inline-flex items-center justify-center"
                    style={{
                      minWidth: "fit-content",
                      height: "27.33px",
                      paddingLeft: "8px",
                      paddingRight: "8px",
                      backgroundColor: roleColors[index] || "#F3F4F6",
                      borderColor: roleBorders[index] || "#D1D5DB",
                    }}
                  >
                    {role}
                  </span>
                )
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

