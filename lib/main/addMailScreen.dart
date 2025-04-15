import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AddMailScreen extends StatefulWidget {
  @override
  _AddMailScreenState createState() => _AddMailScreenState();
}

class _AddMailScreenState extends State<AddMailScreen> {
  final _storage = FlutterSecureStorage();
  final _toAddressController = TextEditingController();
  final _mailSubjectController = TextEditingController();
  final _mailContentController = TextEditingController();
  // final _attachmentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedFile;

  String _error = '';

  Future<void> _saveMail() async {
    final uri = Uri.parse('http://localhost:4401/api/Mail');
    final token = await _storage.read(key: 'auth_token');

    if (token == null) {
      setState(() {
        _error = 'Bạn chưa đăng nhập.';
      });
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Tạo multipart request
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    // request.headers['Content-Type'] = 'multipart/form-data';
    // request.headers['Accept'] = 'application/json';

    request.fields['ToAddress'] = _toAddressController.text;
    request.fields['MailSubject'] = _mailSubjectController.text;
    request.fields['MailContent'] = _mailContentController.text;
    // request.fields['Attachment'] = _attachmentController.text;

    if (_selectedFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('Attachment', _selectedFile!.path),
      );
    } else {
      print("Không có file hoặc file không tồn tại");
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/mail');
      } else {
        if (response.body.isNotEmpty) {
          try {
            final json = jsonDecode(response.body);
            setState(() {
              _error = json['message'] ?? 'Lưu thư thất bại. Vui lòng thử lại.';
            });
          } catch (e) {
            print("Lỗi JSON: $e");
            setState(() {
              _error = 'Đáp ứng từ server không hợp lệ.';
            });
          }
        } else {
          // print("Status code: ${response.statusCode}");
          // print("Response headers: ${response.headers}");
          // print("Response body: ${response.body}");

          setState(() {
            _error = 'Không nhận được phản hồi từ server.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối đến server: $e';
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
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
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lưu thư')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _toAddressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ Email bạn muốn gửi đến',
                ),
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
                controller: _mailSubjectController,
                decoration: InputDecoration(labelText: 'Tiêu đề thư'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên hiển thị';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mailContentController,
                decoration: InputDecoration(labelText: 'Nội dung thư'),
                maxLines: 10,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(
                  _selectedFile == null
                      ? 'Chọn tệp đính kèm'
                      : "Tệp đã chọn: ${_selectedFile!.path.split('/').last}",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveMail();
                  }
                },
                child: Text('Lưu thư'),
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
