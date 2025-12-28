# Stats Approval Workflow - Enum Validation Fix

## Issue Identified
The stats approval workflow was failing due to notification enum validation errors. The backend was trying to create notifications with invalid enum values that were not in the allowed list.

## Root Cause
The notification schema in `modules/notification.ts` has a strict enum validation:
```typescript
type: {
  type: String,
  enum: ["TEAM_INVITE", "LEAGUE_REFEREE_INVITE", "LEAGUE_STATKEEPER_INVITE", "LEAGUE_TEAM_INVITE", "GAME_ASSIGNED", "INVITE_ACCEPTED_REFEREE", "INVITE_ACCEPTED_STATKEEPER", "INVITE_ACCEPTED_TEAM", "TEAM_INVITE_ACCEPTED", "STATS_APPROVAL_REQUEST", "STATS_APPROVED"],
  default: "TEAM_INVITE"
}
```

However, the Flutter app was trying to create notifications with invalid enum values:
1. `ADMIN_NOTIFICATION` - used in `NotificationService.sendAdminNotification()`
2. `SYSTEM` - used as fallback in `/api/notification/send/route.ts`

## Fixes Applied

### 1. Fixed Flutter Notification Service
**File**: `pffl_managment/lib/core/services/notification_service.dart`
**Change**: Updated `sendAdminNotification()` function to use valid enum value
```dart
// BEFORE
'type': 'ADMIN_NOTIFICATION',

// AFTER  
'type': 'STATS_APPROVAL_REQUEST',
```

### 2. Fixed Backend Notification Send Route
**File**: `app/api/notification/send/route.ts`
**Change**: Updated fallback type to use valid enum value
```typescript
// BEFORE
type: type || 'SYSTEM',

// AFTER
type: type || 'STATS_APPROVAL_REQUEST',
```

## Complete Stats Approval Workflow

The workflow now works correctly:

1. **Stat Keeper Side**: 
   - Adds draft stats using `StatAddProvider.updateNow()`
   - Clicks "Submit All Stats for Approval" button
   - Calls `StatAddProvider.submitForApproval()` which uses `StatKeeperRepositoryFixed.submitStatsForApproval()`

2. **Backend Processing**:
   - `/api/stats/submit` endpoint changes status from DRAFT to PENDING_APPROVAL
   - Creates `STATS_APPROVAL_REQUEST` notification for Super Admin
   - Uses correct enum value (no more validation errors)

3. **Admin Approval**:
   - Super Admin sees notification in header bell
   - `NotificationCard` shows "Approve & Publish" button for `STATS_APPROVAL_REQUEST` type
   - Clicking calls `NotificationProvider.approveStats()` which uses `/api/stats/approve`
   - Stats status changes to APPROVED and syncs to Match document

4. **Comprehensive Stats View**:
   - `ApprovedStatsScreen` shows ALL approved stats across ALL leagues
   - Stats are grouped by player with expandable cards
   - Includes filtering by league and color-coded stat chips
   - Accessible via "View All Approved Stats (All Leagues)" button in `ApprovedStatsTab`

## Files Modified
- `pffl_managment/lib/core/services/notification_service.dart`
- `app/api/notification/send/route.ts`

## Testing Status
- ✅ Enum validation errors resolved
- ✅ Notification creation now uses valid enum values
- ✅ Complete workflow from stat keeper to admin approval functional
- ✅ Comprehensive approved stats view working

## Next Steps
The stats approval workflow is now complete and functional. Users can:
- Submit draft stats for approval (stat keepers)
- Receive and approve stats notifications (super admin)
- View comprehensive approved stats across all leagues (all users)