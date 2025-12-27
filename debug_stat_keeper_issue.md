# Debug Stat Keeper Notification Issue

## Problem
Stat keeper is not receiving notifications or seeing assigned games despite:
- ✅ Notifications being created successfully in backend
- ✅ Correct notification type (`GAME_ASSIGNED`)
- ✅ Correct receiver ID (`6946d924a285d6afb4a8c758`)
- ✅ Match created with correct stat keeper ID

## Backend Logs Analysis
```
🔔 [STATKEEPER NOTIFICATION] Notification data: {
  sender: '693c88f725239d27ad1f4505',
  receiver: '6946d924a285d6afb4a8c758',
  league: '6949829604d5b5dfdc05e1c2',
  match: '695060eb4749e7d5159102a9',
  type: 'GAME_ASSIGNED',
  status: 'pending'
}
✅ [STATKEEPER NOTIFICATION] Notification created successfully
```

## Fixes Applied

### 1. Fixed Notification Type ✅
- Changed `GAME_ASSIGNMENT_STATKEEPER` to `GAME_ASSIGNED` in Flutter
- Backend validation now passes

### 2. Fixed Notification Filtering ✅
- Updated `filterNotificationsByRole` to include `GAME_ASSIGNED` for stat keepers
- Added debugging logs to track filtering process

### 3. Enhanced Dashboard Debugging ✅
- Added detailed logging in `StatKeeperDashboardProvider`
- Shows user ID comparison and match assignment logic

## Next Steps to Debug

### Test the Notification Flow:
1. **Login as stat keeper** (`6946d924a285d6afb4a8c758`)
2. **Check notification screen** - Should show `GAME_ASSIGNED` notification
3. **Check dashboard** - Should show assigned game in "Assigned Games For You"

### Check Flutter Logs:
Look for these debug messages:
```
🎮 Found X GAME_ASSIGNED notifications:
🎮 GAME_ASSIGNED notification filtering:
📋 Current user info:
✅ Found assigned match: [match details]
```

### Potential Issues to Investigate:
1. **User ID mismatch** - Flutter vs Backend user ID format
2. **Role mismatch** - User role not being detected as 'stat-keeper'
3. **Notification retrieval** - Backend filtering out notifications
4. **Dashboard refresh** - Provider not refreshing after game creation

## Testing Commands

### Backend Test:
```bash
# Check if notification exists in database
curl -H "Authorization: Bearer <token>" \
  http://localhost:3000/api/notification/all
```

### Flutter Test:
1. Open stat keeper dashboard
2. Check console logs for debugging messages
3. Pull to refresh on notification screen
4. Check "Assigned Games For You" section

## Expected Behavior After Fixes:
- ✅ Stat keeper receives `GAME_ASSIGNED` notification
- ✅ Notification appears in notification screen
- ✅ Game appears in "Assigned Games For You" section
- ✅ No validation errors in backend logs