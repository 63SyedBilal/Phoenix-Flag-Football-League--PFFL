"use client"

import type React from "react"
import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card } from "@/components/ui/card"

export interface PlayerSignupFormProps {
  onSubmit: (data: PlayerSignupData) => void
  isLoading?: boolean
  error?: string
}

export interface PlayerSignupData {
  firstName: string
  lastName: string
  email: string
  phoneNumber: string
  password: string
  confirmPassword: string
  agreeToTerms: boolean
}

export const PlayerSignupForm: React.FC<PlayerSignupFormProps> = ({ onSubmit, isLoading, error }) => {
  const [formData, setFormData] = useState<PlayerSignupData>({
    firstName: "",
    lastName: "",
    email: "",
    phoneNumber: "",
    password: "",
    confirmPassword: "",
    agreeToTerms: false,
  })

  const [passwordStrength, setPasswordStrength] = useState<"weak" | "medium" | "strong">("weak")

  const checkPasswordStrength = (pwd: string) => {
    if (pwd.length < 6) return "weak"
    if (pwd.length < 10 || !/[A-Z]/.test(pwd) || !/[0-9]/.test(pwd)) return "medium"
    return "strong"
  }

  const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const pwd = e.target.value
    setFormData({ ...formData, password: pwd })
    setPasswordStrength(checkPasswordStrength(pwd))
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (formData.password !== formData.confirmPassword) {
      return
    }
    onSubmit(formData)
  }

  return (
    <Card className="w-full max-w-2xl p-8">
      <h1 className="text-2xl font-bold text-foreground mb-2">Join PFFL Today</h1>
      <p className="text-sm text-muted-foreground mb-6">Create your player account</p>

      <form onSubmit={handleSubmit} className="space-y-4">
        {error && <div className="p-3 bg-red-100 text-red-700 rounded-lg text-sm">{error}</div>}

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <label htmlFor="firstName" className="text-sm font-medium text-foreground">
              First Name
            </label>
            <Input
              id="firstName"
              placeholder="e.g bilal"
              value={formData.firstName}
              onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
              required
            />
          </div>

          <div className="space-y-2">
            <label htmlFor="lastName" className="text-sm font-medium text-foreground">
              Last Name
            </label>
            <Input
              id="lastName"
              placeholder="e.g ahmed"
              value={formData.lastName}
              onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
              required
            />
          </div>
        </div>

        <div className="space-y-2">
          <label htmlFor="email" className="text-sm font-medium text-foreground">
            Email Address
          </label>
          <Input
            id="email"
            type="email"
            placeholder="e.g bilal@phoenixleague.com"
            value={formData.email}
            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
            required
          />
        </div>

        <div className="space-y-2">
          <label htmlFor="phone" className="text-sm font-medium text-foreground">
            Phone Number
          </label>
          <Input
            id="phone"
            type="tel"
            placeholder="e.g +44 123 456 7890"
            value={formData.phoneNumber}
            onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
            required
          />
        </div>

        <div className="space-y-2">
          <label htmlFor="password" className="text-sm font-medium text-foreground">
            Create Password
          </label>
          <Input
            id="password"
            type="password"
            placeholder="Create your password"
            value={formData.password}
            onChange={handlePasswordChange}
            required
          />
          <p className="text-xs text-muted-foreground">
            Password strength:{" "}
            <span
              className={`font-medium ${
                passwordStrength === "strong"
                  ? "text-green-600"
                  : passwordStrength === "medium"
                    ? "text-yellow-600"
                    : "text-red-600"
              }`}
            >
              {passwordStrength.charAt(0).toUpperCase() + passwordStrength.slice(1)}
            </span>
          </p>
        </div>

        <div className="space-y-2">
          <label htmlFor="confirmPassword" className="text-sm font-medium text-foreground">
            Confirm Password
          </label>
          <Input
            id="confirmPassword"
            type="password"
            placeholder="Re-enter your password"
            value={formData.confirmPassword}
            onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
            required
          />
          {formData.password && formData.confirmPassword && formData.password !== formData.confirmPassword && (
            <p className="text-xs text-red-600">Passwords do not match</p>
          )}
        </div>

        <div className="flex items-center gap-2">
          <input
            id="terms"
            type="checkbox"
            checked={formData.agreeToTerms}
            onChange={(e) => setFormData({ ...formData, agreeToTerms: e.target.checked })}
            className="rounded border-border"
            required
          />
          <label htmlFor="terms" className="text-xs text-muted-foreground">
            I agree to Terms & Privacy
          </label>
        </div>

        <Button type="submit" className="w-full" disabled={isLoading || !formData.agreeToTerms}>
          {isLoading ? "Creating Account..." : "Create Account"}
        </Button>

        <p className="text-center text-sm text-muted-foreground">
          Already have an account?{" "}
          <a href="/login" className="text-primary hover:underline">
            login
          </a>
        </p>
      </form>
    </Card>
  )
}
