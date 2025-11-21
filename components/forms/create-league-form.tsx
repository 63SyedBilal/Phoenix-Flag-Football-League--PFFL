"use client"

import type React from "react"

import { useState } from "react"
import { ChevronLeft, Upload, X } from "lucide-react"

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
    }
  }

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="border-b border-blue-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <button onClick={handleBack} className="p-2 hover:bg-gray-100 rounded-lg">
            <ChevronLeft className="w-5 h-5" />
          </button>
          {onClose && (
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg">
              <X className="w-5 h-5" />
            </button>
          )}
        </div>

        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          {step === 1 && "Create League"}
          {step === 2 && "Invite Referees"}
          {step === 3 && "Invite Stat Keepers"}
          {step === 4 && "Invite Teams"}
        </h1>
        <p className="text-gray-600">
          {step === 1 && "Enter league information below to create a new tournament."}
          {step === 2 && "Choose referees for this league. You can invite new referees or select from existing ones."}
          {step === 3 &&
            "Choose Stat Keepers for this league. You can invite new Stat Keepers or select from existing ones."}
          {step === 4 && "Invite teams to join this league. You can search existing teams."}
        </p>

        {/* Progress Steps */}
        <div className="flex items-center justify-between mt-8">
          {[1, 2, 3, 4].map((s) => (
            <div key={s} className="flex items-center flex-1">
              <div
                className={`w-10 h-10 rounded-full flex items-center justify-center font-semibold text-sm transition-colors ${
                  step === s
                    ? "bg-blue-600 text-white"
                    : step > s
                      ? "bg-green-600 text-white"
                      : "bg-gray-200 text-gray-600"
                }`}
                style={step === s ? { backgroundColor: PRIMARY_COLOR } : {}}
              >
                {step > s ? "✓" : s}
              </div>
              {s < 4 && (
                <div className={`flex-1 h-1 mx-2 transition-colors ${step > s ? "bg-green-600" : "bg-gray-200"}`} />
              )}
            </div>
          ))}
        </div>

        <div className="flex justify-between text-xs font-medium text-gray-600 mt-4">
          <span>Create League</span>
          <span>Referees</span>
          <span>Stat Keeper</span>
          <span>Invite Teams</span>
        </div>
      </div>

      {/* Content */}
      <form
        className="p-8 max-w-3xl mx-auto"
        onSubmit={(e) => {
          e.preventDefault()
          handleNext()
        }}
      >
        {/* Step 1: Create League */}
        {step === 1 && (
          <div className="space-y-6">
            {/* Format Selection */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-3">Select Format</label>
              <div className="grid grid-cols-2 gap-4">
                {["5v5", "7v7"].map((format) => (
                  <button
                    key={format}
                    onClick={() =>
                      setFormData({
                        ...formData,
                        format: format as "5v5" | "7v7",
                      })
                    }
                    className={`p-4 rounded-lg font-medium transition-colors ${
                      formData.format === format ? "text-white" : "bg-gray-100 text-gray-900 hover:bg-gray-200"
                    }`}
                    style={formData.format === format ? { backgroundColor: PRIMARY_COLOR } : {}}
                  >
                    {format}
                  </button>
                ))}
              </div>
            </div>

            {/* League Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">League Name</label>
              <input
                type="text"
                placeholder="Enter League Name"
                value={formData.leagueName}
                onChange={(e) => setFormData({ ...formData, leagueName: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                style={{ borderRadius: "6px" }}
              />
            </div>

            {/* Logo Upload */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-3">Upload Logo</label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                {formData.logo ? (
                  <div className="flex items-center justify-center gap-4">
                    <div className="text-4xl">{formData.logo.name.split(".")[0]}</div>
                    <button
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
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
                <input
                  type="date"
                  value={formData.startDate}
                  onChange={(e) => setFormData({ ...formData, startDate: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  style={{ borderRadius: "6px" }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
                <input
                  type="date"
                  value={formData.endDate}
                  onChange={(e) => setFormData({ ...formData, endDate: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  style={{ borderRadius: "6px" }}
                />
              </div>
            </div>

            {/* Other Fields */}
            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Minimum Players Required</label>
                <select
                  value={formData.minPlayers}
                  onChange={(e) => setFormData({ ...formData, minPlayers: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  style={{ borderRadius: "6px" }}
                >
                  <option value="">Select</option>
                  <option value="5">5</option>
                  <option value="6">6</option>
                  <option value="7">7</option>
                  <option value="8">8</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Entry Fee Type</label>
                <select
                  value={formData.entryFeeType}
                  onChange={(e) => setFormData({ ...formData, entryFeeType: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  style={{ borderRadius: "6px" }}
                >
                  <option value="">Select</option>
                  <option value="per-player">Per Player</option>
                  <option value="per-team">Per Team</option>
                  <option value="flat">Flat Rate</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Per Player League Fee</label>
                <input
                  type="number"
                  placeholder="$250"
                  value={formData.perPlayerFee}
                  onChange={(e) => setFormData({ ...formData, perPlayerFee: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  style={{ borderRadius: "6px" }}
                />
              </div>
            </div>
          </div>
        )}

        {/* Step 2: Referees */}
        {step === 2 && (
          <div className="space-y-4">
            <input
              type="text"
              placeholder="Search by Referee name"
              className="w-full px-4 py-2 border border-gray-300 rounded"
              style={{ borderRadius: "6px" }}
            />
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {mockReferees.map((referee) => (
                <div
                  key={referee.id}
                  className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50"
                >
                  <div className="flex items-center gap-3">
                    <img
                      src={referee.avatar || "/placeholder.svg"}
                      alt={referee.name}
                      className="w-10 h-10 rounded-full"
                    />
                    <span className="font-medium text-gray-900">{referee.name}</span>
                  </div>
                  <input
                    type="checkbox"
                    checked={selectedReferees.has(referee.id)}
                    onChange={() => toggleReferee(referee.id)}
                    className="w-5 h-5 cursor-pointer"
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Step 3: Stat Keepers */}
        {step === 3 && (
          <div className="space-y-4">
            <input
              type="text"
              placeholder="Search by Stat Keeper name"
              className="w-full px-4 py-2 border border-gray-300 rounded"
              style={{ borderRadius: "6px" }}
            />
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {mockStatKeepers.map((keeper) => (
                <div
                  key={keeper.id}
                  className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50"
                >
                  <div className="flex items-center gap-3">
                    <img
                      src={keeper.avatar || "/placeholder.svg"}
                      alt={keeper.name}
                      className="w-10 h-10 rounded-full"
                    />
                    <span className="font-medium text-gray-900">{keeper.name}</span>
                  </div>
                  <input
                    type="checkbox"
                    checked={selectedStatKeepers.has(keeper.id)}
                    onChange={() => toggleStatKeeper(keeper.id)}
                    className="w-5 h-5 cursor-pointer"
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Step 4: Teams */}
        {step === 4 && (
          <div className="space-y-4">
            <input
              type="text"
              placeholder="Search by Team name"
              className="w-full px-4 py-2 border border-gray-300 rounded"
              style={{ borderRadius: "6px" }}
            />
            <div className="space-y-4 max-h-96 overflow-y-auto">
              {mockTeams.map((team) => (
                <div key={team.id} className="border border-gray-200 rounded-lg overflow-hidden">
                  <div
                    className="p-4 flex items-center justify-between cursor-pointer hover:bg-gray-50"
                    onClick={() => toggleTeam(team.id)}
                  >
                    <div className="flex items-center gap-3">
                      <div className="text-2xl">{team.logo}</div>
                      <div>
                        <p className="font-semibold text-gray-900">{team.name}</p>
                        <p className="text-sm text-gray-600">
                          View Team Overview ({team.playerCount}/{team.playerCount})
                        </p>
                      </div>
                    </div>
                    <input
                      type="checkbox"
                      checked={selectedTeams.has(team.id)}
                      onChange={() => toggleTeam(team.id)}
                      className="w-5 h-5 cursor-pointer"
                    />
                  </div>

                  {/* Team Roster */}
                  {selectedTeams.has(team.id) && (
                    <div className="border-t border-gray-200 bg-gray-50 p-4">
                      <div className="space-y-2">
                        {team.players.map((player, idx) => (
                          <div key={idx} className="flex items-center justify-between text-sm">
                            <div className="grid grid-cols-3 gap-8 flex-1">
                              <span className="text-gray-700">#{player.jerseyNumber}</span>
                              <span className="text-gray-900 font-medium">{player.name}</span>
                              <span className="text-gray-600">{player.position}</span>
                            </div>
                            <button
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
              ))}
            </div>
          </div>
        )}

        {/* Next button now inside form */}
        <div className="mt-8">
          <button
            type="submit"
            className="w-full py-3 rounded-lg text-white font-semibold transition-colors"
            style={{ backgroundColor: PRIMARY_COLOR }}
          >
            {step === 4 ? "Create League" : "Next"}
          </button>
        </div>
      </form>
    </div>
  )
}
