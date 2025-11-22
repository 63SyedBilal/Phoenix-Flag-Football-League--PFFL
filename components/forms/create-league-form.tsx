"use client"

import React, { useState } from "react"
import { ChevronLeft, Upload, Search, ChevronDown, ChevronUp } from "lucide-react"

const PRIMARY_COLOR = "#0F173E"

interface FormData {
  format: "5v5" | "7v7" | ""
  leagueName: string
  logo: File | null
  startDate: string
  endDate: string
  minPlayers: string
  entryFeeType: string
  perPlayerFee: string
}

interface SelectableUser {
  id: string
  name: string
  avatar: string
}

interface SelectableTeam {
  id: string
  name: string
  logo: string
  playerCount: number
  players: Array<{
    jerseyNumber: string
    name: string
    position: string
  }>
}

export default function CreateLeagueForm({
  onClose,
}: {
  onClose?: () => void
}) {
  const [step, setStep] = useState(1)
  const [formData, setFormData] = useState<FormData>({
    format: "",
    leagueName: "",
    logo: null,
    startDate: "",
    endDate: "",
    minPlayers: "",
    entryFeeType: "",
    perPlayerFee: "",
  })

  const [selectedReferees, setSelectedReferees] = useState<Set<string>>(new Set())
  const [selectedStatKeepers, setSelectedStatKeepers] = useState<Set<string>>(new Set())
  const [selectedTeams, setSelectedTeams] = useState<Set<string>>(new Set())

  // Mock data
  const mockReferees: SelectableUser[] = [
    { id: "1", name: "John Carter", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=John" },
    { id: "2", name: "Michael Lee", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Michael" },
    { id: "3", name: "Anthony Brooks", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Anthony" },
  ]

  const mockStatKeepers: SelectableUser[] = [
    { id: "1", name: "Alex Morgan", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alex" },
    { id: "2", name: "David Brooks", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=David" },
    { id: "3", name: "Rebecca Torres", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Rebecca" },
  ]

  const mockTeams: SelectableTeam[] = [
    {
      id: "1",
      name: "STC",
      logo: "🛡️",
      playerCount: 5,
      players: [
        { jerseyNumber: "01", name: "Alex Morgan (C)", position: "QB" },
        { jerseyNumber: "02", name: "John Carter", position: "WR" },
        { jerseyNumber: "03", name: "Michael Lee", position: "DB" },
        { jerseyNumber: "04", name: "Rebecca Torres", position: "RB" },
        { jerseyNumber: "05", name: "Anthony Brooks", position: "LB" },
      ],
    },
    {
      id: "2",
      name: "GEO",
      logo: "⚡",
      playerCount: 8,
      players: [
        { jerseyNumber: "01", name: "Player One", position: "QB" },
        { jerseyNumber: "02", name: "Player Two", position: "WR" },
      ],
    },
  ]

  const handleLogoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) {
      setFormData({ ...formData, logo: e.target.files[0] })
    }
  }

  const toggleReferee = (id: string) => {
    const newSet = new Set(selectedReferees)
    if (newSet.has(id)) {
      newSet.delete(id)
    } else {
      newSet.add(id)
    }
    setSelectedReferees(newSet)
  }

  const toggleStatKeeper = (id: string) => {
    const newSet = new Set(selectedStatKeepers)
    if (newSet.has(id)) {
      newSet.delete(id)
    } else {
      newSet.add(id)
    }
    setSelectedStatKeepers(newSet)
  }

  const toggleTeam = (id: string) => {
    const newSet = new Set(selectedTeams)
    if (newSet.has(id)) {
      newSet.delete(id)
    } else {
      newSet.add(id)
    }
    setSelectedTeams(newSet)
  }

  const handleNext = () => {
    if (step < 4) {
      setStep(step + 1)
    } else {
      // Submit form
      console.log("Form submitted:", {
        ...formData,
        referees: Array.from(selectedReferees),
        statKeepers: Array.from(selectedStatKeepers),
        teams: Array.from(selectedTeams),
      })
      onClose?.()
    }
  }

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1)
    } else {
      onClose?.()
    }
  }

  const steps = [
    { number: 1, name: "Create League" },
    { number: 2, name: "Referees" },
    { number: 3, name: "Stat Keeper" },
    { number: 4, name: "Invite Teams" },
  ]

  return (
    <div className="flex flex-col gap-6">
      {/* Header */}
      <div className="flex flex-col gap-4">
        <button
          onClick={handleBack}
          className="flex items-center justify-center hover:opacity-80 transition-opacity self-start"
          style={{
            width: "50px",
            height: "50px",
            padding: "10px",
            borderRadius: "50px",
            backgroundColor: "#F2F2F2",
          }}
        >
          <img
            src="/assets/image/Back arrow.svg"
            alt="back"
            className="w-5 h-5"
          />
        </button>
        <div>
          <h1 className="text-3xl font-bold text-foreground">Create League</h1>
          <p className="text-muted-foreground mt-1">
            {step === 1 && "Enter league information below to create a new tournament."}
            {step === 2 && "Choose referees for this league. You can invite new referees or select from existing ones."}
            {step === 3 && "Choose Stat Keepers for this league. You can invite new Stat Keepers or select from existing ones."}
            {step === 4 && "Invite teams to join this league. You can search existing teams."}
          </p>
        </div>
      </div>

      {/* Progress Nodes */}
      <div className="flex items-center justify-between relative w-full">
        {steps.map((s, index) => (
          <React.Fragment key={s.number}>
            <div className="flex flex-col items-center relative z-10 flex-shrink-0" style={{ width: "90px", minWidth: "90px", height: "79px", gap: "12px" }}>
              <div
                className="rounded-full flex items-center justify-center font-semibold text-sm transition-colors relative z-10 bg-white flex-shrink-0"
                style={{
                  width: "50px",
                  height: "50px",
                  minWidth: "50px",
                  padding: "13px",
                  backgroundColor: step >= s.number ? PRIMARY_COLOR : "#FFFFFF",
                  border: `1px solid ${PRIMARY_COLOR}`,
                  color: step >= s.number ? "#FFFFFF" : "#000000",
                }}
              >
                {step > s.number ? "✓" : s.number}
              </div>
              <span
                className="text-center block"
                style={{
                  width: "90px",
                  minWidth: "90px",
                  height: "17px",
                  fontFamily: "Lato, sans-serif",
                  fontWeight: 400,
                  fontSize: "14px",
                  lineHeight: "100%",
                  color: "#000000",
                }}
              >
                {s.name}
              </span>
            </div>
            {index < steps.length - 1 && (
              <div
                className="flex-1 relative z-0"
                style={{
                  height: "50px",
                  display: "flex",
                  alignItems: "center",
                }}
              >
                <div
                  className="h-0 border-t-2"
                  style={{
                    borderColor: "rgba(15, 23, 62, 0.2)",
                    borderWidth: "1.8px",
                    width: "100%",
                    marginLeft: "20px",
                    marginRight: "20px",
                  }}
                />
              </div>
            )}
          </React.Fragment>
        ))}
      </div>

      {/* Form Content */}
      <form
        className="flex flex-col gap-[18px]"
        onSubmit={(e) => {
          e.preventDefault()
          handleNext()
        }}
      >
        {/* Step 1: Create League */}
        {step === 1 && (
          <div className="flex flex-col gap-[18px]">
            {/* Select Format */}
            <div className="flex gap-1">
              {["5v5", "7v7"].map((format) => (
                <button
                  key={format}
                  type="button"
                  onClick={() =>
                    setFormData({
                      ...formData,
                      format: format as "5v5" | "7v7",
                    })
                  }
                  className="flex-1 h-12 px-3 py-[10px] rounded-md font-medium transition-colors"
                  style={{
                    backgroundColor: formData.format === format ? PRIMARY_COLOR : "#FFFFFF",
                    color: formData.format === format ? "#FFFFFF" : "#000000",
                    border: formData.format === format ? "none" : "1px solid #D1D5DB",
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  }}
                >
                  {format}
                </button>
              ))}
            </div>

            {/* League Name */}
            <div className="flex flex-col gap-3">
              <label
                className="font-medium"
                style={{
                  fontFamily: "Lato, sans-serif",
                  fontWeight: 500,
                  fontSize: "14px",
                  lineHeight: "20px",
                  color: "#111827",
                }}
              >
                League Name
              </label>
              <input
                type="text"
                placeholder="Enter League Name"
                value={formData.leagueName}
                onChange={(e) => setFormData({ ...formData, leagueName: e.target.value })}
                className="w-full h-12 px-3 py-[10px] rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              />
            </div>

            {/* Upload Logo */}
            <div className="flex flex-col gap-3">
              <label
                className="font-medium"
                style={{
                  fontFamily: "Lato, sans-serif",
                  fontWeight: 500,
                  fontSize: "14px",
                  lineHeight: "20px",
                  color: "#111827",
                }}
              >
                Upload Logo
              </label>
              <div
                className="w-full min-h-[161px] px-3 py-[10px] rounded-md border-dashed flex flex-col items-center justify-center gap-3 cursor-pointer hover:bg-gray-50 transition-colors"
                style={{
                  border: "1px solid #D1D5DB",
                  borderStyle: "dashed",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              >
                {formData.logo ? (
                  <div className="flex items-center justify-center gap-4">
                    <div className="text-4xl">{formData.logo.name.split(".")[0]}</div>
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, logo: null })}
                      className="text-red-600 hover:text-red-700"
                    >
                      Remove
                    </button>
                  </div>
                ) : (
                  <>
                    <p className="text-gray-600 mb-2">Tap below to upload your league logo.</p>
                    <label
                      className="inline-flex items-center gap-2 px-4 py-2 rounded-full font-medium text-white cursor-pointer transition-colors"
                      style={{ backgroundColor: PRIMARY_COLOR }}
                    >
                      <Upload className="w-4 h-4" />
                      Upload
                      <input type="file" accept="image/*" onChange={handleLogoUpload} className="hidden" />
                    </label>
                  </>
                )}
              </div>
            </div>

            {/* Dates */}
            <div className="grid grid-cols-2 gap-4">
              <div className="flex flex-col gap-3">
                <label
                  className="font-medium"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    fontWeight: 500,
                    fontSize: "14px",
                    lineHeight: "20px",
                    color: "#111827",
                  }}
                >
                  Start Date
                </label>
                <input
                  type="date"
                  value={formData.startDate}
                  onChange={(e) => setFormData({ ...formData, startDate: e.target.value })}
                  className="w-full h-12 px-3 py-[10px] rounded-md border"
                  style={{
                    border: "1px solid #D1D5DB",
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                    backgroundColor: "#FFFFFF",
                  }}
                />
              </div>
              <div className="flex flex-col gap-3">
                <label
                  className="font-medium"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    fontWeight: 500,
                    fontSize: "14px",
                    lineHeight: "20px",
                    color: "#111827",
                  }}
                >
                  End Date
                </label>
                <input
                  type="date"
                  value={formData.endDate}
                  onChange={(e) => setFormData({ ...formData, endDate: e.target.value })}
                  className="w-full h-12 px-3 py-[10px] rounded-md border"
                  style={{
                    border: "1px solid #D1D5DB",
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                    backgroundColor: "#FFFFFF",
                  }}
                />
              </div>
            </div>

            {/* Three Fields Row */}
            <div className="grid grid-cols-3 gap-4">
              <div className="flex flex-col gap-3">
                <label
                  className="font-medium"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    fontWeight: 500,
                    fontSize: "14px",
                    lineHeight: "20px",
                    color: "#111827",
                  }}
                >
                  Minimum Players Required
                </label>
                <div className="relative">
                  <select
                    value={formData.minPlayers}
                    onChange={(e) => setFormData({ ...formData, minPlayers: e.target.value })}
                    className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border appearance-none"
                    style={{
                      border: "1px solid #D1D5DB",
                      boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                      backgroundColor: "#FFFFFF",
                    }}
                  >
                    <option value="">Select</option>
                    <option value="5">5</option>
                    <option value="6">6</option>
                    <option value="7">7</option>
                    <option value="8">8</option>
                  </select>
                  <img
                    src="/assets/image/arrow-down.svg"
                    alt=""
                    className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 pointer-events-none"
                  />
                </div>
              </div>
              <div className="flex flex-col gap-3">
                <label
                  className="font-medium"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    fontWeight: 500,
                    fontSize: "14px",
                    lineHeight: "20px",
                    color: "#111827",
                  }}
                >
                  Entry Fee Type
                </label>
                <div className="relative">
                  <select
                    value={formData.entryFeeType}
                    onChange={(e) => setFormData({ ...formData, entryFeeType: e.target.value })}
                    className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border appearance-none"
                    style={{
                      border: "1px solid #D1D5DB",
                      boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                      backgroundColor: "#FFFFFF",
                    }}
                  >
                    <option value="">Select</option>
                    <option value="per-player">Per Player</option>
                    <option value="per-team">Per Team</option>
                    <option value="flat">Flat Rate</option>
                  </select>
                  <img
                    src="/assets/image/arrow-down.svg"
                    alt=""
                    className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 pointer-events-none"
                  />
                </div>
              </div>
              <div className="flex flex-col gap-3">
                <label
                  className="font-medium"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    fontWeight: 500,
                    fontSize: "14px",
                    lineHeight: "20px",
                    color: "#111827",
                  }}
                >
                  Per Player League Fee
                </label>
                <input
                  type="number"
                  placeholder="$250"
                  value={formData.perPlayerFee}
                  onChange={(e) => setFormData({ ...formData, perPlayerFee: e.target.value })}
                  className="w-full h-12 px-3 py-[10px] rounded-md border"
                  style={{
                    border: "1px solid #D1D5DB",
                    boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                    backgroundColor: "#FFFFFF",
                  }}
                />
              </div>
            </div>
          </div>
        )}

        {/* Step 2: Referees */}
        {step === 2 && (
          <div className="space-y-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search by Referee name"
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              />
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {mockReferees.map((referee) => {
                const isSelected = selectedReferees.has(referee.id)
                return (
                  <div
                    key={referee.id}
                    className="flex items-center justify-between p-3 rounded-md border cursor-pointer hover:bg-gray-50 transition-colors w-full"
                    style={{
                      height: "64px",
                      gap: "10px",
                      border: "1px solid rgba(0, 0, 0, 0.12)",
                      backgroundColor: "#FFFFFF",
                    }}
                    onClick={() => toggleReferee(referee.id)}
                  >
                    <div className="flex items-center gap-[10px]">
                      <img
                        src={referee.avatar || "/placeholder.svg"}
                        alt={referee.name}
                        className="w-10 h-10 rounded-full flex-shrink-0"
                      />
                      <span className="font-medium text-gray-900">{referee.name}</span>
                    </div>
                    <img
                      src={isSelected ? "/assets/image/ic_baseline-email.svg" : "/assets/image/ic_outline-email.svg"}
                      alt="email"
                      className="w-5 h-5 cursor-pointer flex-shrink-0"
                    />
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* Step 3: Stat Keepers */}
        {step === 3 && (
          <div className="space-y-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search by Stat Keeper name"
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              />
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {mockStatKeepers.map((keeper) => {
                const isSelected = selectedStatKeepers.has(keeper.id)
                return (
                  <div
                    key={keeper.id}
                    className="flex items-center justify-between p-3 rounded-md border cursor-pointer hover:bg-gray-50 transition-colors w-full"
                    style={{
                      height: "64px",
                      gap: "10px",
                      border: "1px solid rgba(0, 0, 0, 0.12)",
                      backgroundColor: "#FFFFFF",
                    }}
                    onClick={() => toggleStatKeeper(keeper.id)}
                  >
                    <div className="flex items-center gap-[10px]">
                      <img
                        src={keeper.avatar || "/placeholder.svg"}
                        alt={keeper.name}
                        className="w-10 h-10 rounded-full flex-shrink-0"
                      />
                      <span className="font-medium text-gray-900">{keeper.name}</span>
                    </div>
                    <img
                      src={isSelected ? "/assets/image/ic_baseline-email.svg" : "/assets/image/ic_outline-email.svg"}
                      alt="email"
                      className="w-5 h-5 cursor-pointer flex-shrink-0"
                    />
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* Step 4: Teams */}
        {step === 4 && (
          <div className="space-y-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search by Team name"
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                }}
              />
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {mockTeams.map((team) => {
                const isExpanded = selectedTeams.has(team.id)
                return (
                  <div
                    key={team.id}
                    className="rounded-md border w-full p-3"
                    style={{
                      border: "1px solid rgba(0, 0, 0, 0.12)",
                      backgroundColor: "#FFFFFF",
                      borderRadius: "6px",
                      padding: "12px",
                      gap: "12px",
                    }}
                  >
                    <div
                      className="cursor-pointer hover:bg-gray-50 transition-colors -m-3 p-3"
                      onClick={() => toggleTeam(team.id)}
                    >
                      <div className="flex items-start gap-[10px]">
                        <div className="text-2xl flex-shrink-0">{team.logo}</div>
                        <div className="flex flex-col gap-1 flex-1 w-full">
                          <div className="flex items-center justify-between w-full">
                            <p className="font-semibold text-gray-900">{team.name}</p>
                            <img
                              src="/assets/image/ic_outline-email.svg"
                              alt="email"
                              className="w-5 h-5 flex-shrink-0"
                            />
                          </div>
                          <div className="flex items-center justify-between w-full">
                            <p className="text-sm text-gray-600">
                              View Team Overview ({team.playerCount}/{team.playerCount})
                            </p>
                            {isExpanded ? (
                              <ChevronUp className="w-5 h-5 text-gray-400 flex-shrink-0" />
                            ) : (
                              <ChevronDown className="w-5 h-5 text-gray-400 flex-shrink-0" />
                            )}
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Team Roster */}
                    {isExpanded && (
                      <div
                        className="border rounded-md p-3 mt-3 w-full"
                        style={{
                          gap: "12px",
                          border: "1px solid rgba(0, 0, 0, 0.12)",
                          borderRadius: "6px",
                          backgroundColor: "#FFFFFF",
                          padding: "12px",
                        }}
                      >
                        <div className="space-y-2">
                          {team.players.map((player, idx) => (
                            <div key={idx} className="flex items-center justify-between text-sm">
                              <div className="grid grid-cols-3 gap-8 flex-1">
                                <span className="text-gray-700">#{player.jerseyNumber}</span>
                                <span className="text-gray-900 font-medium">{player.name}</span>
                                <span className="text-gray-600">{player.position}</span>
                              </div>
                              <button
                                type="button"
                                className="px-3 py-1 rounded text-white text-xs font-medium transition-colors"
                                style={{ backgroundColor: PRIMARY_COLOR }}
                              >
                                View Position
                              </button>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* Next Button */}
        <button
          type="submit"
          className="w-full h-[58px] rounded-full text-white font-semibold transition-colors"
          style={{ backgroundColor: PRIMARY_COLOR }}
        >
          {step === 4 ? "Create League" : "Next"}
        </button>
      </form>
    </div>
  )
}
