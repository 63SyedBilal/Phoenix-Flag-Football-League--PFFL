# Design Document: Free Agent Settings

## Overview

The Free Agent Settings feature provides a role-specific settings interface for free agents in the PFFL Management Flutter application. This feature implements a streamlined settings menu with four core sections: Player Information, Change Password, Notifications, and Payment History. The design follows the existing role-based settings architecture while providing free agents with the essential functionality they need to manage their accounts.

## Architecture

The Free Agent Settings feature integrates with the existing `RoleBasedSettingsProvider` architecture and follows the established patterns used by other role-based settings implementations.

### Component Hierarchy

```
RoleBasedSettingsProvider
├── getFreeAgentSettings() → List<SettingsSectionModel>
├── Player Information Screen (reused from existing)
├── Change Password Screen (reused from existing)  
├── Notifications Screen (reused from existing)
└── Payment History Screen (reused from existing)
```

### Integration Points

- **Settings Provider**: Extends `RoleBasedSettingsProvider` with `getFreeAgentSettings()` method
- **Role Normalization**: Handles "freeagent", "free agent", and "free_agent" variations
- **Screen Reuse**: Leverages existing settings screens where appropriate
- **Navigation**: Uses standard `MaterialPageRoute` navigation pattern

## Components and Interfaces

### Core Components

#### 1. Free Agent Settings Configuration Function

```dart
List<SettingsSectionModel> getFreeAgentSettings() {
  return [
    SettingsSectionModel(
      title: 'Player information',
      screen: const PlayerInformationScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password', 
      screen: const ChangePassowrd(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const NotificationsScreen(),
    ),
    SettingsSectionModel(
      title: 'Payment history',
      screen: PaymentHistory(),
    ),
  ];
}
```

#### 2. Settings Provider Integration

The existing `RoleBasedSettingsProvider` will be extended to handle the "freeagent" case:

```dart
switch (normalizedRole) {
  case 'admin':
    return getAdminSettings();
  case 'captain':
    return getCaptainSettings();
  case 'player':
    return getPlayerSettings();
  case 'freeagent':  // New case
    return getFreeAgentSettings();
  case 'referee':
    return getRefereeSettings();
  case 'statkeeper':
    return getStatKeeperSettings();
  default:
    return getPlayerSettings();
}
```

### Screen Components

All screens are reused from existing implementations:

1. **PlayerInformationScreen**: Displays and allows editing of personal profile data
2. **ChangePassowrd**: Handles password change functionality with validation
3. **NotificationsScreen**: Manages notification preferences and settings
4. **PaymentHistory**: Shows transaction history and payment details

## Data Models

### SettingsSectionModel

The existing `SettingsSectionModel` is used without modification:

```dart
class SettingsSectionModel {
  final String title;
  final Widget screen;
  
  SettingsSectionModel({required this.title, required this.screen});
}
```

### Role Handling

Free agent role variations are normalized using the existing logic:
- Input: "Free Agent", "free_agent", "freeagent"
- Normalized: "freeagent"
- Processed by: `userRole.toLowerCase().replaceAll(' ', '').replaceAll('_', '').trim()`

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Free Agent Settings Menu Completeness
*For any* free agent user role (including variations like "free agent", "free_agent", "freeagent"), the settings menu should contain exactly four sections with the titles: "Player information", "Change Password", "Notifications", and "Payment history".
**Validates: Requirements 1.2**

### Property 2: Role Normalization Consistency  
*For any* string variation of the free agent role ("Free Agent", "free_agent", "freeagent", etc.), the role normalization process should consistently return the same free agent settings configuration.
**Validates: Requirements 6.2**

### Property 3: Settings Provider Integration
*For any* free agent role processed by RoleBasedSettingsProvider, the provider should return the free agent settings configuration and each returned SettingsSectionModel should have a non-null title and screen.
**Validates: Requirements 1.1, 6.1**

## Error Handling

### Role Recognition Errors
- **Unknown Role Variations**: If an unrecognized free agent role variation is encountered, the system falls back to player settings with appropriate logging
- **Null Role Handling**: Empty or null roles default to player settings to prevent crashes

### Navigation Errors
- **Screen Construction Failures**: If any settings screen fails to construct, the error is caught and logged, with graceful fallback to a basic error screen
- **Route Navigation Issues**: Navigation failures are handled by the Flutter framework's built-in error handling

### Data Validation
- **Settings Model Validation**: All SettingsSectionModel objects are validated to ensure they have non-null titles and screens
- **Provider State Management**: The provider ensures consistent state management across navigation events

## Testing Strategy

### Unit Testing Approach
- **Settings Configuration Tests**: Verify that `getFreeAgentSettings()` returns the correct number and type of settings sections
- **Role Normalization Tests**: Test various free agent role string inputs to ensure consistent normalization
- **Provider Integration Tests**: Validate that the RoleBasedSettingsProvider correctly handles free agent roles
- **Navigation Tests**: Test that each settings section navigates to the expected screen

### Property-Based Testing Configuration
- **Testing Framework**: Use Flutter's built-in test framework with custom property test utilities
- **Test Iterations**: Minimum 100 iterations per property test
- **Input Generation**: Generate various role string formats and user interaction patterns
- **Property Validation**: Each property test references its corresponding design document property

### Integration Testing
- **End-to-End Navigation**: Test complete user flows from role assignment through settings navigation
- **Screen Integration**: Verify that reused screens work correctly in the free agent context
- **Provider State Management**: Test that settings selection and navigation maintain proper state

### Test Organization
- Unit tests focus on individual functions and components
- Property tests verify universal behaviors across all inputs
- Integration tests validate complete user workflows
- All tests include descriptive names and clear assertions