# Migration Guide: Old → New Payment API

## Overview
The payment system has been upgraded with security improvements. The old `/api/payments/stripe` endpoint still works, but we recommend migrating to the new `/api/payments/process` endpoint.

---

## Quick Comparison

### Old Endpoint (Still Works)
```javascript
POST /api/payments/stripe
{
  "paymentId": "payment123",
  "cardNumber": "4242424242424242",
  "expiryDate": "12/26",
  "cvv": "123"
}
```

### New Endpoint (Recommended)
```javascript
POST /api/payments/process
{
  "paymentId": "payment123",
  "paymentMethod": "stripe",  // NEW: specify method
  "cardNumber": "4242424242424242",
  "expiryDate": "12/26",
  "cvv": "123",
  "idempotencyKey": "unique_key"  // NEW: optional
}
```

---

## What's New?

### 1. Payment Method Selection
You can now specify which payment processor to use:
```javascript
paymentMethod: "stripe"  // or "paypal" (coming soon)
```

### 2. Idempotency Key
Optional but recommended for duplicate prevention:
```javascript
idempotencyKey: `payment_${paymentId}_${Date.now()}_${randomString}`
```

### 3. Better Error Responses
More detailed error messages with error codes:
```javascript
{
  "success": false,
  "error": "Your card was declined. Please try a different card.",
  "errorType": "StripeCardError",
  "alreadyPaid": false  // NEW: indicates if payment was already processed
}
```

---

## Frontend Migration

### Old Code:
```javascript
const response = await fetch("/api/payments/stripe", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${token}`,
  },
  body: JSON.stringify({
    paymentId,
    cardNumber: formData.cardNumber,
    expiryDate: formData.expiryDate,
    cvv: formData.cvv,
  }),
})
```

### New Code:
```javascript
// Generate idempotency key
const idempotencyKey = `payment_${paymentId}_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`

const response = await fetch("/api/payments/process", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${token}`,
  },
  body: JSON.stringify({
    paymentId,
    paymentMethod: "stripe",  // NEW
    cardNumber: formData.cardNumber,
    expiryDate: formData.expiryDate,
    cvv: formData.cvv,
    idempotencyKey,  // NEW
  }),
})

// Handle response
const data = await response.json()

if (response.ok && data.success) {
  // Success
  router.push(`/pffl/settings/payment/success?paymentId=${paymentId}`)
} else if (data.alreadyPaid) {
  // Already paid - redirect to history
  setError("This payment has already been processed.")
  setTimeout(() => router.push("/pffl/settings/payment-history"), 3000)
} else {
  // Other error
  setError(data.error || "Payment failed")
}
```

---

## Error Handling Migration

### Old Code:
```javascript
if (!response.ok) {
  setError("Payment failed")
}
```

### New Code:
```javascript
if (!response.ok) {
  const data = await response.json()
  
  // Handle specific error cases
  if (data.alreadyPaid) {
    setError("Payment already processed. Redirecting...")
    setTimeout(() => router.push("/pffl/settings/payment-history"), 3000)
  } else if (response.status === 401) {
    setError("Session expired. Please log in again.")
    setTimeout(() => router.push("/login"), 2000)
  } else if (response.status === 403) {
    setError("You do not have permission to process this payment.")
  } else {
    setError(data.error || "Payment failed. Please try again.")
  }
}
```

---

## Double-Click Protection

### Add This to Your Component:
```javascript
const [isProcessing, setIsProcessing] = useState(false)

const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault()
  
  // Prevent double submission
  if (isProcessing) {
    console.warn("Payment already in progress")
    return
  }
  
  setIsProcessing(true)
  
  try {
    // ... payment processing
  } catch (error) {
    // ... error handling
  } finally {
    setIsProcessing(false)
  }
}
```

### Update Your Button:
```javascript
<button
  type="submit"
  disabled={isLoading || isProcessing || !formData.agreeToTerms}
>
  {isProcessing ? "Processing..." : "Pay Now"}
</button>
```

---

## Testing Checklist

After migration:

- [ ] Test successful payment
- [ ] Test double-click (should be prevented)
- [ ] Test expired card (should show user-friendly error)
- [ ] Test already paid (should redirect to history)
- [ ] Test session timeout (should redirect to login)
- [ ] Test with invalid payment ID (should show error)

---

## Backward Compatibility

**Good News:** The old `/api/payments/stripe` endpoint still works!

All security improvements have been added to both:
- ✅ `/api/payments/stripe` (old endpoint)
- ✅ `/api/payments/process` (new endpoint)

You can migrate at your own pace. Both endpoints have:
- Card data protection
- Payment ownership verification
- Idempotency checks
- Enhanced error handling
- Security logging

---

## When to Migrate?

**Migrate Now If:**
- You're adding PayPal support
- You want better error handling
- You need idempotency keys

**Can Wait If:**
- Current implementation works fine
- Only using Stripe
- Planning larger refactor soon

---

## Need Help?

Check these files:
- `PAYMENT_SECURITY_IMPROVEMENTS.md` - Full security documentation
- `SECURITY_IMPROVEMENTS_SUMMARY.md` - Quick reference
- `app/pffl/settings/payment/[id]/details/page.tsx` - Reference implementation

---

## Summary

| Feature | Old Endpoint | New Endpoint |
|---------|-------------|--------------|
| Security | ✅ | ✅ |
| Stripe support | ✅ | ✅ |
| PayPal support | ❌ | 🔜 Soon |
| Idempotency | Manual | Built-in |
| Error codes | Basic | Detailed |
| Backward compatible | N/A | ✅ |

**Recommendation:** Migrate to new endpoint for better PayPal support and error handling.

---

**Last Updated:** November 28, 2025

