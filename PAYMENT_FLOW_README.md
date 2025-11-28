# Payment Flow Documentation

## Overview
This document describes the complete payment flow implementation using Stripe for the Phoenix Football League (PFFL) application.

## Flow Steps

### 1️⃣ User Joins League → Backend Creates "Unpaid" Payment Record

When a user accepts a league invitation, the backend automatically creates an "unpaid" payment record.

**Example Payment Record:**
```json
{
  "_id": "paymentId123",
  "userId": "...",
  "leagueId": "...",
  "amount": 250,
  "status": "unpaid",
  "transactionId": null,
  "paymentMethod": null
}
```

**Implementation:**
- Location: `controller/notification.ts` (when accepting invite)
- Calls: `createPayment(userId, leagueId, teamId?)`

---

### 2️⃣ Frontend → "Pay Now" Button Opens Payment Method Page

User clicks the "Pay Now" card from the notifications page.

**Route:**
```
/pffl/settings/payment/[id]?leagueId=xxx
```

**Page:**
- `app/pffl/settings/payment/[id]/page.tsx`
- Displays payment methods: PayPal and Stripe
- Fetches payment amount from `/api/payments/my?leagueId=xxx`
- User selects payment method (Stripe by default)

---

### 3️⃣ User Enters Card Details → Frontend Calls Stripe API

User proceeds to the payment details page and enters card information.

**Route:**
```
/pffl/settings/payment/[id]/details?method=stripe&leagueId=xxx
```

**Page:**
- `app/pffl/settings/payment/[id]/details/page.tsx`
- Form fields:
  - Cardholder Name
  - Card Number (formatted as: XXXX XXXX XXXX XXXX)
  - Expiry Date (MM/YY format)
  - CVV (3-digit code)
  - Terms & Privacy checkbox

**Frontend Process:**
1. Fetches payment record: `GET /api/payments/my?leagueId=xxx`
2. Calls Stripe API: `POST /api/payments/stripe`

**Request Body:**
```json
{
  "paymentId": "paymentId123",
  "cardNumber": "4242 4242 4242 4242",
  "expiryDate": "12/26",
  "cvv": "123"
}
```

---

### 4️⃣ Backend Processes Stripe Payment

**API Endpoint:**
- `app/api/payments/stripe/route.ts`
- Method: `POST`

**Three Steps:**

#### ✔️ Step A — Find and Validate Payment Record
- Checks if payment exists
- Verifies payment belongs to the authenticated user
- Ensures payment is not already paid

#### ✔️ Step B — Process Stripe Charge
```typescript
// 1. Create payment method
const paymentMethod = await stripe.paymentMethods.create({
  type: "card",
  card: {
    number: cardNumber.replace(/\s/g, ""),
    exp_month: parseInt(exp_month),
    exp_year: parseInt(fullYear),
    cvc: cvv,
  },
})

// 2. Create payment intent
const paymentIntent = await stripe.paymentIntents.create({
  amount: Math.round(payment.amount * 100), // Convert to cents
  currency: "usd",
  payment_method: paymentMethod.id,
  confirm: true,
  automatic_payment_methods: {
    enabled: true,
    allow_redirects: "never",
  },
  description: `Payment for league ${payment.leagueId}`,
  metadata: {
    paymentId: payment._id.toString(),
    userId: payment.userId.toString(),
    leagueId: payment.leagueId.toString(),
  },
})
```

#### ✔️ Step C — Update Database
```typescript
payment.status = "paid"
payment.transactionId = paymentIntent.id
payment.paymentMethod = "stripe"
await payment.save()
```

**Response:**
```json
{
  "success": true,
  "message": "Payment successful",
  "transactionId": "pi_3ut7D....",
  "data": { /* populated payment object */ }
}
```

---

### 5️⃣ Frontend Redirects to Success Page

**Route:**
```
/pffl/settings/payment/success?paymentId=xxx
```

**Page:**
- `app/pffl/settings/payment/success/page.tsx`
- Displays:
  - Success icon and message
  - Payment details (ID, status, date)
  - "What's Next" information
  - Action buttons:
    - Go to Home
    - View Payment History

---

## Environment Variables

Add the following to your `.env.local` file:

```env
# Stripe Keys
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

**Note:** These keys can be obtained from your Stripe Dashboard:
- Test Mode: https://dashboard.stripe.com/test/apikeys
- Live Mode: https://dashboard.stripe.com/apikeys

---

## Testing

### Test Card Numbers (Stripe Test Mode)

| Card Number | Description |
|-------------|-------------|
| 4242 4242 4242 4242 | Successful payment |
| 4000 0000 0000 9995 | Payment declined |
| 4000 0000 0000 3220 | Requires authentication |

**Test Card Details:**
- Expiry Date: Any future date (e.g., 12/26)
- CVV: Any 3 digits (e.g., 123)

---

## API Endpoints Summary

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/payments/my` | GET | Get payment for user and league |
| `/api/payments/unpaid` | GET | Get all unpaid payments for user |
| `/api/payments/stripe` | POST | Process Stripe payment |
| `/api/payments/pay` | PATCH | Update payment status (legacy) |

---

## Database Schema

**Payment Model** (`modules/payment.ts`):
```typescript
{
  userId: ObjectId (ref: User)
  leagueId: ObjectId (ref: League)
  amount: Number
  status: "paid" | "unpaid"
  transactionId: String
  paymentMethod: "stripe" | "paypal"
  teamName: String
  playerName: String
  captainName: String
  freeAgentName: String
  createdAt: Date
  updatedAt: Date
}
```

---

## Security Considerations

1. **Token Verification**: All API endpoints verify JWT tokens
2. **User Authorization**: Payment operations are restricted to the payment owner
3. **Stripe Secret Key**: Never exposed to the frontend
4. **HTTPS Required**: Stripe requires HTTPS in production
5. **PCI Compliance**: Card details are sent directly to Stripe (not stored in our database)

---

## Error Handling

### Frontend Errors
- Invalid card number format
- Missing required fields
- Network errors
- Authentication errors

### Backend Errors
- Payment not found
- Unauthorized access
- Payment already processed
- Stripe API errors
- Database errors

All errors are caught and displayed to the user with appropriate messages.

---

## Future Enhancements

1. **PayPal Integration**: Add PayPal payment processing
2. **Email Notifications**: Send email confirmations on successful payments
3. **Receipt Generation**: Generate PDF receipts
4. **Refund System**: Allow superadmins to issue refunds
5. **Payment Plans**: Support installment payments
6. **Multiple Currencies**: Support international payments

---

## Support

For issues or questions:
- Check Stripe Dashboard for transaction details
- Review server logs for detailed payment processing logs
- Contact Stripe support for payment-related issues

---

**Last Updated:** November 28, 2025

