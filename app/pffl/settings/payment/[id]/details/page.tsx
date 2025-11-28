"use client"

import { useState, useEffect } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { loadStripe } from "@stripe/stripe-js"
import { Elements, CardElement, useStripe, useElements } from "@stripe/react-stripe-js"
import Image from "next/image"

// Initialize Stripe
const stripePromise = loadStripe(
  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || ""
)

// Card Element styling
const CARD_ELEMENT_OPTIONS = {
  style: {
    base: {
      color: "#111827",
      fontFamily: "Lato, sans-serif",
      fontSize: "16px",
      "::placeholder": {
        color: "#9CA3AF",
      },
    },
    invalid: {
      color: "#EF4444",
      iconColor: "#EF4444",
    },
  },
}

function PaymentForm() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const stripe = useStripe()
  const elements = useElements()
  
  const paymentMethod = searchParams.get("method") || "stripe"
  const leagueId = searchParams.get("leagueId")
  
  const [formData, setFormData] = useState({
    cardholderName: "",
    agreeToTerms: false,
  })
  const [isLoading, setIsLoading] = useState(false)
  const [isProcessing, setIsProcessing] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [clientSecret, setClientSecret] = useState<string | null>(null)
  const [paymentId, setPaymentId] = useState<string | null>(null)
  const [paymentIntentId, setPaymentIntentId] = useState<string | null>(null)
  const [stripeReady, setStripeReady] = useState(false)

  // Check if Stripe key is available
  useEffect(() => {
    if (!process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY) {
      setError("Stripe is not configured. Please contact support.")
      return
    }
    setStripeReady(true)
  }, [])

  useEffect(() => {
    // Create Payment Intent when component mounts and Stripe is ready
    if (!stripeReady) return

    const createPaymentIntent = async () => {
      if (!leagueId) {
        setError("League ID is missing. Please try again.")
        return
      }

      try {
        const token = localStorage.getItem("token")
        if (!token) {
          setError("Please login to continue. Your session may have expired.")
          return
        }

        // Step 1: Get the payment ID for this league
        console.log("Fetching payment record...")
        const paymentResponse = await fetch(`/api/payments/my?leagueId=${leagueId}`, {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        })

        if (!paymentResponse.ok) {
          const paymentError = await paymentResponse.json()
          setError(paymentError.error || "Failed to retrieve payment information.")
          return
        }

        const paymentData = await paymentResponse.json()
        if (!paymentData.success || !paymentData.data) {
          setError("Payment record not found. Please contact support.")
          return
        }

        const fetchedPaymentId = paymentData.data._id
        setPaymentId(fetchedPaymentId)

        // Step 2: Create Payment Intent
        console.log("Creating Payment Intent...")
        const intentResponse = await fetch("/api/payments/create-intent", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
          },
          body: JSON.stringify({
            paymentId: fetchedPaymentId,
          }),
        })

        const intentData = await intentResponse.json()

        if (intentResponse.ok && intentData.success) {
          setClientSecret(intentData.clientSecret)
          setPaymentIntentId(intentData.paymentIntentId)
          console.log("✅ Payment Intent created successfully")
        } else {
          if (intentData.alreadyPaid) {
            setError("This payment has already been processed. Redirecting to payment history...")
            setTimeout(() => {
              router.push("/pffl/settings/payment-history")
            }, 3000)
          } else if (intentResponse.status === 401) {
            setError("Your session has expired. Please log in again.")
            setTimeout(() => {
              router.push("/login")
            }, 2000)
          } else {
            setError(intentData.error || "Failed to initialize payment. Please try again.")
          }
        }
      } catch (err: any) {
        console.error("Error creating payment intent:", err)
        setError("An unexpected error occurred. Please try again.")
      }
    }

    createPaymentIntent()
  }, [leagueId, router, stripeReady])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)

    // Prevent double submission
    if (isProcessing) {
      console.warn("Payment already in progress, ignoring duplicate submission")
      return
    }

    if (!stripe || !elements) {
      setError("Stripe has not loaded yet. Please wait and try again.")
      return
    }

    if (!clientSecret || !paymentId || !paymentIntentId) {
      setError("Payment not initialized. Please refresh the page and try again.")
      return
    }

    setIsLoading(true)
    setIsProcessing(true)

    try {
      const cardElement = elements.getElement(CardElement)

      if (!cardElement) {
        setError("Card element not found. Please refresh the page.")
        setIsLoading(false)
        setIsProcessing(false)
        return
      }

      console.log("Processing payment with Stripe Elements...")

      // Confirm payment with Stripe
      const { error: stripeError, paymentIntent } = await stripe.confirmCardPayment(
        clientSecret,
        {
          payment_method: {
            card: cardElement,
            billing_details: {
              name: formData.cardholderName,
            },
          },
        }
      )

      if (stripeError) {
        console.error("Stripe error:", stripeError)
        setError(stripeError.message || "Payment failed. Please try again.")
        setIsLoading(false)
        setIsProcessing(false)
        return
      }

      if (paymentIntent && paymentIntent.status === "succeeded") {
        console.log("✅ Payment succeeded! Confirming with backend...")

        // Confirm payment with our backend
        const token = localStorage.getItem("token")
        const confirmResponse = await fetch("/api/payments/confirm", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
          },
          body: JSON.stringify({
            paymentId,
            paymentIntentId: paymentIntent.id,
          }),
        })

        const confirmData = await confirmResponse.json()

        if (confirmResponse.ok && confirmData.success) {
          console.log("✅ Payment confirmed! Redirecting...")
          router.push(`/pffl/settings/payment/success?paymentId=${paymentId}`)
        } else {
          setError(confirmData.error || "Payment succeeded but confirmation failed. Please contact support.")
          setIsLoading(false)
          setIsProcessing(false)
        }
      } else {
        setError("Payment was not successful. Please try again.")
        setIsLoading(false)
        setIsProcessing(false)
      }
    } catch (err: any) {
      console.error("Error processing payment:", err)
      setError("An unexpected error occurred. Please try again or contact support.")
      setIsLoading(false)
      setIsProcessing(false)
    }
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
        <div
          className="mt-2 flex items-center gap-2 text-sm"
          style={{
            fontFamily: "Lato, sans-serif",
            color: "#059669",
          }}
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Secured by Stripe - Your card details never reach our servers</span>
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md">
          {error}
        </div>
      )}

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

        {/* Card Element (Stripe) */}
        <div className="flex flex-col gap-2">
          <label
            htmlFor="card-element"
            className="font-medium"
            style={{
              fontFamily: "Lato, sans-serif",
              fontWeight: 500,
              fontSize: "14px",
              lineHeight: "20px",
              color: "#111827",
            }}
          >
            Card Details
          </label>
          <div
            className="w-full rounded-md border"
            style={{
              border: "1px solid #D1D5DB",
              boxShadow: "0px 1px 2px 0px rgba(16, 24, 40, 0.05)",
              backgroundColor: "#FFFFFF",
              padding: "12px",
              minHeight: "48px",
            }}
          >
            {stripeReady && elements ? (
              <CardElement 
                options={CARD_ELEMENT_OPTIONS}
                onChange={(e) => {
                  if (e.error) {
                    console.error("Card element error:", e.error)
                  }
                }}
              />
            ) : (
              <div className="flex items-center justify-center h-6">
                <span
                  className="text-sm"
                  style={{
                    fontFamily: "Lato, sans-serif",
                    color: "#9CA3AF",
                  }}
                >
                  Loading secure payment form...
                </span>
              </div>
            )}
          </div>
          <p
            className="text-xs"
            style={{
              fontFamily: "Lato, sans-serif",
              color: "#6B7280",
            }}
          >
            Enter your card number, expiry date, and CVC
          </p>
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
          disabled={!stripe || isLoading || isProcessing || !formData.agreeToTerms || !clientSecret}
          className="w-full h-[58px] rounded-full text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style={{
            backgroundColor: "#0F173E",
            fontFamily: "Lato, sans-serif",
          }}
        >
          {isLoading || isProcessing ? (
            <span className="flex items-center justify-center gap-2">
              <svg
                className="animate-spin h-5 w-5 text-white"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                ></circle>
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
              Processing Payment...
            </span>
          ) : !clientSecret ? (
            "Initializing..."
          ) : (
            "Pay Now"
          )}
        </button>
      </form>
    </div>
  )
}

export default function PaymentDetailsPage() {
  // Check if Stripe key is configured
  const stripeKey = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY

  if (!stripeKey) {
    return (
      <div className="flex flex-col gap-6">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md">
          <h2 className="font-bold mb-2">Stripe Configuration Error</h2>
          <p>
            Stripe is not properly configured. Please add NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY to your environment variables.
          </p>
        </div>
      </div>
    )
  }

  return (
    <Elements stripe={stripePromise}>
      <PaymentForm />
    </Elements>
  )
}
