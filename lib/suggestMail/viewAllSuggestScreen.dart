import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

// ===== MODEL =====
class SuggestionItem {
  final int id;
  final String content;
  final int rating;

  SuggestionItem({
    required this.id,
    required this.content,
    required this.rating,
  });

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    return SuggestionItem(
      id: json['id'],
      content: json['content'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }
}

// ===== SCREEN =====
class AllSuggest extends StatefulWidget {
  @override
  _AllSuggestState createState() => _AllSuggestState();
}

class _AllSuggestState extends State<AllSuggest> {
  final _storage = FlutterSecureStorage();
  List<SuggestionItem> _suggestions = [];
  bool _loading = true;

  Future<void> _fetchSuggestions() async {
    try {
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:4401/api/Suggestions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print("Decoded JSON: $data");

          if (data is Map && data['suggestions'] is List) {
            final List<dynamic> listSuggestion = data['suggestions'];

            setState(() {
              _suggestions =
                  listSuggestion.map((e) => SuggestionItem.fromJson(e)).toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));
              _loading = false;
            });
          } else {
            throw Exception("Dữ liệu trả về không đúng đinh dạng");
          }
        } catch (e) {
          print("Lỗi khi parse JSON: $e");
          setState(() {
            _loading = false;
          });
        }
      } else {
        print("Lỗi API: ${response.statusCode}");
        await _storage.delete(key: 'auth_token');
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách gợi ý Email'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await _storage.deleteAll();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _suggestions.isEmpty
              ? Center(child: Text('Không có gợi ý nào.'))
              : ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(suggestion.content),
                      subtitle: Text("Gợi ý của hệ thống"),
                      onTap: () {
                        _showSuggestionDetails(suggestion);
                      },
                    ),
                  );
                },
              ),
    );
  }

  void _showSuggestionDetails(SuggestionItem suggestion) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chi tiết gợi ý'),
            content: SingleChildScrollView(child: Text(suggestion.content)),
            actions: [
              TextButton(
                child: Text('Đóng'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Sao chép'),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: suggestion.content),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã sao chép vào clipboard')),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }
}
