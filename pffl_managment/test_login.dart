import 'package:pffl_managment/core/services/auth_service.dart';

void main() async {
  print('=== TESTING LOGIN FUNCTIONALITY ===');

  // Test the login with the provided credentials
  try {
    print('Testing login with pffl@gmail.com / 123456');
    final result = await AuthService.login('pffl@gmail.com', '123456');

    if (result != null) {
      print('✅ Login successful!');
      print('User ID: ${result.data.id}');
      print('Email: ${result.data.email}');
      print('Role: ${result.data.role}');
      print('Token: ${result.token.substring(0, 20)}...');
    } else {
      print('❌ Login failed - null response');
    }
  } catch (e) {
    print('❌ Login failed with error: $e');
  }

  print('=== TEST COMPLETE ===');
}
