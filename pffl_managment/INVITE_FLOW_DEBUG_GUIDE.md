# Invite Flow Debug Guide

## 🎯 Overview
This guide helps verify and debug the invite flow from Captain to Free Agent notifications.

## 🔍 Debug Logging Added

### 1. CaptainInviteProvider (`lib/invite_screens/captain_invite_screen/providers/captain_invite_provider.dart`)
- ✅ Added comprehensive logging to `inviteUser()` method
- Logs user details, team ID, format, and API call parameters
- Tracks UI state changes and error handling

### 2. TeamService (`lib/core/services/team_service.dart`)
- ✅ Added detailed logging to `invitePlayer()` method
- Logs request data, endpoint URL, and response details
- Tracks API call success/failure with full error details

### 3. NotificationService (`lib/core/services/notification_service.dart`)
- ✅ Enhanced logging in `getAllNotifications()` method
- Logs each notification with ID, type, message, and status
- Specifically tracks team/invite notifications

### 4. NotificationProvider (`lib/core/providers/notification_provider.dart`)
- ✅ Added user info logging (ID, role)
- Logs all notifications with detailed breakdown
- Specifically highlights team/invite notifications

## 🧪 Testing Steps

### Step 1: Test Invite Trigger
1. **Open Captain Invite Screen**
2. **Select Free Agents tab**
3. **Tap Invite on a Free Agent**
4. **Check Console Logs:**
   ```
   🎯 [INVITE DEBUG] Starting invite process for user: [userId]
   🎯 [INVITE DEBUG] Team ID: [teamId]
   🎯 [INVITE DEBUG] Selected format: 5v5
   🎯 [INVITE DEBUG] Found user: [userName] ([email])
   🎯 [INVITE DEBUG] User role: free-agent
   ✅ [INVITE DEBUG] Updated UI state to invited
   ```

### Step 2: Verify API Call
**Expected Console Output:**
```
🎯 [TEAM SERVICE DEBUG] Starting invitePlayer API call
🎯 [TEAM SERVICE DEBUG] Parameters:
   - playerId: [userId]
   - teamId: [teamId]
   - format: 5v5
🎯 [TEAM SERVICE DEBUG] Full URL: https://api-staging.phoenixflagfootballleague.com/api/team/invite-player
🎯 [TEAM SERVICE DEBUG] Response received
🎯 [TEAM SERVICE DEBUG] Status code: 200
✅ [TEAM SERVICE DEBUG] Player invited successfully
```

### Step 3: Check Free Agent Notifications
1. **Switch to Free Agent account**
2. **Open Notifications Screen**
3. **Check Console Logs:**
   ```
   📡 [NOTIFICATION SERVICE DEBUG] Fetching all notifications...
   📡 [NOTIFICATION SERVICE DEBUG] Found [X] raw notifications
   🎯 [NOTIFICATION SERVICE DEBUG] Found [X] team/invite notifications
   ```

### Step 4: Verify Notification Content
**Expected Notification Types:**
- `TEAM_INVITE`
- `TEAM_INVITATION_AS_PLAYER`

**Expected Message:**
- "This captain has invited you" or similar

## 🔧 Debugging Checklist

### ✅ Invite Trigger Check
- [ ] Invite button tap triggers `inviteUser()` method
- [ ] Correct Free Agent userId is passed
- [ ] UI immediately shows "Invited" state (black color + outlined icon)
- [ ] No duplicate invites allowed

### ✅ API Call Verification
- [ ] `TeamService.invitePlayer()` is called with correct parameters
- [ ] API endpoint `/team/invite-player` returns 200/201 status
- [ ] No network errors or authentication issues

### ✅ Notification Creation
- [ ] Backend creates notification record for Free Agent
- [ ] Notification type is `TEAM_INVITE` or `TEAM_INVITATION_AS_PLAYER`
- [ ] Notification status is `pending`
- [ ] Notification contains captain/team reference

### ✅ Free Agent Notification Display
- [ ] Free Agent notification screen fetches notifications
- [ ] Invite notification appears in the list
- [ ] Notification shows correct title: "Team Invitation — As Player"
- [ ] Accept/Decline buttons are visible for pending invites

### ✅ Accept/Cancel Actions
- [ ] Accept button calls `acceptNotification()` API
- [ ] Accept changes Free Agent role to Player
- [ ] Cancel button calls `rejectNotification()` API
- [ ] Cancel keeps Free Agent role unchanged

## 🚨 Common Issues

### Issue 1: No Notification Received
**Possible Causes:**
- Backend not creating notification record
- Wrong user ID in invite request
- Notification filtering excluding invite types

**Debug Steps:**
1. Check API response from `/team/invite-player`
2. Verify notification creation in backend logs
3. Check notification filtering in `FreeAgentNotificationsScreen`

### Issue 2: Notification Not Displayed
**Possible Causes:**
- Notification type not in `freeAgentNotificationTypes` array
- Notification parsing error
- UI filtering issue

**Debug Steps:**
1. Check notification types in `FreeAgentNotificationsScreen`
2. Verify notification parsing in `NotificationModel.fromJson()`
3. Check console logs for parsing errors

### Issue 3: Accept/Cancel Not Working
**Possible Causes:**
- Wrong notification ID
- API endpoint issues
- Role update failure

**Debug Steps:**
1. Check notification ID in accept/reject calls
2. Verify API endpoints `/notification/accept/` and `/notification/reject/`
3. Check role update in backend

## 📋 Expected Notification Types

The Free Agent notification screen filters for these types:
```dart
final freeAgentNotificationTypes = [
  'TEAM_INVITE',
  'LEAGUE_INVITE', 
  'TEAM_INVITATION_AS_PLAYER',
  'LEAGUE_REGISTRATION_APPROVED',
  'LEAGUE_REGISTRATION_REJECTED',
  'PAYMENT_REMINDER',
  'PAYMENT_CONFIRMATION',
];
```

## 🎯 Success Criteria

### ✅ Complete Flow Success
1. **Captain sends invite** → UI shows "Invited" immediately
2. **API call succeeds** → Backend creates notification
3. **Free Agent opens notifications** → Invite appears in list
4. **Free Agent accepts** → Role changes to Player
5. **Free Agent cancels** → Role remains Free Agent

### 📱 UI Behavior
- **Before invite:** Blue Gmail icon + "Invite" text
- **After invite:** Black outlined Gmail icon + "Invited" text (black)
- **No loading indicators** at any point
- **Immediate visual feedback** on tap

## 🔄 Testing Commands

Run the app and use these console commands to monitor:

```bash
# Filter for invite-related logs
flutter logs | grep -E "(INVITE DEBUG|TEAM SERVICE DEBUG|NOTIFICATION.*DEBUG)"

# Monitor notification fetching
flutter logs | grep -E "NOTIFICATION.*DEBUG"

# Track API calls
flutter logs | grep -E "(TeamService|NotificationService)"
```

## 📞 Support

If issues persist after following this guide:
1. Check all console logs match expected patterns
2. Verify backend API responses
3. Test with different Free Agent accounts
4. Ensure notification permissions are enabled