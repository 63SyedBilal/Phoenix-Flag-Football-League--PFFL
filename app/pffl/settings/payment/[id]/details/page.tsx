"use client"

import { useState } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { Eye, EyeOff, Calendar } from "lucide-react"
import Image from "next/image"

export default function PaymentDetailsPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const paymentMethod = searchParams.get("method") || "stripe"
  
  const [formData, setFormData] = useState({
    cardholderName: "",
    cardNumber: "",
    expiryDate: "",
    cvv: "",
    agreeToTerms: false,
  })
  const [showCvv, setShowCvv] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    // Simulate payment processing
    setTimeout(() => {
      setIsLoading(false)
      router.push("/pffl/settings/payment/success")
    }, 2000)
  }

  const formatCardNumber = (value: string) => {
    const v = value.replace(/\s+/g, "").replace(/[^0-9]/gi, "")
    const matches = v.match(/\d{4,16}/g)
    const match = (matches && matches[0]) || ""
    const parts = []
    for (let i = 0, len = match.length; i < len; i += 4) {
      parts.push(match.substring(i, i + 4))
    }
    if (parts.length) {
      return parts.join(" ")
    } else {
      return v
    }
  }

  const formatExpiryDate = (value: string) => {
    const v = value.replace(/\D/g, "")
    if (v.length >= 2) {
      return v.substring(0, 2) + "/" + v.substring(2, 4)
    }
    return v
  }

  return (
    <div className="flex flex-col gap-6">
      {/* Back Arrow */}
      <button
        onClick={() => router.back()}
        className="w-[50px] h-[50px] p-[10px] rounded-full bg-[#F2F2F2] hover:bg-gray-200 transition-colors flex items-center justify-center flex-shrink-0 mb-2"
      >
        <Image src="/assets/image/Back arrow.svg" alt="Back" width={24} height={24} />
      </button>

      {/* Header */}
      <div className="mb-4">
        <h1
          className="text-3xl font-bold mb-2"
          style={{
            fontFamily: "Lato, sans-serif",
            fontWeight: 700,
            color: "#111827",
          }}
        >
          Add Payment Details
        </h1>
        <p
          className="text-base"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#6B7280",
          }}
        >
          Enter your card information below to complete the payment securely.
        </p>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="flex flex-col gap-6">
        {/* Cardholder Name */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="cardholderName"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Cardholder Name
          </label>
          <input
            id="cardholderName"
            type="text"
            placeholder="Enter the name printed on your card"
            value={formData.cardholderName}
            onChange={(e) => setFormData({ ...formData, cardholderName: e.target.value })}
            required
            className="w-full h-12 px-3 py-[10px] rounded-md border"
            style={{
              border: "1px solid #D1D5DB",
              boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
              backgroundColor: "#FFFFFF",
              fontFamily: "Lato, sans-serif",
            }}
          />
        </div>

        {/* Card Number */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="cardNumber"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Card Number
          </label>
          <div className="relative">
            <input
              id="cardNumber"
              type="text"
              placeholder="16-digit card number"
              value={formData.cardNumber}
              onChange={(e) => {
                const formatted = formatCardNumber(e.target.value)
                setFormData({ ...formData, cardNumber: formatted })
              }}
              maxLength={19}
              required
              className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
              style={{
                border: "1px solid #D1D5DB",
                boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                backgroundColor: "#FFFFFF",
                fontFamily: "Lato, sans-serif",
              }}
            />
            <div className="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-1">
              <div className="w-6 h-4 bg-red-500 rounded-sm flex items-center justify-center">
                <div className="w-3 h-3 bg-yellow-400 rounded-full"></div>
              </div>
              <div className="w-6 h-4 bg-red-600 rounded-sm -ml-1"></div>
            </div>
          </div>
        </div>

        {/* Expiry Date and CVV in same row */}
        <div className="grid grid-cols-2 gap-4">
          {/* Expiry Date */}
          <div className="flex flex-col gap-2">
            <label
              htmlFor="expiryDate"
              className="font-medium"
              style={{
                fontFamily: "Lato, sans-serif",
                fontWeight: 500,
                fontSize: "14px",
                lineHeight: "20px",
                color: "#111827",
              }}
            >
              Expiry Date
            </label>
            <div className="relative">
              <input
                id="expiryDate"
                type="text"
                placeholder="MM/YY"
                value={formData.expiryDate}
                onChange={(e) => {
                  const formatted = formatExpiryDate(e.target.value)
                  setFormData({ ...formData, expiryDate: formatted })
                }}
                maxLength={5}
                required
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                  fontFamily: "Lato, sans-serif",
                }}
              />
              <Calendar className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
            </div>
          </div>

          {/* CVV */}
          <div className="flex flex-col gap-2">
            <label
              htmlFor="cvv"
              className="font-medium"
              style={{
                fontFamily: "Lato, sans-serif",
                fontWeight: 500,
                fontSize: "14px",
                lineHeight: "20px",
                color: "#111827",
              }}
            >
              CVV
            </label>
            <div className="relative">
              <input
                id="cvv"
                type={showCvv ? "text" : "password"}
                placeholder="3-digit code"
                value={formData.cvv}
                onChange={(e) => {
                  const v = e.target.value.replace(/\D/g, "").substring(0, 3)
                  setFormData({ ...formData, cvv: v })
                }}
                maxLength={3}
                required
                className="w-full h-12 px-3 py-[10px] pr-10 rounded-md border"
                style={{
                  border: "1px solid #D1D5DB",
                  boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
                  backgroundColor: "#FFFFFF",
                  fontFamily: "Lato, sans-serif",
                }}
              />
              <button
                type="button"
                onClick={() => setShowCvv(!showCvv)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 transition-colors"
              >
                {showCvv ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>
        </div>

        {/* Terms & Privacy */}
        <div className="flex items-center gap-2">
          <input
            id="terms"
            type="checkbox"
            checked={formData.agreeToTerms}
            onChange={(e) => setFormData({ ...formData, agreeToTerms: e.target.checked })}
            className="rounded border-border"
            required
          />
          <label
            htmlFor="terms"
            className="text-xs"
            style={{
              fontFamily: "Lato, sans-serif",
              color: "#6B7280",
            }}
          >
            I agree to{" "}
            <a href="#" className="text-[#0F173E] hover:underline">
              Terms & Privacy
            </a>
          </label>
        </div>

        {/* Pay Now Button */}
        <button
          type="submit"
          disabled={isLoading || !formData.agreeToTerms}
          className="w-full h-[58px] rounded-full text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          {isLoading ? "Processing..." : "Pay Now"}
        </button>
      </form>
    </div>
  )
}



