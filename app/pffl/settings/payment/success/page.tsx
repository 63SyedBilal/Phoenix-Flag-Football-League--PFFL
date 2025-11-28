"use client"

import { useEffect, useState } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { CheckCircle2 } from "lucide-react"
import LoadingSpinner from "@/components/ui/loading-spinner"

interface PaymentData {
  _id: string
  amount: number
  status: string
  transactionId: string
  paymentMethod: string
  leagueId: {
    leagueName: string
    logo?: string
  }
  userId: {
    firstName: string
    lastName: string
    email: string
  }
  createdAt: string
}

export default function PaymentSuccessPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const paymentId = searchParams.get("paymentId")
  const [paymentData, setPaymentData] = useState<PaymentData | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchPaymentDetails = async () => {
      if (!paymentId) {
        setError("Payment ID is missing")
        setIsLoading(false)
        return
      }

      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Authentication required")
          setIsLoading(false)
          return
        }

        // You can create a specific API endpoint to fetch payment details if needed
        // For now, we'll just display the success message
        setIsLoading(false)
      } catch (err) {
        console.error("Error fetching payment details:", err)
        setError("Failed to load payment details")
        setIsLoading(false)
      }
    }

    fetchPaymentDetails()
  }, [paymentId])

  if (isLoading) {
    return <LoadingSpinner fullScreen text="Loading payment confirmation..." />
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-6">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600 mb-2">Error</h1>
          <p className="text-gray-600">{error}</p>
        </div>
        <button
          onClick={() => router.push("/pffl/home")}
          className="px-6 py-3 bg-[#0F173E] text-white rounded-full font-medium hover:bg-opacity-90 transition-colors"
          style={{ fontFamily: "Lato, sans-serif" }}
        >
          Go to Home
        </button>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-6 max-w-2xl mx-auto">
      {/* Success Icon and Message */}
      <div className="flex flex-col items-center justify-center gap-6 py-12">
        <div className="w-24 h-24 rounded-full bg-green-100 flex items-center justify-center">
          <CheckCircle2 className="w-16 h-16 text-green-600" />
        </div>

        <div className="text-center">
          <h1
            className="text-3xl font-bold mb-2"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 700,
              color: "#111827",
            }}
          >
            Payment Successful!
          </h1>
          <p
            className="text-base"
            style={{
              fontFamily: "Lato, sans-serif",
              color: "#6B7280",
            }}
          >
            Your payment has been processed successfully.
          </p>
        </div>
      </div>

      {/* Payment Details Card */}
      <div
        className="bg-white border rounded-xl p-6"
        style={{
          borderColor: "rgba(0, 0, 0, 0.12)",
          borderWidth: "1px",
        }}
      >
        <h2
          className="text-lg font-bold mb-4"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#111827",
          }}
        >
          Payment Details
        </h2>

        <div className="space-y-3">
          {paymentId && (
            <div className="flex justify-between items-center">
              <span
                className="text-sm"
                style={{
                  fontFamily: "Lato, sans-serif",
                  color: "#6B7280",
                }}
              >
                Payment ID:
              </span>
              <span
                className="text-sm font-medium"
                style={{
                  fontFamily: "Lato, sans-serif",
                  color: "#111827",
                }}
              >
                {paymentId}
              </span>
            </div>
          )}

          <div className="flex justify-between items-center">
            <span
              className="text-sm"
              style={{
                fontFamily: "Lato, sans-serif",
                color: "#6B7280",
              }}
            >
              Status:
            </span>
            <span
              className="text-sm font-medium px-3 py-1 rounded-full bg-green-100 text-green-700"
              style={{
                fontFamily: "Lato, sans-serif",
              }}
            >
              Paid
            </span>
          </div>

          <div className="flex justify-between items-center">
            <span
              className="text-sm"
              style={{
                fontFamily: "Lato, sans-serif",
                color: "#6B7280",
              }}
            >
              Date:
            </span>
            <span
              className="text-sm font-medium"
              style={{
                fontFamily: "Lato, sans-serif",
                color: "#111827",
              }}
            >
              {new Date().toLocaleDateString("en-US", {
                month: "long",
                day: "numeric",
                year: "numeric",
              })}
            </span>
          </div>
        </div>
      </div>

      {/* What's Next */}
      <div
        className="bg-blue-50 border border-blue-200 rounded-xl p-6"
        style={{
          borderColor: "#BFDBFE",
        }}
      >
        <h3
          className="text-base font-bold mb-2"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#1E3A8A",
          }}
        >
          What's Next?
        </h3>
        <p
          className="text-sm mb-4"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#1E40AF",
          }}
        >
          Your payment has been recorded. You can now access all league features. A confirmation
          email has been sent to your registered email address.
        </p>
      </div>

      {/* Action Buttons */}
      <div className="flex flex-col sm:flex-row gap-4">
        <button
          onClick={() => router.push("/pffl/home")}
          className="flex-1 h-[58px] rounded-full text-white font-medium transition-colors"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          Go to Home
        </button>
        <button
          onClick={() => router.push("/pffl/settings/payment-history")}
          className="flex-1 h-[58px] rounded-full font-medium transition-colors border"
          style={{
            backgroundColor: "#FFFFFF",
            color: "#0F173E",
            borderColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          View Payment History
        </button>
      </div>
    </div>
  )
}

