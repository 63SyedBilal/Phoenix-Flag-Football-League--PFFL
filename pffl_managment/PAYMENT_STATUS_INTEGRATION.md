# Payment Status Integration - Summary of Changes

## Date: 2025-12-30

### Overview
Extended the payment status checking feature to work for both **Captains** and **Players** across the application. Fixed the "You are not a captain of any team" error by making providers role-aware.

---

## Key Changes

### 1. RoleBasedGameCard - Dynamic Payment Status Checking
**File:** `lib/screens/games/widgets/role_based_game_card.dart`

**Changes:**
- Added imports for `AuthProvider`, `LeaguePaymentProvider`, and `AppRoutes`
- Completely rewrote `_buildActionSection()` to dynamically check payment status
- Now uses `Consumer<LeaguePaymentProvider>` to check if league fee is paid
- Automatically triggers payment status check if not in cache
- Shows "Pay League Fee" button only if fee is unpaid
- Works for both captains and players
- If fee is paid and user has edit permission, shows "Edit Game" option
- Navigates to `AppRoutes.freeAgentPaymentHistory` when "Pay League Fee" is clicked

**Logic Flow:**
1. Check if user is captain or player
2. If yes, check payment status from `LeaguePaymentProvider`
3. If status not in cache, trigger API call
4. If unpaid → Show payment prompt
5. If paid and can edit → Show edit option
6. Otherwise → Show nothing

---

### 2. CaptainPaymentHistoryProvider - Role-Aware Loading
**File:** `lib/features/payment_history/providers/captain_payment_history_provider.dart`

**Changes:**
- Added `userRole` field to the provider
- Added constructor to accept `userRole` parameter
- Updated `loadPaymentHistory()` to check user role before loading
- If user is NOT a captain → Load personal payments via `PaymentService.fetchUserPayments()`
- If user IS a captain → Load team payments via `PaymentService.fetchTeamPayments()`
- Added debug logging to track which path is taken

**Why This Fixes the Error:**
The backend API `/api/payments/team` requires the user to be a captain. Previously, any user accessing the captain payment history screen would trigger this API call, causing a 403 error for non-captains. Now, the provider intelligently loads the appropriate data based on the user's role.

---

### 3. AppProviders - Inject User Role
**File:** `lib/core/providers/app_providers.dart`

**Changes:**
- Changed `CaptainPaymentHistoryProvider` from `ChangeNotifierProvider` to `ChangeNotifierProxyProvider<AuthProvider, CaptainPaymentHistoryProvider>`
- Now injects `userRole` from `AuthProvider` into the provider
- Provider is recreated only if user role changes

---

### 4. GamesScreen - Already Updated (Previous Session)
**File:** `lib/screens/games/common/games_screen.dart`

**Status:** Already updated in previous session
- Uses `Consumer2<GamesProvider, LeaguePaymentProvider>`
- Checks payment status per match for both captains and players
- Triggers payment status check if not cached

---

### 5. SharedGameCard - Already Updated (Previous Session)
**File:** `lib/core/widgets/upcomingmatches/shared_game_card.dart`

**Status:** Already updated in previous session
- Includes payment prompt logic
- Uses `LeaguePaymentProvider` to check status
- Shows "Pay League Fee" button if unpaid

---

## Testing Checklist

### For Captains:
- [ ] Login as captain
- [ ] Navigate to Games screen
- [ ] Verify payment status is checked for each game
- [ ] If unpaid, verify "Pay League Fee" button appears
- [ ] Click "Pay League Fee" → Should navigate to payment history
- [ ] If paid, verify "Edit Game" option appears (if captain has edit permission)
- [ ] Navigate to Captain Payment History
- [ ] Verify team payments load without errors

### For Players:
- [ ] Login as player
- [ ] Navigate to Games screen
- [ ] Verify payment status is checked for each game
- [ ] If unpaid, verify "Pay League Fee" button appears
- [ ] Click "Pay League Fee" → Should navigate to payment history
- [ ] If paid, verify no action buttons appear (players can't edit)
- [ ] Navigate to Player Payment History (if accessible)
- [ ] Verify personal payments load without errors

### For Other Roles (Admin, Referee, etc.):
- [ ] Login as admin/referee/statkeeper
- [ ] Navigate to Games screen
- [ ] Verify appropriate actions appear (e.g., Edit for admin)
- [ ] Verify no payment prompts appear for these roles

---

## API Endpoints Used

1. **Check Payment Status:**
   - `GET /api/league/:leagueId/payment-status/:userId`
   - Used by: `LeagueService.checkLeaguePaymentStatus()`
   - Called by: `LeaguePaymentProvider`

2. **Fetch Team Payments (Captains Only):**
   - `GET /api/payments/team`
   - Used by: `PaymentService.fetchTeamPayments()`
   - Called by: `CaptainPaymentHistoryProvider` (only if user is captain)

3. **Fetch User Payments:**
   - `GET /api/payments/my`
   - Used by: `PaymentService.fetchUserPayments()`
   - Called by: `CaptainPaymentHistoryProvider` (if user is not captain)

---

## Error Resolution

### Error: "You are not a captain of any team"
**Root Cause:** 
- `CaptainPaymentHistoryProvider` was calling `PaymentService.fetchTeamPayments()` regardless of user role
- Backend API `/api/payments/team` returns 403 error if user is not a captain

**Solution:**
- Made `CaptainPaymentHistoryProvider` role-aware
- Check user role before deciding which API to call
- Non-captains now load personal payments instead of team payments

---

## Benefits

1. **Unified Experience:** Both captains and players see payment prompts consistently
2. **League-Level Checking:** Payment status is checked at league level, not per game
3. **Real-Time Updates:** UI updates immediately when payment status changes
4. **Error Prevention:** Role-aware providers prevent 403 errors
5. **Reusable Components:** `RoleBasedGameCard` can be used anywhere in the app
6. **Performance:** Payment status is cached to reduce API calls

---

## Notes

- Payment status is cached in `LeaguePaymentProvider` using `leagueId-userId` as the cache key
- Cache is automatically cleared when user logs out or changes role
- Payment status check is triggered automatically when a game card is rendered
- The "Pay League Fee" button navigates to `AppRoutes.freeAgentPaymentHistory` for all roles
