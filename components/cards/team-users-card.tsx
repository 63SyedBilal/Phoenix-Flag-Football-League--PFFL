"use client"

import { useState } from "react"
import Image from "next/image"

interface TeamUsersCardProps {
  id: string
  name: string
  email: string
  position: string
  avatar: string
  role: "Captain" | "Player"
  paymentStatus: "Paid" | "Unpaid"
  showClockIcon?: boolean
  hidePaymentStatus?: boolean
}

export default function TeamUsersCard({
  id,
  name,
  email,
  position,
  avatar,
  role,
  paymentStatus,
  showClockIcon = false,
  hidePaymentStatus = false,
}: TeamUsersCardProps) {
  const [isClockClicked, setIsClockClicked] = useState(false)
  return (
    <div
      className="bg-white border-[0.67px] border-[#E5E7EB] border-t-[0.67px] border-t-[#E5E7EB] rounded-[14px] py-5 px-2 w-full relative shadow-[0px_1px_2px_-1px_rgba(0,0,0,0.1),0px_1px_3px_0px_rgba(0,0,0,0.1)]"
    >
      <div className="flex items-start gap-3">
        {/* Logo/Avatar */}
        <div className="w-13 h-13 rounded-full flex-shrink-0 overflow-hidden">
          <img
            src={avatar}
            alt={name}
            className="w-13 h-13 rounded-full object-cover"
          />
        </div>

        {/* Detail Section */}
        <div className="flex flex-1 justify-between items-start">
          <div className="flex flex-col flex-1 gap-1">
            {/* Name with Clock Icon */}
            <div className="flex items-center gap-2">
              <h3 className="font-bold text-medium text-[#101828]" >
                {name}
              </h3>
              {showClockIcon && (
                <button
                  onClick={() => setIsClockClicked(!isClockClicked)}
                  className="p-0 border-0 bg-transparent cursor-pointer"
                >
                  <Image
                    src="/assets/image/clock.svg"
                    alt="clock"
                    width={20}
                    height={20}
                    className="w-5 h-5 transition-all"
                    style={{
                      filter: isClockClicked
                        ? "brightness(0) saturate(100%) invert(6%) sepia(28%) saturate(2000%) hue-rotate(210deg) brightness(95%) contrast(95%)"
                        : "brightness(0) saturate(100%) invert(45%) sepia(8%) saturate(500%) hue-rotate(180deg) brightness(95%) contrast(85%)",
                    }}
                  />
                </button>
              )}
            </div>
            
            {/* Email */}
            <p className="font-medium text-sm  text-[#6A7282]" >
              {email}
            </p>
            
            {/* Position */}
            <p className="font-medium text-sm  text-[#6A7282]" >
              Position: {position}
            </p>
          </div>

          {/* Role and Payment Status Tags */}
          <div className="flex flex-col gap-2 items-end">
            {/* Role Tag */}
            <span
              className="px-3 py-2 rounded-lg text-xs font-medium border-[0.67px]"
              style={{
                backgroundColor: role === "Captain" ? "#FEF3C7" : "#DBEAFE",
                borderColor: role === "Captain" ? "#FDE68A" : "#93C5FD",
                color: role === "Captain" ? "#000000" : "#1E40AF",
              }}
            >
              {role}
            </span>
            
            {/* Payment Status Tag - Only show if not hidden */}
            {!hidePaymentStatus && (
              <span
                className="px-4 py-2 rounded-lg text-xs font-medium text-white"
                style={{
                  backgroundColor: paymentStatus === "Paid" ? "#0F173E" : "#6B7280",
                }}
              >
                {paymentStatus}
              </span>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

