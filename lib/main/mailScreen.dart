import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

// ===== MODEL =====
class MailItem {
  final String subject;
  final String content;
  final String time;
  bool isRead;

  MailItem({
    required this.subject,
    required this.content,
    required this.time,
    this.isRead = false,
  });

  factory MailItem.fromJson(Map<String, dynamic> json) {
    return MailItem(
      subject: json['mailSubject'] ?? 'Không có tiêu đề',
      content: json['mailContent'] ?? 'Không có nội dung',
      time: json['timeSent'] ?? 'Không có ngày gửi',
    );
  }

  String get formattedTime {
    try {
      final parsed = DateFormat("HH:mm").parse(time);
      return DateFormat("HH:mm").format(parsed);
    } catch (context) {
      return time;
    }
  }
}

// ===== SCREEN =====
class MailScreen extends StatefulWidget {
  @override
  _MailScreenState createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  final _storage = FlutterSecureStorage();
  List<MailItem> _allEmails = [];
  List<MailItem> _visibleEmails = [];
  bool _loading = true;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 10;

  Future<void> _fetchEmails() async {
    String _displayName = '';
    final token = await _storage.read(key: 'auth_token');

    _displayName = await _storage.read(key: 'display_name') ?? '';
    if (_displayName.isEmpty) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:4401/api/Mail'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> jsonList = decoded['all_mails_sent'] ?? [];

      _allEmails = jsonList.map((e) => MailItem.fromJson(e)).toList();
      _applySearchAndPagination();
      setState(() => _loading = false);
    } else {
      await _storage.delete(key: 'auth_token');
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _applySearchAndPagination() {
    List<MailItem> filtered =
        _allEmails.where((e) {
          return e.subject.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    final int end = (_currentPage * _pageSize);
    _visibleEmails = filtered.take(end).toList();
  }

  void _loadMore() {
    setState(() {
      _currentPage++;
      _applySearchAndPagination();
    });
  }

  void _markAsRead(MailItem mail) {
    setState(() {
      mail.isRead = true;
    });
  }

  void _showMailDetails(MailItem mail) {
    _markAsRead(mail);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(mail.subject),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🕒 Gửi lúc: ${mail.formattedTime}"),
                SizedBox(height: 8),
                Text(mail.content),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Đóng"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận đăng xuất'),
            content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
            actions: [
              TextButton(
                child: Text('Hủy'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Đăng xuất'),
                onPressed: () async {
                  await _storage
                      .deleteAll(); // xóa token và thông tin người dùng
                  Navigator.pushReplacementNamed(
                    context,
                    '/',
                  ); // Quay lại login
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Email'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              _confirmLogout();
              // _storage.delete(key: 'auth_token'); // Xoá token
              // Navigator.pushReplacementNamed(context, '/'); // Quay lại login
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔍 Tìm kiếm tiêu đề...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                  _applySearchAndPagination();
                });
              },
            ),
          ),
        ),
      ),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _visibleEmails.isEmpty
              ? Center(child: Text('Không có email nào.'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _visibleEmails.length,
                      itemBuilder: (context, index) {
                        final mail = _visibleEmails[index];
                        return GestureDetector(
                          onTap: () => _showMailDetails(mail),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            color:
                                mail.isRead ? Colors.grey[100] : Colors.white,
                            child: ListTile(
                              title: Text(
                                mail.subject,
                                style: TextStyle(
                                  fontWeight:
                                      mail.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                mail.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(mail.formattedTime),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_visibleEmails.length <
                      _allEmails
                          .where(
                            (e) => e.subject.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .length)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: ElevatedButton(
                        onPressed: _loadMore,
                        child: Text('Tải thêm'),
                      ),
                    ),
                ],
              ),
    );
  }
}
