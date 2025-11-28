# Fix: Stripe Elements Not Showing

## 🔍 Problem
- Error: "Cannot read properties of undefined (reading 'match')"
- Card number, expiry date, and CVV fields not showing

## ✅ Solution

### Step 1: Add Stripe Publishable Key

The error occurs because `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` is not set.

**Create or update `.env.local` file in your project root:**

```env
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
```

**To get your Stripe keys:**
1. Go to https://dashboard.stripe.com
2. Navigate to: **Developers** → **API keys**
3. Copy the **Publishable key** (starts with `pk_test_`)
4. Copy the **Secret key** (starts with `sk_test_`)

### Step 2: Restart Development Server

After adding the keys, restart your Next.js server:

```bash
# Stop the server (Ctrl+C)
# Then restart:
npm run dev
```

### Step 3: Verify CardElement is Showing

After restarting, the payment page should show:
- ✅ "Card Details" label
- ✅ Stripe Elements iframe (secure card input)
- ✅ Card number, expiry, and CVC fields inside the iframe

---

## 🧪 Test

1. Navigate to payment page
2. You should see a secure card input field
3. Try entering test card: `4242 4242 4242 4242`
4. Fields should be visible and working

---

## 🔧 What Was Fixed

### 1. Added Stripe Key Validation
- Component now checks if key exists
- Shows error message if missing
- Prevents runtime errors

### 2. Improved CardElement Container
- Better styling for visibility
- Loading state while Stripe initializes
- Proper error handling

### 3. Better Error Messages
- Clear message if Stripe not configured
- Loading indicator while initializing
- Card element error handling

---

## 📋 Code Changes Made

### Before:
```tsx
const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)
// ❌ Fails if key is undefined
```

### After:
```tsx
const stripePromise = loadStripe(
  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || ""
)

// ✅ Check if key exists before rendering
if (!stripeKey) {
  return <ErrorComponent />
}
```

### CardElement Container:
```tsx
<div style={{ padding: "12px", minHeight: "48px" }}>
  {stripeReady && elements ? (
    <CardElement options={CARD_ELEMENT_OPTIONS} />
  ) : (
    <div>Loading secure payment form...</div>
  )}
</div>
```

---

## 🚨 Common Issues

### Issue 1: "Stripe is not configured"
**Solution:** Add `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` to `.env.local` and restart server

### Issue 2: CardElement not visible
**Solution:** 
- Check browser console for errors
- Verify Stripe key is correct
- Clear browser cache and reload

### Issue 3: "Cannot read properties of undefined"
**Solution:**
- Ensure `.env.local` file exists
- Restart development server after adding keys
- Check key format (should start with `pk_test_` or `pk_live_`)

---

## ✅ Verification Checklist

- [ ] `.env.local` file exists in project root
- [ ] `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` is set
- [ ] Development server restarted
- [ ] No console errors
- [ ] CardElement iframe is visible
- [ ] Can type in card fields

---

## 📖 Additional Resources

- **Stripe Dashboard:** https://dashboard.stripe.com/test/apikeys
- **Stripe Elements Docs:** https://stripe.com/docs/stripe-js
- **Setup Guide:** See `SETUP_STRIPE.md`

---

**After adding the Stripe key and restarting, the card fields should appear!** 🎉

