import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MailScreen extends StatefulWidget {
  @override
  _MailScreenState createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  final _storage = FlutterSecureStorage();
  List<dynamic> _emails = [];
  bool _loading = true;

  Future<void> _fetchEmails() async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null) {
      // Token không tồn tại, quay lại login
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:4401/api/Mail'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> emails = decoded['all_mails_sent'];
      setState(() {
        _emails = emails;
        _loading = false;
      });
    } else {
      // Token hết hạn hoặc lỗi, quay lại login
      await _storage.delete(key: 'auth_token');
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách Email')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _emails.length,
                itemBuilder: (context, index) {
                  final mail = _emails[index];
                  return ListTile(
                    title: Text(mail['MailSubject'] ?? 'Không có tiêu đề'),
                    subtitle: Text(mail['MailContent'] ?? 'Không có nội dung'),
                    trailing: Text(mail['TimeSent'] ?? 'Không có ngày gửi'),
                  );
                },
              ),
    );
  }
}
