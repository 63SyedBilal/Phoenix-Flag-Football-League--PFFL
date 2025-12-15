import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Test login with pffl@gmail.com
  final url = Uri.parse('http://192.168.1.13:3000/api/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'pffl@gmail.com',
      'password': '123456',
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    print('✅ Login successful!');
    final data = jsonDecode(response.body);
    print('User Role: ${data['data']['role']}');
  } else {
    print('❌ Login failed!');
  }
}