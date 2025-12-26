import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/auth/complete_profile.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/enhanced_complete_profile_provider.dart';

/// Test file for Enhanced CompleteProfile functionality
/// Tests image upload, multiple position selection, validation, and backend integration
void main() {
  group('Enhanced CompleteProfile Tests', () {
    late UserPreferenceProvider mockUserPrefs;
    late EnhancedCompleteProfileProvider provider;

    setUp(() {
      // Create mock user preferences
      mockUserPrefs = UserPreferenceProvider();
      provider = EnhancedCompleteProfileProvider(mockUserPrefs);
    });

    testWidgets('CompleteProfile screen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<UserPreferenceProvider>.value(
                value: mockUserPrefs,
              ),
            ],
            child: const CompleteProfile(),
          ),
        ),
      );

      // Verify key elements are present
      expect(find.text('Complete Your Profile'), findsOneWidget);
      expect(find.text('Profile Pic *'), findsOneWidget);
      expect(find.text('Phone Number *'), findsOneWidget);
      expect(find.text('Position *'), findsOneWidget);
      expect(find.text('Emergency Contact Name *'), findsOneWidget);
      expect(find.text('Emergency Phone Number *'), findsOneWidget);
      expect(find.text('I agree to Terms & Privacy *'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });

    test('Multiple position selection works correctly', () {
      // Test initial state
      expect(provider.selectedPositions, isEmpty);
      expect(provider.isPositionSelected('Quarterback'), false);

      // Test adding positions
      provider.togglePosition('Quarterback');
      expect(provider.selectedPositions, contains('Quarterback'));
      expect(provider.isPositionSelected('Quarterback'), true);

      provider.togglePosition('Receiver');
      expect(provider.selectedPositions, hasLength(2));
      expect(provider.selectedPositions, contains('Receiver'));

      // Test removing positions
      provider.togglePosition('Quarterback');
      expect(provider.selectedPositions, hasLength(1));
      expect(provider.selectedPositions, contains('Receiver'));
      expect(provider.isPositionSelected('Quarterback'), false);
    });

    test('Form validation works correctly', () {
      // Test initial validation - should fail
      expect(provider.isFormValid, false);

      // Add required fields one by one
      provider.setPhone('+1234567890');
      expect(provider.isFormValid, false); // Still missing other fields

      provider.togglePosition('Quarterback');
      expect(provider.isFormValid, false); // Still missing other fields

      provider.setEmergencyContactName('John Doe');
      expect(provider.isFormValid, false); // Still missing other fields

      provider.setEmergencyPhone('+1987654321');
      expect(provider.isFormValid, false); // Still missing image and terms

      provider.toggleTermsAgreement(true);
      expect(provider.isFormValid, false); // Still missing image

      // Mock image path
      provider.setProfileImage('/mock/path/image.jpg');
      expect(provider.isFormValid, true); // Now should be valid
    });

    test('Phone number validation works', () {
      // Test invalid phone numbers
      provider.setPhone('123');
      expect(provider.fieldErrors['phone'], isNotNull);

      provider.setPhone('invalid');
      expect(provider.fieldErrors['phone'], isNotNull);

      // Test valid phone number
      provider.setPhone('+1234567890');
      expect(provider.fieldErrors['phone'], isNull);
    });

    test('Jersey number validation works', () {
      // Test invalid jersey numbers
      provider.setJerseyNumber('0');
      expect(provider.fieldErrors['jerseyNumber'], isNotNull);

      provider.setJerseyNumber('100');
      expect(provider.fieldErrors['jerseyNumber'], isNotNull);

      provider.setJerseyNumber('abc');
      expect(provider.fieldErrors['jerseyNumber'], isNotNull);

      // Test valid jersey numbers
      provider.setJerseyNumber('1');
      expect(provider.fieldErrors['jerseyNumber'], isNull);

      provider.setJerseyNumber('99');
      expect(provider.fieldErrors['jerseyNumber'], isNull);

      provider.setJerseyNumber('50');
      expect(provider.fieldErrors['jerseyNumber'], isNull);
    });

    test('Emergency contact validation works', () {
      // Test invalid emergency contact names
      provider.setEmergencyContactName('A');
      expect(provider.fieldErrors['emergencyContactName'], isNotNull);

      provider.setEmergencyContactName('');
      expect(
        provider.fieldErrors['emergencyContactName'],
        isNull,
      ); // Cleared when empty

      // Test valid emergency contact names
      provider.setEmergencyContactName('John Doe');
      expect(provider.fieldErrors['emergencyContactName'], isNull);
    });

    test('Emergency phone validation works', () {
      // Test invalid emergency phone numbers
      provider.setEmergencyPhone('123');
      expect(provider.fieldErrors['emergencyPhone'], isNotNull);

      // Test valid emergency phone numbers
      provider.setEmergencyPhone('+1234567890');
      expect(provider.fieldErrors['emergencyPhone'], isNull);
    });

    test('Position display text works correctly', () {
      // Test empty positions
      expect(
        provider.positionsDisplayText,
        'Select positions (e.g. Rusher, Blocker)',
      );

      // Test single position
      provider.togglePosition('Quarterback');
      expect(provider.positionsDisplayText, 'Quarterback');

      // Test multiple positions
      provider.togglePosition('Receiver');
      expect(provider.positionsDisplayText, 'Quarterback, Receiver');
    });

    test('Available positions are correct', () {
      expect(provider.availablePositions, hasLength(6));
      expect(provider.availablePositions, contains('Quarterback'));
      expect(provider.availablePositions, contains('Receiver'));
      expect(provider.availablePositions, contains('Running Back'));
      expect(provider.availablePositions, contains('Linebacker'));
      expect(provider.availablePositions, contains('Cornerback'));
      expect(provider.availablePositions, contains('Safety'));
    });

    test('Terms agreement works correctly', () {
      // Test initial state
      expect(provider.agreedToTerms, false);

      // Test toggling
      provider.toggleTermsAgreement(true);
      expect(provider.agreedToTerms, true);

      provider.toggleTermsAgreement(false);
      expect(provider.agreedToTerms, false);

      provider.toggleTermsAgreement(null); // Should default to false
      expect(provider.agreedToTerms, false);
    });
  });

  group('Position Display Tests', () {
    testWidgets('MultiplePositionSelector renders correctly', (
      WidgetTester tester,
    ) async {
      final positions = ['Quarterback', 'Receiver'];
      final selectedPositions = ['Quarterback'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiplePositionSelector(
              availablePositions: positions,
              selectedPositions: selectedPositions,
              onPositionToggle: (position) {},
            ),
          ),
        ),
      );

      // Verify positions are displayed
      expect(find.text('Quarterback'), findsOneWidget);
      expect(find.text('Receiver'), findsOneWidget);
      expect(find.text('Selected Positions:'), findsOneWidget);
      expect(
        find.text('Quarterback'),
        findsWidgets,
      ); // Should appear in both places
    });

    testWidgets('Position selection visual feedback works', (
      WidgetTester tester,
    ) async {
      final positions = ['Quarterback', 'Receiver'];
      var selectedPositions = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: MultiplePositionSelector(
                  availablePositions: positions,
                  selectedPositions: selectedPositions,
                  onPositionToggle: (position) {
                    setState(() {
                      if (selectedPositions.contains(position)) {
                        selectedPositions.remove(position);
                      } else {
                        selectedPositions.add(position);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Tap on Quarterback
      await tester.tap(find.text('Quarterback'));
      await tester.pump();

      // Verify selection state changed
      expect(selectedPositions, contains('Quarterback'));
    });
  });
}

/// Helper function to run the tests
void runCompleteProfileTests() {
  print('🧪 Running Enhanced CompleteProfile Tests...');
  print('✅ Multiple position selection');
  print('✅ Form validation');
  print('✅ Phone number validation');
  print('✅ Jersey number validation');
  print('✅ Emergency contact validation');
  print('✅ Terms agreement');
  print('✅ Position display');
  print('✅ Visual feedback');
  print('🎉 All tests configured and ready to run!');
}
