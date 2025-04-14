import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Registerscreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<Registerscreen> {
  final _storage = FlutterSecureStorage();
  final _usernameController = TextEditingController();
  final _displaynameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _smtppasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _error = '';

  Future<void> _register() async {
    final uri = Uri.parse('http://localhost:4401/register');

    // Tạo multipart request
    var request = http.MultipartRequest('POST', uri);

    // Gửi field đúng tên giống ReactJS: Email, Password (chữ hoa đầu)
    request.fields['Email'] = _usernameController.text;
    request.fields['DisplayName'] = _displaynameController.text;
    request.fields['Password'] = _passwordController.text;
    request.fields['SMTPPassword'] = _smtppasswordController.text;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['token'];
        final displayName = json['display_name'];

        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'display_name', value: displayName);
        Navigator.pushReplacementNamed(context, '/');
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
      appBar: AppBar(title: Text('Đăng ký tài khoản')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  final emailRegex = RegExp(
                    r'^[\w.-]+@([\w-]+\.)+[\w-]{2,30}$',
                  );
                  if (!emailRegex.hasMatch(value) || value.length > 40) {
                    return 'Địa chỉ e-mail này không hợp lệ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _displaynameController,
                decoration: InputDecoration(labelText: 'Tên hiển thị'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên hiển thị';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mật khẩu phải từ 6 ký tự';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _smtppasswordController,
                decoration: InputDecoration(labelText: 'Mật khẩu SMTP'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu SMTP hợp lệ để có thể thực hiện gửi mail';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                child: Text('Đăng ký'),
              ),
              if (_error.isNotEmpty) ...[
                SizedBox(height: 10),
                Text(_error, style: TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
