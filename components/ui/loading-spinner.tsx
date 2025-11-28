"use client"

interface LoadingSpinnerProps {
  size?: "sm" | "md" | "lg"
  text?: string
  fullScreen?: boolean
}

export default function LoadingSpinner({ 
  size = "md", 
  text = "Loading...",
  fullScreen = false 
}: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: "w-4 h-4",
    md: "w-8 h-8",
    lg: "w-12 h-12"
  }

  const spinner = (
    <div className="flex flex-col items-center justify-center gap-3">
      <div
        className={`${sizeClasses[size]} border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin`}
      />
      {text && (
        <p className="text-sm text-gray-600" style={{ fontFamily: "Lato, sans-serif" }}>
          {text}
        </p>
      )}
    </div>
  )

  if (fullScreen) {
    return (
      <div className="flex items-center justify-center min-h-[400px] w-full">
        {spinner}
      </div>
    )
  }

  return spinner
}

