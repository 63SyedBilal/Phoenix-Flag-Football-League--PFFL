# Role-Based Visibility Test Guide

## 🎯 Overview
This guide helps verify that the 3-dot icon in My Team screen is only visible to Captains.

## ✅ Changes Made

### TeamInfoSection Widget (`lib/features/captain/view/teams/widgets/team_info_section.dart`)
- ✅ Added `Consumer<AuthProvider>` wrapper
- ✅ Added role check: `authProvider.userRole.toLowerCase() == 'captain'`
- ✅ Wrapped 3-dot IconButton with conditional `if (isCaptain)`
- ✅ No layout, styling, or padding changes
- ✅ Uses Provider-only state management

## 🧪 Testing Steps

### Test 1: Captain Role
1. **Login as Captain**
2. **Navigate to My Team screen**
3. **Expected Result:** 3-dot icon is visible
4. **Tap 3-dot icon:** Popup menu should appear with options

### Test 2: Player Role  
1. **Login as Player**
2. **Navigate to My Team screen**
3. **Expected Result:** 3-dot icon is NOT visible
4. **UI Layout:** Should remain unchanged, just missing the icon

### Test 3: Free Agent Role
1. **Login as Free Agent**
2. **Navigate to My Team screen** (if accessible)
3. **Expected Result:** 3-dot icon is NOT visible

### Test 4: Role Change (Dynamic)
1. **Start as Player** (no 3-dot icon)
2. **Accept Captain invitation** (role changes to Captain)
3. **Return to My Team screen**
4. **Expected Result:** 3-dot icon now appears (Provider reactivity)

## 🔍 Code Logic

### Role Check Implementation
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // Check if current user is a captain
    final isCaptain = authProvider.userRole.toLowerCase() == 'captain';
    
    // ... UI code ...
    
    // Only show 3-dot icon for captains
    if (isCaptain)
      IconButton(
        // ... 3-dot icon code ...
      ),
  },
)
```

### Key Features
- ✅ **Case-insensitive role check** - `toLowerCase()` handles "Captain", "CAPTAIN", "captain"
- ✅ **Provider-driven** - Automatically updates when role changes
- ✅ **No hardcoded values** - Uses `authProvider.userRole` from state
- ✅ **Clean conditional rendering** - Simple `if (isCaptain)` wrapper

## 📱 UI Behavior

### Captain View
```
[Team Logo] Team Name                    [5/10] [⋮]
```

### Player/Free Agent View  
```
[Team Logo] Team Name                    [5/10]
```

### Layout Consistency
- ✅ **No layout shifts** - Icon space is simply not rendered
- ✅ **No padding changes** - Existing spacing maintained
- ✅ **No style changes** - Colors, fonts, sizes unchanged

## 🚨 Common Issues

### Issue 1: Icon Still Visible for Non-Captains
**Possible Causes:**
- Role not properly set in AuthProvider
- Case sensitivity in role comparison
- Provider not properly consumed

**Debug Steps:**
1. Check `authProvider.userRole` value in console
2. Verify role is set correctly during login
3. Ensure Consumer<AuthProvider> is properly wrapped

### Issue 2: Icon Not Appearing for Captains
**Possible Causes:**
- Role string mismatch (e.g., "team_captain" vs "captain")
- AuthProvider not updated after role change
- Provider context not available

**Debug Steps:**
1. Log the exact role value: `print('User role: ${authProvider.userRole}')`
2. Check if role comparison is working: `print('Is captain: $isCaptain')`
3. Verify AuthProvider is provided in widget tree

### Issue 3: UI Layout Issues
**Possible Causes:**
- Conditional rendering affecting layout
- Missing Container or spacing

**Debug Steps:**
1. Check if Row layout is maintained
2. Verify no extra spacing or containers added
3. Test with different screen sizes

## 🎯 Success Criteria

### ✅ Role-Based Visibility
- **Captain:** 3-dot icon visible and functional
- **Player:** 3-dot icon hidden
- **Free Agent:** 3-dot icon hidden
- **Other roles:** 3-dot icon hidden

### ✅ UI Consistency
- **Layout:** No shifts or changes when icon is hidden
- **Spacing:** Consistent padding and margins
- **Styling:** No color, font, or size changes

### ✅ Provider Reactivity
- **Role changes:** UI updates automatically when role changes
- **No setState:** Pure Provider-driven state management
- **Performance:** No unnecessary rebuilds

## 🔄 Testing Commands

Add debug logging to verify role checks:

```dart
// Add this in TeamInfoSection build method
print('🔍 [ROLE DEBUG] User role: ${authProvider.userRole}');
print('🔍 [ROLE DEBUG] Is captain: $isCaptain');
```

Monitor logs:
```bash
flutter logs | grep "ROLE DEBUG"
```

## 📞 Support

If issues persist:
1. Verify AuthProvider contains correct role
2. Check role string format and casing
3. Ensure Provider is properly consumed
4. Test role changes and UI reactivity