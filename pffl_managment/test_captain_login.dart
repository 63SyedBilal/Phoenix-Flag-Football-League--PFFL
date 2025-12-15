import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Test login with captain@gmail.com
  final url = Uri.parse('http://192.168.1.13:3000/api/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'captain@gmail.com',
      'password': '123456',
    }),
  );

  print('Status Code: ${response.statusCode}');
  
  if (response.statusCode == 200) {
    print('✅ Login successful!');
    final data = jsonDecode(response.body);
    print('User Role: ${data['data']['role']}');
    print('User Email: ${data['data']['email']}');
  } else {
    print('❌ Login failed!');
    print('Response: ${response.body}');
  }
}