# 🔍 Debug Notification Flow - Step by Step

## Current Issue
Stat keeper and referee are not receiving notifications or seeing assigned games despite backend logs showing successful creation.

## Enhanced Debugging Added

### 1. **Backend Debugging** (`controller/notification-handlers.ts`)
- ✅ Enhanced user ID logging
- ✅ Added GAME_ASSIGNED notification tracking
- ✅ Shows all notifications for user (any status)
- ✅ Detailed receiver ID comparison

### 2. **Flutter Notification Service** (`notification_service.dart`)
- ✅ Added GAME_ASSIGNED notification detection
- ✅ Enhanced role-based filtering logs
- ✅ Added receiver ID logging
- ✅ Added match ID parameter support

### 3. **Flutter Notification Provider** (`notification_provider.dart`)
- ✅ Added role-specific notification logging
- ✅ Shows notification count per role
- ✅ Lists notification types and messages

### 4. **Flutter Game Creation** (`upcoming_games_provider.dart`)
- ✅ Enhanced notification sending logs
- ✅ Added receiver ID, message, and match ID logging
- ✅ Added match ID to notification payload

## 🧪 **Testing Steps**

### Step 1: Check Backend Logs
When creating a game, look for:
```
🔔 [STATKEEPER NOTIFICATION] Notification created successfully
📊 Total GAME_ASSIGNED notifications in system: X
📊 GAME_ASSIGNED notifications details: [...]
```

### Step 2: Check Flutter Logs (Game Creation)
Look for:
```
🔔 [FLUTTER] Stat keeper notification details:
   - Receiver ID: 6946d924a285d6afb4a8c758
   - Message: You're the Stat Keeper for...
   - Match ID: 695060eb4749e7d5159102a9
   - Notification sent: true
```

### Step 3: Check Flutter Logs (Notification Retrieval)
When stat keeper opens notification screen, look for:
```
🎮 Found X GAME_ASSIGNED notifications:
🎯 Normalized user role: "statkeeper"
🎯 [NOTIFICATION PROVIDER] Stat keeper notifications: X
```

### Step 4: Check Flutter Logs (Dashboard)
When stat keeper opens dashboard, look for:
```
📋 Current user info:
   - User ID: 6946d924a285d6afb4a8c758
   - Role: statkeeper
✅ Found assigned match: Team A vs Team B
```

## 🎯 **Potential Issues to Check**

### Issue 1: User ID Mismatch
- **Check**: Backend notification receiver ID vs Flutter user ID
- **Solution**: Ensure both use same ID format (ObjectId vs String)

### Issue 2: Role Mismatch  
- **Check**: Flutter user role vs notification filtering
- **Solution**: Ensure role is stored as "statkeeper" not "stat-keeper"

### Issue 3: Notification Status
- **Check**: Notifications might be created as "accepted" instead of "pending"
- **Solution**: Ensure GAME_ASSIGNED notifications are created with "pending" status

### Issue 4: Match ID Missing
- **Check**: Notification might not be linked to match properly
- **Solution**: Ensure matchId is passed in notification payload

## 🔧 **Quick Fixes Applied**

1. **Enhanced Debugging**: Added comprehensive logging throughout the flow
2. **Match ID Support**: Added matchId parameter to notification service
3. **Role Filtering**: Ensured GAME_ASSIGNED is included for stat keepers and referees
4. **Message Formatting**: Improved notification messages with colors

## 🚀 **Next Steps**

1. **Create a game** with stat keeper assignment
2. **Check all logs** in the order above
3. **Identify the exact point** where the flow breaks
4. **Apply targeted fix** based on findings

The enhanced debugging will show us exactly where the issue is occurring! 🎯