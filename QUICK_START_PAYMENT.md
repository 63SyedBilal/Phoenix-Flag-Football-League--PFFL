# 🚀 Quick Start - Payment Integration

## ⚡ 3-Minute Setup

### Step 1: Get Stripe Keys (2 minutes)
1. Go to https://dashboard.stripe.com/register
2. Sign up (or log in if you have an account)
3. Navigate to: **Developers** → **API keys**
4. Copy these two keys:
   - **Publishable key** (starts with `pk_test_`)
   - **Secret key** (starts with `sk_test_` - click "Reveal")

### Step 2: Add Keys to Project (1 minute)
Create a file named `.env.local` in your project root:

```bash
# Copy and paste this, then replace with your actual keys:

NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_KEY_HERE
STRIPE_SECRET_KEY=sk_test_YOUR_KEY_HERE
```

### Step 3: Restart Server
```bash
# Stop your server (Ctrl+C)
# Start it again:
npm run dev
```

---

## ✅ Test It

### Test Card (Use this for all tests):
```
Card Number: 4242 4242 4242 4242
Expiry Date: 12/26
CVV: 123
Name: Any name
```

### Test Flow:
1. **As Superadmin:**
   - Create a league
   - Invite a user

2. **As User:**
   - Accept league invitation
   - Go to Notifications
   - Click "Pay Now"
   - Select "Stripe"
   - Enter test card details
   - Click "Pay Now"
   - See success page! ✅

---

## 📂 What Was Added

```
✅ Stripe SDK installed
✅ Payment API endpoint: /api/payments/stripe
✅ Success page: /pffl/settings/payment/success
✅ Updated payment details page
✅ Documentation files created
```

---

## 🎯 Payment Flow Summary

```
User Joins League
    ↓
Payment Record Created (unpaid)
    ↓
User Sees Notification
    ↓
Clicks "Pay Now"
    ↓
Selects Payment Method (Stripe)
    ↓
Enters Card Details
    ↓
Backend Processes with Stripe API
    ↓
Payment Status Updated (paid)
    ↓
Success Page Shown
```

---

## 🔍 Check Payment in Stripe

After making a test payment:
1. Go to https://dashboard.stripe.com/test/payments
2. You'll see your test payment listed
3. Click it to see full details

---

## 🐛 Troubleshooting

**"No API key provided"**
→ Add keys to `.env.local` and restart server

**"Your card was declined"**
→ Use test card: `4242 4242 4242 4242`

**Payment not working**
→ Check browser console and server logs for errors

---

## 📚 More Details

For complete documentation, see:
- `PAYMENT_IMPLEMENTATION_SUMMARY.md` - Full overview
- `PAYMENT_FLOW_README.md` - Detailed flow
- `SETUP_STRIPE.md` - Complete setup guide

---

## ✨ You're Done!

Your payment system is ready to test. Just add your Stripe keys and start testing! 🎉

**Test Card Again:**
- **4242 4242 4242 4242**
- **12/26**
- **123**

