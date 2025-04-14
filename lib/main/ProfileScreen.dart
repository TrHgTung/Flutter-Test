import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen();

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  final _storage = FlutterSecureStorage();
  Map<String, dynamic>? _userData;
  String _error = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final uri = Uri.parse('http://localhost:4401/profile');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        final json = jsonDecode(response.body);
        _userData = json['user_information'];
        // _userData = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Xảy ra sự cố khi tải thông tin người dùng';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin về bạn'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _userData != null
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/Dragonite.png',
                        height: 150,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tên hiển thị: ${_userData!['display_name']}',
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Địa chỉ email: ${_userData!['email']}',
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Center(child: Text('Không có dữ liệu')),
    );
  }
}
