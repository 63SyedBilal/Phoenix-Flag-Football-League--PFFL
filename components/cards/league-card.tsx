"use client"

import { ChevronRight } from "lucide-react"
import Image from "next/image"
import { useRouter } from "next/navigation"

export interface LeagueCardProps {
  id: string
  name: string
  logo: string
  format: string
  startDate: string
  endDate: string
  leagueFee: string
  status: "active" | "pending"
}

export default function LeagueCard({
  id,
  name,
  logo,
  format,
  startDate,
  endDate,
  leagueFee,
  status,
}: LeagueCardProps) {
  const router = useRouter()

  return (
    <div
      className="bg-white border rounded-xl cursor-pointer hover:bg-gray-50 transition-colors w-full flex flex-col min-h-[240px] p-6 gap-6 border-[rgba(0,0,0,0.12)] rounded-[12px]"
      onClick={() => router.push(`/superadmin/leagues/${id}`)}
    >
      {/* First Section */}
      <div className="flex flex-col w-full h-[126px] gap-6">
        {/* First Row: Logo, Name, Status */}
        <div className="flex items-center justify-between w-full">
          <div className="flex items-center gap-6">
            <div className="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 overflow-hidden border-2 border-dashed border-gray-300">
              <Image
                src={logo}
                alt={name}
                width={48}
                height={48}
                className="w-12 h-12 rounded-full object-cover"
              />
            </div>
            <h3 className="font-semibold text-foreground text-xl">{name}</h3>
          </div>
          <button
            className="text-white text-sm font-medium flex-shrink-0 w-[77px] h-9 px-3 rounded-full"
            style={{
              backgroundColor: status === "active" ? "#0F173E" : "#A855F7",
            }}
          >
            {status === "active" ? "Active" : "Pending"}
          </button>
        </div>

        {/* Detail Section */}
        <div className="flex flex-col w-full h-[52px] gap-3">
          {/* First Row: Format and League Fee */}
          <div className="flex items-center justify-between w-full h-5">
            <p className="text-sm text-[#111827]">Format: {format}</p>
            <p className="text-sm text-[#111827]">League Fee: {leagueFee}</p>
          </div>

          {/* Second Row: Start Date and End Date */}
          <div className="flex items-center justify-between w-full h-5">
            <p className="text-sm text-[#111827]">Start Date: {startDate}</p>
            <p className="text-sm text-[#111827]">End Date: {endDate}</p>
          </div>
        </div>
      </div>

      {/* Border */}
      <div className="w-full h-0 border-t-2 border-[rgba(0,0,0,0.12)]" />

      {/* Show More Row */}
      <div className="flex items-center justify-between w-full rounded-xl h-[18px] opacity-40">
        <span className="text-sm text-muted-foreground">Show more</span>
        <ChevronRight className="w-4 h-4 text-muted-foreground" />
      </div>
    </div>
  )
}
