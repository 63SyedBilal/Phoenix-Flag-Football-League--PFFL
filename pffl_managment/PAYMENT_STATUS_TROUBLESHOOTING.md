# Payment Status Troubleshooting Guide

## Issue: "Pay League Fee" button showing even after payment

### Expected Behavior
✅ **If league fee is PAID** → No "Pay League Fee" button should appear
❌ **If league fee is UNPAID** → "Pay League Fee" button should appear

---

## Debug Steps

### 1. Check Console Logs
After hot reload, check the console for these logs:

```
🎮 [GAME CARD] League: <League Name>, LeagueId: <ID>
🎮 [GAME CARD] Payment Status - Cached: true/false/null, HasPaid: true/false, Loading: true/false
```

**What to look for:**
- `Cached: true` → Payment is confirmed as PAID ✅
- `Cached: false` → Payment is UNPAID ❌
- `Cached: null` → Payment status not loaded yet, will trigger API call

### 2. Check Payment Status API Response
Look for this log:
```
💳 Checking league payment status: league=<leagueId>, user=<userId>
✅ League payment status checked successfully
```

**Expected API Response:**
```json
{
  "success": true,
  "data": {
    "isPaid": true  // Should be true if you paid
  }
}
```

### 3. Check LeaguePaymentProvider Cache
The provider caches payment status using key: `leagueId-userId`

**To clear cache and force refresh:**
```dart
// In your code, call:
Provider.of<LeaguePaymentProvider>(context, listen: false).clearAllCache();
```

---

## Common Issues & Solutions

### Issue 1: Backend Not Returning Correct Status
**Symptom:** Console shows `Cached: false` even after payment

**Solution:** Check backend API `/api/league/:leagueId/payment-status/:userId`
- Verify the API is checking payment correctly
- Ensure `isPaid` field is being set to `true` after payment
- Check if the payment record exists in database

**Backend Check:**
```javascript
// Backend should return:
{
  success: true,
  data: {
    isPaid: true,  // This should be true if payment exists
    paymentId: "...",
    amount: 200
  }
}
```

### Issue 2: Wrong League ID
**Symptom:** Payment status shows unpaid for specific games

**Solution:**
- Verify `match.leagueId` is correct in the game card
- Check if the payment was made for the same `leagueId`
- Console log: `🎮 [GAME CARD] League: <name>, LeagueId: <id>`

### Issue 3: Cache Not Updating After Payment
**Symptom:** Paid but still shows unpaid until app restart

**Solution:** After successful payment, refresh the cache:
```dart
// In AddPaymentDetailsProvider after payment success:
final paymentProvider = Provider.of<LeaguePaymentProvider>(context, listen: false);
await paymentProvider.refreshPaymentStatus(leagueId, userId);
```

### Issue 4: Multiple User IDs
**Symptom:** Payment status different for same user

**Solution:**
- Verify `userId` is consistent across the app
- Check `AuthProvider.userId` returns the same ID used during payment
- Console log: `🎮 [GAME CARD] Checking payment for league: <id>, user: <userId>`

---

## Testing Checklist

### Before Payment:
- [ ] Navigate to Games screen
- [ ] Find a game for a league you haven't paid
- [ ] Verify "Pay League Fee" button appears
- [ ] Console shows: `Cached: false, HasPaid: false`

### After Payment:
- [ ] Complete payment successfully
- [ ] Return to Games screen (or pull to refresh)
- [ ] Verify "Pay League Fee" button is GONE
- [ ] Console shows: `Cached: true, HasPaid: true`
- [ ] Console shows: `✅ [GAME CARD] Payment confirmed for <League>`

### For Multiple Leagues:
- [ ] Pay for League A
- [ ] League A games → No payment button ✅
- [ ] League B games → Payment button still shows ✅
- [ ] Pay for League B
- [ ] League B games → No payment button ✅

---

## Quick Fix Commands

### Clear All Payment Cache:
```dart
Provider.of<LeaguePaymentProvider>(context, listen: false).clearAllCache();
```

### Force Refresh Single League:
```dart
await Provider.of<LeaguePaymentProvider>(context, listen: false)
    .refreshPaymentStatus(leagueId, userId);
```

### Check Current Cache:
```dart
final status = Provider.of<LeaguePaymentProvider>(context, listen: false)
    .getCachedPaymentStatus(leagueId, userId);
print('Current status: $status'); // true = paid, false = unpaid, null = not loaded
```

---

## Backend Requirements

The backend API must:
1. ✅ Accept `userId` (not just `captainId`)
2. ✅ Check if payment exists for this user + league
3. ✅ Return `isPaid: true` if payment found
4. ✅ Return `isPaid: false` if no payment found
5. ✅ Work for both captains and players

**API Endpoint:**
```
GET /api/league/:leagueId/payment-status/:userId
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "isPaid": true,
    "paymentId": "payment_123",
    "amount": 200,
    "paidAt": "2025-12-30T09:00:00Z"
  }
}
```

---

## Contact Backend Team If:
- ❌ API returns `isPaid: false` even after payment
- ❌ API returns 403/404 errors
- ❌ Payment record not found in database
- ❌ `userId` not matching between frontend and backend
