"use client"

import type React from "react"
import { Button } from "@/components/ui/button"

export interface HeaderProps {
  title: string
  subtitle?: string
  actionButton?: {
    label: string
    onClick: () => void
    variant?: "default" | "outline"
  }
  onBack?: () => void
  showBackButton?: boolean
}

export const Header: React.FC<HeaderProps> = ({ title, subtitle, actionButton, onBack, showBackButton }) => {
  return (
    <header className="bg-background border-b border-border p-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          {showBackButton && onBack && (
            <button onClick={onBack} className="text-muted-foreground hover:text-foreground transition">
              ← Back
            </button>
          )}
          <div>
            <h1 className="text-3xl font-bold text-foreground">{title}</h1>
            {subtitle && <p className="text-sm text-muted-foreground mt-1">{subtitle}</p>}
          </div>
        </div>
        {actionButton && (
          <Button onClick={actionButton.onClick} variant={actionButton.variant || "default"}>
            {actionButton.label}
          </Button>
        )}
      </div>
    </header>
  )
}
