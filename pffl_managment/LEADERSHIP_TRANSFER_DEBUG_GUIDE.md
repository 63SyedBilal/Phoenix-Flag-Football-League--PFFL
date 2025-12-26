# Leadership Transfer Notification Debug Guide

## Issues Fixed

### 1. Complete Profile Module Fixes
- **Dropdown Error**: Removed explicit `itemHeight: 48` from position dropdown to fix Flutter assertion error
- **Wrong Endpoint**: Changed from `AppConfig.completeProfileEndpoint` to `AppConfig.profileEndpoint` in all profile providers
- **Response Handling**: Enhanced backend sync to handle both `response.data['data']` and `response.data['user']` formats
- **Files Fixed**:
  - `lib/features/profile_screens/complet_profile_screen/complete_captain_profile_screen.dart`
  - `lib/features/profile_screens/complet_profile_screen/providers/complete_captain_profile_provider.dart`
  - `lib/features/referee/providers/complete_referee_profile_provider.dart`
  - `lib/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart`

### 2. Leadership Transfer Notification Debugging
- **Enhanced Logging**: Added comprehensive debug logging throughout the notification flow
- **Request Tracking**: Added detailed request/response logging in NotificationService
- **Error Details**: Enhanced error messages to help identify where the issue occurs

## Testing the Leadership Transfer Flow

### Prerequisites
1. Two user accounts: Captain and Player
2. Both users should be on the same team
3. Captain should be logged in on one device/session
4. Player should be logged in on another device/session

### Step-by-Step Testing

#### 1. Captain Side - Send Leadership Invitation
1. Captain opens Team Management screen
2. Captain taps 3-dot menu on a non-captain player
3. Captain selects "Transfer Leadership"
4. Captain selects the player from dropdown
5. Captain taps "Send Invitation"
6. **Expected**: Green snackbar shows "Leadership transfer invitation sent to [Player Name]"

#### 2. Check Debug Logs (Captain Side)
Look for these log entries in the captain's console:
```
🎯 [TRANSFER LEADERSHIP DEBUG] Starting transfer process to player: [playerId]
📧 [NOTIFICATION DEBUG] Sending leadership invitation to player: [playerId]
📧 [NOTIFICATION DEBUG] Sender ID (Captain): [captainId]
📧 [NOTIFICATION DEBUG] Receiver ID (Player): [playerId]
📧 [NOTIFICATION DEBUG] Team ID: [teamId]
📡 [NOTIFICATION SERVICE] Sending LEADERSHIP_INVITATION notification to: [playerId]
📡 [NOTIFICATION SERVICE] Request data: {receiverId: [playerId], type: LEADERSHIP_INVITATION, message: This captain has offered you the captain role, senderId: [captainId], teamId: [teamId]}
📡 [NOTIFICATION SERVICE] Response status: 200
✅ [NOTIFICATION SERVICE] LEADERSHIP_INVITATION notification sent successfully
✅ [NOTIFICATION DEBUG] Leadership invitation sent successfully
```

#### 3. Player Side - Check for Notification
1. Player opens their notifications screen
2. **Expected**: New notification appears with:
   - Type: "LEADERSHIP_INVITATION"
   - Message: "This captain has offered you the captain role"
   - Sender: Captain's name/ID
   - Accept/Decline buttons

#### 4. Check Debug Logs (Player Side)
Look for these log entries when player fetches notifications:
```
📡 [NOTIFICATION SERVICE DEBUG] Found [X] raw notifications
📡 [NOTIFICATION SERVICE DEBUG] Notification [N]:
   - ID: [notificationId]
   - Type: LEADERSHIP_INVITATION
   - Message: This captain has offered you the captain role
   - Status: pending
```

## Troubleshooting

### If Captain Gets Success But Player Doesn't Receive Notification

#### Check 1: Backend API Response
- Look for `📡 [NOTIFICATION SERVICE] Response status: 200` in captain's logs
- If not 200, check backend `/notification/send` endpoint
- Verify backend is creating notification record in database

#### Check 2: Notification Payload
- Verify all required fields are included:
  - `receiverId`: Player's user ID
  - `senderId`: Captain's user ID  
  - `type`: "LEADERSHIP_INVITATION"
  - `message`: "This captain has offered you the captain role"
  - `teamId`: Team ID (optional but recommended)

#### Check 3: Player Notification Fetching
- Verify player's `NotificationService.getAllNotifications()` is working
- Check if player's user ID matches the `receiverId` in notification
- Verify notification status is "pending" (not already processed)

#### Check 4: Backend Database
- Check if notification record was created in database
- Verify notification has correct `receiverId` matching player's user ID
- Check notification `status` field (should be "pending")

### Common Issues

1. **Wrong User ID**: Captain or player user ID not found in SharedPreferences
2. **Backend Error**: `/notification/send` endpoint returning non-200 status
3. **Database Issue**: Notification created but not visible due to query filters
4. **Caching Issue**: Player's notification list not refreshing
5. **Role Mismatch**: Player's role changed, affecting notification visibility

## Next Steps for Testing

1. **Test with Real Users**: Use two actual devices/accounts
2. **Check Backend Logs**: Monitor backend `/notification/send` endpoint
3. **Database Verification**: Check notification records in database
4. **Network Monitoring**: Use network inspector to verify API calls
5. **Real-time Updates**: Test if notifications appear without app refresh

## Files Modified

- `lib/features/captain/providers/captain_team_provider.dart` - Enhanced debugging
- `lib/core/services/notification_service.dart` - Enhanced debugging  
- `lib/features/profile_screens/complet_profile_screen/complete_captain_profile_screen.dart` - Fixed dropdown
- `lib/features/profile_screens/complet_profile_screen/providers/complete_captain_profile_provider.dart` - Fixed endpoint
- `lib/features/referee/providers/complete_referee_profile_provider.dart` - Fixed endpoint
- `lib/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart` - Fixed endpoint

All files compile without errors and are ready for testing.