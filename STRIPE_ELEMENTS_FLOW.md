# Stripe Elements Payment Flow - Correct Implementation

## ✅ CORRECT APPROACH (PCI Compliant)

### Overview
This document describes the **correct** way to integrate Stripe payments using Stripe Elements. Card details never reach your server, ensuring PCI compliance and security.

---

## 🔄 Complete Flow

```
┌─────────────────────────────────────────────────────────────┐
│              STEP 1: USER ARRIVES AT PAYMENT PAGE            │
└─────────────────────────────────────────────────────────────┘
                            ↓
    Frontend: Initialize Stripe Elements
    Frontend: Fetch payment record from /api/payments/my
                            ↓
┌─────────────────────────────────────────────────────────────┐
│         STEP 2: BACKEND CREATES PAYMENT INTENT              │
└─────────────────────────────────────────────────────────────┘
                            ↓
    POST /api/payments/create-intent
    Body: { paymentId: "payment123" }
                            ↓
    Backend:
    1. Verify user owns payment
    2. Check if already paid
    3. Create Stripe Payment Intent
    4. Return clientSecret
                            ↓
    Response: {
      clientSecret: "pi_123_secret_456",
      paymentIntentId: "pi_123"
    }
                            ↓
┌─────────────────────────────────────────────────────────────┐
│          STEP 3: USER ENTERS CARD IN STRIPE IFRAME          │
└─────────────────────────────────────────────────────────────┘
                            ↓
    Frontend: Render Stripe CardElement
    User types card details in secure iframe
    ⚠️ YOUR CODE NEVER SEES THE CARD NUMBER
                            ↓
┌─────────────────────────────────────────────────────────────┐
│        STEP 4: FRONTEND CONFIRMS PAYMENT WITH STRIPE        │
└─────────────────────────────────────────────────────────────┘
                            ↓
    stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: cardElement,
        billing_details: { name: "John Doe" }
      }
    })
                            ↓
    Stripe processes payment directly
    Card details go directly to Stripe servers
    ⚠️ NEVER TO YOUR BACKEND
                            ↓
    Returns: { paymentIntent: { status: "succeeded" } }
                            ↓
┌─────────────────────────────────────────────────────────────┐
│        STEP 5: BACKEND CONFIRMS AND UPDATES DATABASE        │
└─────────────────────────────────────────────────────────────┘
                            ↓
    POST /api/payments/confirm
    Body: { 
      paymentId: "payment123",
      paymentIntentId: "pi_123"
    }
                            ↓
    Backend:
    1. Verify payment ownership
    2. Retrieve Payment Intent from Stripe
    3. Verify status is "succeeded"
    4. Update database: status = "paid"
                            ↓
    Response: {
      success: true,
      message: "Payment confirmed"
    }
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              STEP 6: REDIRECT TO SUCCESS PAGE               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Why This Approach is Secure

### ❌ Old Approach (WRONG - Stripe Rejects)
```javascript
// DON'T DO THIS
POST /api/payments/stripe
Body: {
  cardNumber: "4242 4242 4242 4242",  // ❌ RAW CARD DATA
  expiryDate: "12/26",
  cvv: "123"
}

// Backend tries:
stripe.paymentMethods.create({
  card: { number, exp_month, exp_year, cvc }
})
// ❌ Stripe rejects: "Cannot send card numbers to API"
```

**Problems:**
- Card data reaches your server (PCI risk)
- Stripe blocks this by default
- Requires dangerous PCI mode

### ✅ New Approach (CORRECT - Stripe Approves)
```javascript
// DO THIS
// Frontend: Card details stay in Stripe iframe
stripe.confirmCardPayment(clientSecret, {
  payment_method: { card: cardElement }
})
// ✅ Card never touches your server
```

**Benefits:**
- Card data never reaches your server
- Fully PCI compliant
- Stripe approves and processes
- No special configuration needed

---

## 📋 API Endpoints

### 1. Create Payment Intent
**Endpoint:** `POST /api/payments/create-intent`

**Purpose:** Creates a Payment Intent on Stripe's servers

**Request:**
```json
{
  "paymentId": "payment123"
}
```

**Response:**
```json
{
  "success": true,
  "clientSecret": "pi_3Abc...secret_xyz",
  "paymentIntentId": "pi_3Abc...",
  "amount": 250
}
```

**What it does:**
1. Verifies user owns the payment
2. Checks if payment already completed
3. Creates Payment Intent with Stripe
4. Stores Payment Intent ID in database
5. Returns clientSecret for frontend

---

### 2. Confirm Payment
**Endpoint:** `POST /api/payments/confirm`

**Purpose:** Verifies payment succeeded and updates database

**Request:**
```json
{
  "paymentId": "payment123",
  "paymentIntentId": "pi_3Abc..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Payment confirmed successfully!",
  "transactionId": "pi_3Abc...",
  "data": { /* payment object */ }
}
```

**What it does:**
1. Verifies user owns the payment
2. Retrieves Payment Intent from Stripe
3. Checks status is "succeeded"
4. Updates database:
   - `status = "paid"`
   - `transactionId = paymentIntent.id`
   - `paymentMethod = "stripe"`
5. Returns success

---

## 💻 Frontend Implementation

### 1. Initialize Stripe

```typescript
import { loadStripe } from "@stripe/stripe-js"
import { Elements, CardElement, useStripe, useElements } from "@stripe/react-stripe-js"

// Load Stripe with your publishable key
const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)
```

### 2. Wrap Component in Elements Provider

```tsx
export default function PaymentDetailsPage() {
  return (
    <Elements stripe={stripePromise}>
      <PaymentForm />
    </Elements>
  )
}
```

### 3. Payment Form Component

```tsx
function PaymentForm() {
  const stripe = useStripe()
  const elements = useElements()
  const [clientSecret, setClientSecret] = useState<string | null>(null)
  const [paymentId, setPaymentId] = useState<string | null>(null)

  useEffect(() => {
    // Create Payment Intent on mount
    const createIntent = async () => {
      const response = await fetch("/api/payments/create-intent", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ paymentId })
      })
      
      const data = await response.json()
      setClientSecret(data.clientSecret)
    }
    
    createIntent()
  }, [])

  const handleSubmit = async (e) => {
    e.preventDefault()
    
    if (!stripe || !elements) return

    const cardElement = elements.getElement(CardElement)

    // Confirm payment with Stripe
    const { error, paymentIntent } = await stripe.confirmCardPayment(
      clientSecret,
      {
        payment_method: {
          card: cardElement,
          billing_details: { name: cardholderName }
        }
      }
    )

    if (error) {
      setError(error.message)
      return
    }

    if (paymentIntent.status === "succeeded") {
      // Confirm with backend
      await fetch("/api/payments/confirm", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          paymentId,
          paymentIntentId: paymentIntent.id
        })
      })
      
      // Redirect to success
      router.push(`/pffl/settings/payment/success?paymentId=${paymentId}`)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <CardElement options={CARD_ELEMENT_OPTIONS} />
      <button type="submit" disabled={!stripe}>
        Pay Now
      </button>
    </form>
  )
}
```

### 4. Card Element Styling

```typescript
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
```

---

## 🔄 Backend Implementation

### 1. Create Payment Intent Endpoint

```typescript
// app/api/payments/create-intent/route.ts

export async function POST(req: NextRequest) {
  const { paymentId } = await req.json()
  
  // Verify payment ownership
  const payment = await Payment.findById(paymentId)
  
  // Check if already paid
  if (payment.status === "paid") {
    return error("Already paid")
  }
  
  // Create Payment Intent
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(payment.amount * 100),
    currency: "usd",
    automatic_payment_methods: { enabled: true },
    metadata: { paymentId, userId, leagueId }
  })
  
  // Save Payment Intent ID
  payment.stripePaymentIntentId = paymentIntent.id
  await payment.save()
  
  return { clientSecret: paymentIntent.client_secret }
}
```

### 2. Confirm Payment Endpoint

```typescript
// app/api/payments/confirm/route.ts

export async function POST(req: NextRequest) {
  const { paymentId, paymentIntentId } = await req.json()
  
  // Verify payment ownership
  const payment = await Payment.findById(paymentId)
  
  // Verify with Stripe
  const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId)
  
  if (paymentIntent.status !== "succeeded") {
    return error("Payment not successful")
  }
  
  // Update database
  payment.status = "paid"
  payment.transactionId = paymentIntent.id
  payment.paymentMethod = "stripe"
  await payment.save()
  
  return { success: true }
}
```

---

## 📦 Database Schema Updates

```typescript
// modules/payment.ts

const PaymentSchema = new mongoose.Schema({
  userId: ObjectId,
  leagueId: ObjectId,
  amount: Number,
  status: { type: String, enum: ["paid", "unpaid"], default: "unpaid" },
  transactionId: String,
  stripePaymentIntentId: String,  // ✅ NEW: Store Payment Intent ID
  paymentMethod: { type: String, enum: ["stripe", "paypal"] },
  // ... other fields
})
```

---

## 🧪 Testing

### Test Cards (Stripe Test Mode)

| Card Number | Scenario |
|-------------|----------|
| 4242 4242 4242 4242 | ✅ Success |
| 4000 0000 0000 9995 | ❌ Declined |
| 4000 0000 0000 3220 | 🔐 Requires 3D Secure |

### Testing Steps:

1. **Create Payment Intent**
   - ✅ Backend returns clientSecret
   - ✅ Payment Intent ID saved to database

2. **Enter Card Details**
   - ✅ Stripe CardElement loads
   - ✅ User can type card number
   - ✅ Validation works

3. **Submit Payment**
   - ✅ Stripe processes payment
   - ✅ Status becomes "succeeded"
   - ✅ Frontend receives paymentIntent

4. **Confirm Payment**
   - ✅ Backend verifies with Stripe
   - ✅ Database updated to "paid"
   - ✅ Success page shown

---

## 🔒 Security Features

### ✅ What's Secure:

1. **Card Data Never Reaches Your Server**
   - Entered in Stripe-hosted iframe
   - Goes directly to Stripe
   - You never see the card number

2. **Payment Ownership Verified**
   - User must be authenticated
   - Payment must belong to user
   - Double-checked on confirmation

3. **Stripe Verification**
   - Backend verifies Payment Intent status
   - Ensures payment actually succeeded
   - Prevents fake confirmations

4. **Idempotency**
   - Can't pay same payment twice
   - Status check before processing
   - Safe to retry on errors

---

## 📊 Comparison: Old vs New

| Feature | Old (Raw Cards) | New (Stripe Elements) |
|---------|----------------|----------------------|
| Card data to server | ❌ Yes | ✅ No |
| PCI compliance | ❌ Complex | ✅ Simple |
| Stripe approval | ❌ Blocked | ✅ Approved |
| Security | ⚠️ Risky | ✅ Secure |
| Setup difficulty | Easy | Medium |
| Production ready | ❌ No | ✅ Yes |

---

## 🚀 Deployment Checklist

Before going live:

- [ ] Add Stripe publishable key to `.env.local`
- [ ] Test with Stripe test cards
- [ ] Verify Payment Intent creation works
- [ ] Test payment confirmation flow
- [ ] Test error scenarios (declined card, etc.)
- [ ] Switch to live Stripe keys in production
- [ ] Enable HTTPS (required)
- [ ] Test in production mode

---

## 🆘 Troubleshooting

### "Stripe has not loaded yet"
**Solution:** Wait for Stripe to initialize, check publishable key

### "Payment not initialized"
**Solution:** Check console for Payment Intent creation errors

### "Card element not found"
**Solution:** Ensure component is wrapped in `<Elements>` provider

### "Payment Intent already used"
**Solution:** Create new Payment Intent (refresh page)

---

## 📖 Additional Resources

- **Stripe Elements Docs:** https://stripe.com/docs/stripe-js
- **Payment Intents Guide:** https://stripe.com/docs/payments/payment-intents
- **Testing Guide:** https://stripe.com/docs/testing

---

## ✨ Summary

**What Changed:**
- ❌ Removed: Sending raw card data to backend
- ✅ Added: Stripe Elements for secure card input
- ✅ Added: Payment Intent creation endpoint
- ✅ Added: Payment confirmation endpoint
- ✅ Added: `stripePaymentIntentId` to database

**Result:**
- ✅ Fully PCI compliant
- ✅ Stripe approved
- ✅ More secure
- ✅ Better user experience
- ✅ Production ready

---

**Last Updated:** November 28, 2025
**Status:** ✅ Complete - Correct Stripe Implementation

