# Implementation Plan: Free Agent Settings

## Overview

This implementation plan creates the Free Agent Settings functionality by adding a new settings configuration function and integrating it with the existing RoleBasedSettingsProvider. The approach reuses existing settings screens while providing free agents with a tailored menu containing only the sections they need: Player Information, Change Password, Notifications, and Payment History.

## Tasks

- [x] 1. Create free agent settings configuration function
  - Create `getFreeAgentSettings()` function in a new file `lib/screens/settings/roles/free_agent_settings.dart`
  - Return list of four SettingsSectionModel objects with correct titles and screens
  - Import required existing screen widgets
  - _Requirements: 1.2, 2.1, 3.1, 4.1, 5.1_

- [ ]* 1.1 Write property test for free agent settings configuration
  - **Property 1: Free Agent Settings Menu Completeness**
  - **Validates: Requirements 1.2**

- [x] 2. Integrate free agent settings with RoleBasedSettingsProvider
  - Add import for `getFreeAgentSettings()` function in `lib/screens/settings/common/settings_provider.dart`
  - Add 'freeagent' case to the switch statement in `settingsSections` getter
  - Ensure case returns `getFreeAgentSettings()` result
  - _Requirements: 6.1, 6.2_

- [ ]* 2.1 Write property test for role normalization
  - **Property 2: Role Normalization Consistency**
  - **Validates: Requirements 6.2**

- [ ]* 2.2 Write property test for settings provider integration
  - **Property 3: Settings Provider Integration**
  - **Validates: Requirements 1.1, 6.1**

- [ ] 3. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 4. Write unit tests for free agent settings
  - Test that `getFreeAgentSettings()` returns exactly 4 sections
  - Test that all section titles match expected values
  - Test that all sections have non-null screens
  - _Requirements: 1.2_

- [ ]* 5. Write integration tests for role-based provider
  - Test free agent role processing through complete provider workflow
  - Test navigation to each settings screen
  - Test role normalization with various input formats
  - _Requirements: 6.1, 6.2, 1.3_

- [ ] 6. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- All existing screens are reused without modification
- Integration follows established patterns from other role-based settings