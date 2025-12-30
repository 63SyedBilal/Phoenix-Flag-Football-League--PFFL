# Payment Database Check Script

## Problem
Backend is returning `isPaid: false` even though user claims to have paid.

## What Backend is Looking For:
```javascript
const payment = await Payment.findOne({
  leagueId: "6949829604d5b5dfdc05e1c2",
  userId: "6946d912a285d6afb4a8c720",
  status: "completed"
});
```

## Possible Issues:

### 1. Payment Status Field
**Check:** Payment record ka `status` field kya hai?
- Backend expects: `"completed"`
- Possible values: `"pending"`, `"paid"`, `"success"`, `"completed"`

**Solution:** Check payment collection and see actual status value

### 2. User ID Mismatch
**Check:** Payment record mein `userId` field hai ya kuch aur?
- Backend expects: `userId: "6946d912a285d6afb4a8c720"`
- Possible fields: `userId`, `playerId`, `captainId`, `user`, `paidBy`

**Solution:** Check payment schema

### 3. League ID Mismatch
**Check:** Payment record mein `leagueId` sahi hai?
- Backend expects: `leagueId: "6949829604d5b5dfdc05e1c2"`
- Possible: Different ID format or field name

### 4. Payment Not Saved
**Check:** Payment actually database mein save hui thi?
- Check payment collection for this user
- Check transaction logs

---

## Debug Steps:

### Step 1: Check Payment Collection
Run this in MongoDB:
```javascript
db.payments.find({
  userId: ObjectId("6946d912a285d6afb4a8c720")
}).pretty()
```

### Step 2: Check All Payments for This League
```javascript
db.payments.find({
  leagueId: ObjectId("6949829604d5b5dfdc05e1c2")
}).pretty()
```

### Step 3: Check Payment Schema
Look at one payment record to see field names:
```javascript
db.payments.findOne()
```

### Step 4: Check Status Values
```javascript
db.payments.distinct("status")
```

---

## Quick Backend Debug

Add this to `checkLeaguePaymentStatus` function (temporarily):

```typescript
// After line 1189 (before payment query)
console.log('🔍 [DEBUG] Searching for payment with:', {
  leagueId: leagueObjectId.toString(),
  userId: userObjectId.toString(),
  status: 'completed'
});

// Check if ANY payment exists for this user+league (any status)
const anyPayment = await Payment.findOne({
  leagueId: leagueObjectId,
  userId: userObjectId
});

console.log('🔍 [DEBUG] Any payment found (any status):', anyPayment ? {
  _id: anyPayment._id.toString(),
  status: anyPayment.status,
  amount: anyPayment.amount,
  createdAt: anyPayment.createdAt
} : 'NO PAYMENT FOUND');

// Check with different status values
const paidPayment = await Payment.findOne({
  leagueId: leagueObjectId,
  userId: userObjectId,
  status: "paid"
});

console.log('🔍 [DEBUG] Payment with status="paid":', paidPayment ? 'FOUND' : 'NOT FOUND');

const successPayment = await Payment.findOne({
  leagueId: leagueObjectId,
  userId: userObjectId,
  status: "success"
});

console.log('🔍 [DEBUG] Payment with status="success":', successPayment ? 'FOUND' : 'NOT FOUND');
```

---

## Expected Output:

If payment exists but status is different:
```
🔍 [DEBUG] Any payment found: { _id: '...', status: 'paid', amount: 200 }
🔍 [DEBUG] Payment with status="paid": FOUND
✅ [PAYMENT CHECK] Payment status: { isPaid: false }  ← Wrong!
```

If payment doesn't exist at all:
```
🔍 [DEBUG] Any payment found: NO PAYMENT FOUND
✅ [PAYMENT CHECK] Payment status: { isPaid: false }
```

---

## Solutions Based on Findings:

### If Status is "paid" instead of "completed":
```typescript
// Change line 1193 from:
status: "completed"

// To:
status: { $in: ["completed", "paid", "success"] }
```

### If userId field is different:
Check payment schema and update query accordingly

### If payment doesn't exist:
Check payment creation code - payment might not be saving correctly
