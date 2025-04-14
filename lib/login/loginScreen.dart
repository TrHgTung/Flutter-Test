import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storage = FlutterSecureStorage();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';

  Future<void> _login() async {
    final uri = Uri.parse('http://localhost:4401/login');

    // Tạo multipart request
    var request = http.MultipartRequest('POST', uri);

    // Gửi field đúng tên giống ReactJS: Email, Password (chữ hoa đầu)
    request.fields['Email'] = _usernameController.text;
    request.fields['Password'] = _passwordController.text;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['token'];
        final displayName = json['display_name'];

        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'display_name', value: displayName);
        Navigator.pushReplacementNamed(context, '/mail');
      } else {
        final json = jsonDecode(response.body);
        setState(() {
          _error = json['message'] ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối đến server.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/mail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Tên đăng nhập'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Đăng nhập')),
            if (_error.isNotEmpty) ...[
              SizedBox(height: 10),
              Text(_error, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
