# Stripe Payment Setup Guide

## Quick Start

### Step 1: Create a Stripe Account
1. Go to https://stripe.com
2. Sign up for a free account
3. Complete the account setup

### Step 2: Get Your API Keys
1. Log in to Stripe Dashboard: https://dashboard.stripe.com
2. Click on "Developers" in the left sidebar
3. Click on "API keys"
4. You will see two keys:
   - **Publishable key** (starts with `pk_test_`)
   - **Secret key** (starts with `sk_test_`) - Click "Reveal test key"

### Step 3: Add Keys to Your Project

You need to manually add these keys to your environment variables:

**Option 1: Create `.env.local` file**
```bash
# In your project root directory, create a file named .env.local
# Add these lines (replace with your actual keys):

NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
```

**Option 2: Use System Environment Variables**
```bash
# Windows (PowerShell)
$env:NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_your_key_here"
$env:STRIPE_SECRET_KEY="sk_test_your_key_here"

# Windows (Command Prompt)
set NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
set STRIPE_SECRET_KEY=sk_test_your_key_here

# Mac/Linux
export NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_your_key_here"
export STRIPE_SECRET_KEY="sk_test_your_key_here"
```

### Step 4: Restart Your Development Server

After adding the environment variables, restart your Next.js development server:

```bash
# Stop the server (Ctrl+C)
# Then restart:
npm run dev
```

---

## Test Payment Flow

### Test Card Numbers

Use these test cards in the payment form:

| Card Number | Scenario |
|-------------|----------|
| `4242 4242 4242 4242` | ✅ Successful payment |
| `4000 0000 0000 9995` | ❌ Payment declined |
| `4000 0000 0000 0002` | ❌ Card declined |
| `4000 0000 0000 3220` | 🔐 Requires 3D Secure |

**Card Details for Testing:**
- **Expiry Date:** Any future date (e.g., `12/26`)
- **CVV:** Any 3 digits (e.g., `123`)
- **Name:** Any name

---

## Verify Installation

Run this command to check if Stripe is installed:

```bash
npm list stripe @stripe/stripe-js
```

You should see:
```
├── @stripe/stripe-js@X.X.X
└── stripe@X.X.X
```

---

## Production Setup

### When Going Live:

1. **Complete Stripe Account Verification**
   - Provide business information
   - Add bank account for payouts
   - Complete identity verification

2. **Switch to Live Mode**
   - In Stripe Dashboard, toggle from "Test mode" to "Live mode"
   - Get new API keys (will start with `pk_live_` and `sk_live_`)

3. **Update Environment Variables**
   - Replace test keys with live keys
   - Use production environment variables
   - **IMPORTANT:** Never commit live keys to version control

4. **Enable HTTPS**
   - Stripe requires HTTPS in production
   - SSL certificate is mandatory

---

## Troubleshooting

### Error: "No API key provided"
**Solution:** Make sure your `.env.local` file exists and contains the correct keys. Restart the dev server.

### Error: "Invalid API Key"
**Solution:** 
- Check that you copied the full key (including `pk_test_` or `sk_test_`)
- Verify you're using the correct key (publishable vs secret)
- Make sure there are no extra spaces

### Error: "Your card was declined"
**Solution:** Use the test card `4242 4242 4242 4242` for successful test payments.

### Payment not processing
**Solution:**
1. Check browser console for errors
2. Check server logs for detailed error messages
3. Verify Stripe Dashboard for payment attempts
4. Ensure environment variables are loaded (restart dev server)

---

## Checking Payment Status

### In Your Application:
- Go to Settings → Payment History
- Check notifications for payment reminders

### In Stripe Dashboard:
1. Log in to https://dashboard.stripe.com
2. Go to "Payments" in the left sidebar
3. See all payment attempts (successful and failed)
4. Click on any payment for detailed information

---

## Security Best Practices

✅ **DO:**
- Keep secret key on server only
- Use environment variables for keys
- Enable webhook signature verification
- Use HTTPS in production
- Regularly rotate API keys

❌ **DON'T:**
- Commit API keys to Git
- Expose secret key to frontend
- Use test keys in production
- Share API keys in plain text
- Store card details in your database

---

## Webhook Setup (Optional but Recommended)

Webhooks notify your application when payment events occur:

1. In Stripe Dashboard, go to "Developers" → "Webhooks"
2. Click "Add endpoint"
3. Enter your webhook URL: `https://your-domain.com/api/webhooks/stripe`
4. Select events to listen for:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Copy the webhook signing secret
6. Add to `.env.local`:
   ```
   STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
   ```

---

## Support Resources

- **Stripe Documentation:** https://stripe.com/docs
- **API Reference:** https://stripe.com/docs/api
- **Testing Guide:** https://stripe.com/docs/testing
- **Support:** https://support.stripe.com

---

## Quick Reference

```bash
# Install Stripe
npm install stripe @stripe/stripe-js --legacy-peer-deps

# Environment Variables
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# Test Card
4242 4242 4242 4242

# Start Development
npm run dev
```

---

**Need Help?** Check the `PAYMENT_FLOW_README.md` file for detailed implementation documentation.

