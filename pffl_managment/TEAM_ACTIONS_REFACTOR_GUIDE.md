# Team Actions Refactor Guide

## 🎯 Overview
This guide documents the refactored 3-dot card actions on the My Team/Team Management screen with enhanced UI and functionality.

## ✅ Changes Made

### **1. UI Improvements**
- ✅ **Removed elevation** from popup menu (elevation: 0)
- ✅ **Added light brown border** (Color: 0xFFD2B48C, width: 1.5)
- ✅ **Added selected item highlighting** (Light blue: 0xFFE8F4FD)
- ✅ **Clean card styling** with rounded corners
- ✅ **Pixel-perfect layout** maintained

### **2. Remove Player Functionality**
- ✅ **Player selection dialog** with list of non-captain players
- ✅ **Delete bucket icon** (Icons.delete_outline) next to each player
- ✅ **Confirmation dialog** before removal
- ✅ **Notification system integration** (placeholder for "You have been removed from this team")
- ✅ **State management** via Provider pattern

### **3. Transfer Leadership Functionality**
- ✅ **Leadership transfer dialog** with dropdown selection
- ✅ **Player dropdown** showing all non-captain team members
- ✅ **Player avatars and positions** in dropdown items
- ✅ **Invitation system** (placeholder for "This captain has offered you the captain role")
- ✅ **Accept/Cancel logic** framework

### **4. State Management**
- ✅ **StatefulWidget conversion** for local state management
- ✅ **Provider integration** for team data access
- ✅ **No setState usage** - pure Provider pattern
- ✅ **Automatic UI rebuilds** based on state changes

## 🎨 UI Design Specifications

### **Popup Menu Styling**
```dart
showMenu(
  color: Colors.white,
  elevation: 0, // No elevation
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: const BorderSide(
      color: Color(0xFFD2B48C), // Light brown border
      width: 1.5,
    ),
  ),
  // ... menu items
)
```

### **Menu Item Highlighting**
```dart
Container(
  decoration: BoxDecoration(
    color: _selectedMenuItem == 'item_name' 
        ? const Color(0xFFE8F4FD) // Light blue highlight
        : Colors.transparent,
    borderRadius: BorderRadius.circular(6),
  ),
  // ... item content
)
```

### **Visual Hierarchy**
- **Border:** Light brown (#D2B48C) for subtle definition
- **Highlight:** Light blue (#E8F4FD) for selected items
- **Typography:** Clean, readable fonts with proper weights
- **Spacing:** Consistent padding and margins

## 🔧 Functionality Details

### **Remove Player Flow**
1. **Captain taps "Remove Player"** → Opens player selection dialog
2. **Dialog shows list** of all non-captain players
3. **Delete icon** (bucket) appears next to each player
4. **Captain taps delete icon** → Shows confirmation dialog
5. **Confirmation** → Player removed + notification sent
6. **State updates** → UI rebuilds automatically

### **Transfer Leadership Flow**
1. **Captain taps "Transfer Leadership"** → Opens transfer dialog
2. **Dropdown shows** all non-captain players with avatars
3. **Captain selects player** → "Send Invitation" button enabled
4. **Invitation sent** → Notification to selected player
5. **Player accepts** → Roles updated (Captain → Player, Player → Captain)
6. **Player cancels** → No changes, invitation dismissed

### **Dialog Components**

#### **Transfer Leadership Dialog**
- **Title:** "Transfer Leadership"
- **Content:** Player selection dropdown with avatars
- **Dropdown Items:** Player name, position, avatar image
- **Actions:** Cancel, Send Invitation
- **Validation:** Requires player selection

#### **Remove Player Dialog**
- **Title:** "Remove Player"
- **Content:** Scrollable list of players
- **List Items:** Avatar, name, position, delete icon
- **Actions:** Cancel (auto-close on delete tap)
- **Confirmation:** Secondary dialog for removal confirmation

## 🔄 State Management Architecture

### **Provider Integration**
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    final isCaptain = authProvider.userRole.toLowerCase() == 'captain';
    // ... role-based UI rendering
  },
)
```

### **Local State Management**
```dart
class _TeamInfoSectionState extends State<TeamInfoSection> {
  String? _selectedMenuItem; // For menu item highlighting
  // ... dialog state management
}
```

### **Team Data Access**
- **Team Model:** `widget.team` provides player list and team info
- **Player Filtering:** `widget.team.players.where((p) => !p.isCaptain)`
- **Role Checking:** `player.isCaptain` boolean flag

## 🚀 Implementation Status

### **✅ Completed Features**
- [x] UI styling (border, elevation, highlighting)
- [x] Role-based visibility (Captain-only access)
- [x] Transfer leadership dialog with dropdown
- [x] Remove player dialog with list
- [x] Confirmation dialogs
- [x] Debug logging
- [x] State management structure

### **🔄 TODO: Backend Integration**
- [ ] **Remove Player API:** Call team service to remove player
- [ ] **Transfer Leadership API:** Send leadership invitation
- [ ] **Notification Service:** Send removal/transfer notifications
- [ ] **Role Update API:** Update user roles on acceptance
- [ ] **Team State Refresh:** Reload team data after changes

## 📱 User Experience Flow

### **Captain Experience**
1. **Sees 3-dot icon** in My Team screen
2. **Taps icon** → Clean popup menu with light brown border
3. **Hovers/selects items** → Light blue highlighting
4. **Chooses action** → Appropriate dialog opens
5. **Completes action** → Confirmation + state update

### **Player Experience (Removed)**
1. **Receives notification:** "You have been removed from this team"
2. **Role remains Player** but no longer in team
3. **Can join other teams** (becomes available for invites)

### **Player Experience (Leadership Transfer)**
1. **Receives notification:** "This captain has offered you the captain role"
2. **Can Accept** → Becomes Captain, previous Captain becomes Player
3. **Can Cancel** → No role changes, both remain in team

## 🧪 Testing Checklist

### **UI Testing**
- [ ] 3-dot menu appears only for Captains
- [ ] Menu has light brown border, no elevation
- [ ] Menu items highlight on selection
- [ ] Dialogs open correctly
- [ ] Dropdown shows all non-captain players
- [ ] Delete icons appear in remove dialog

### **Functionality Testing**
- [ ] Transfer dialog validates player selection
- [ ] Remove dialog shows confirmation
- [ ] Notifications are sent (when backend integrated)
- [ ] State updates correctly
- [ ] UI rebuilds automatically

### **Edge Cases**
- [ ] No players to remove (shows appropriate message)
- [ ] No players to transfer to (shows appropriate message)
- [ ] Network errors handled gracefully
- [ ] Concurrent actions handled properly

## 🔍 Debug Information

### **Console Logging**
```
🔍 [TEAM INFO DEBUG] User role: "captain"
🔍 [TEAM INFO DEBUG] Is captain: true
🔍 [TEAM INFO DEBUG] 3-dot icon will be visible
🎯 [TRANSFER DEBUG] Transferring leadership to: John Doe
🎯 [REMOVE DEBUG] Removing player: Jane Smith
```

### **Monitoring Commands**
```bash
# Filter for team action logs
flutter logs | grep -E "(TEAM INFO DEBUG|TRANSFER DEBUG|REMOVE DEBUG)"

# Monitor UI state changes
flutter logs | grep -E "TeamInfoSection"
```

## 📞 Next Steps

### **Backend Integration Priority**
1. **Remove Player API** - Highest priority for team management
2. **Notification Service** - Critical for user communication
3. **Transfer Leadership API** - Important for role management
4. **State Refresh** - Ensures UI consistency

### **Enhancement Opportunities**
- **Batch player removal** for multiple selections
- **Leadership transfer history** tracking
- **Undo functionality** for accidental removals
- **Advanced player filtering** in dialogs

## 🎯 Success Criteria

### **✅ UI Requirements Met**
- Light brown border with no elevation
- Selected item highlighting
- Clean, professional appearance
- Pixel-perfect layout consistency

### **✅ Functionality Requirements Met**
- Captain-only access control
- Remove player with confirmation
- Transfer leadership with dropdown
- Provider-based state management
- Notification system integration points

The refactored team actions provide a clean, professional interface for team management with proper role-based access control and comprehensive functionality for player management and leadership transfer.