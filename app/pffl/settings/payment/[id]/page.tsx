"use client"

import { useState } from "react"
import { useRouter, useParams } from "next/navigation"
import Image from "next/image"

const paymentMethods = [
  { id: "paypal", name: "PayPal", logo: "PayPal" },
  { id: "stripe", name: "Stripe", logo: "stripe" },
]

export default function PaymentMethodPage() {
  const router = useRouter()
  const params = useParams()
  const id = params?.id as string
  const [selectedMethod, setSelectedMethod] = useState("stripe")
  const amountDue = "$25.00"

  const handleContinue = () => {
    router.push(`/pffl/settings/payment/${id}/details?method=${selectedMethod}`)
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
          Complete Your Payment
        </h1>
        <p
          className="text-base"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#6B7280",
          }}
        >
          Choose your preferred method to pay your league fee.
        </p>
      </div>

      {/* Amount Due */}
      <div className="flex items-center justify-between mb-6">
        <span
          className="font-bold text-base"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#111827",
          }}
        >
          Amount Due:
        </span>
        <span
          className="font-bold text-base"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#111827",
          }}
        >
          {amountDue}
        </span>
      </div>

      {/* Select Payment Method */}
      <div className="flex flex-col gap-4">
        <h2
          className="font-bold text-base mb-2"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#111827",
          }}
        >
          Select Payment Method
        </h2>

        {paymentMethods.map((method) => (
          <button
            key={method.id}
            onClick={() => setSelectedMethod(method.id)}
            type="button"
            className="w-full bg-white border rounded-xl p-6 flex items-center justify-between hover:bg-gray-50 transition-colors"
            style={{
              borderColor: selectedMethod === method.id ? "#3B82F6" : "rgba(0, 0, 0, 0.12)",
              borderWidth: "1px",
            }}
          >
            <div className="flex items-center gap-4">
              {method.id === "paypal" ? (
                <div className="flex items-center">
                  <span
                    className="font-bold text-xl"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      color: "#0070BA",
                    }}
                  >
                    P
                  </span>
                  <span
                    className="font-normal text-xl"
                    style={{
                      fontFamily: "Lato, sans-serif",
                      color: "#009CDE",
                    }}
                  >
                    ayPal
                  </span>
                </div>
              ) : (
                <span
                  className="font-medium text-lg lowercase"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    color: "#635BFF",
                  }}
                >
                  stripe
                </span>
              )}
            </div>
            <div
              className="w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0"
              style={{
                borderColor: selectedMethod === method.id ? "#3B82F6" : "#9CA3AF",
                backgroundColor: selectedMethod === method.id ? "#3B82F6" : "transparent",
              }}
            >
              {selectedMethod === method.id && (
                <div className="w-3 h-3 rounded-full bg-white"></div>
              )}
            </div>
          </button>
        ))}
      </div>

      {/* Continue Button */}
      <button
        onClick={handleContinue}
        className="w-full h-[58px] rounded-full text-white font-medium transition-colors mt-4"
        style={{
          backgroundColor: "#0F173E",
          fontFamily: "Lato, sans-serif",
        }}
      >
        Continue
      </button>
    </div>
  )
}






