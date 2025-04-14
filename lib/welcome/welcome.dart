import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Screen',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final _storage = FlutterSecureStorage();

  Future<bool> _isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng đến với EmailApp',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quản lý email đơn giản và hiệu quả.\n'
                '- Đăng nhập an toàn\n'
                '- Đăng ký nhanh chóng\n'
                '- Truy xuất email từ máy chủ\n'
                '- Giao diện dễ sử dụng',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Center(
                child: Image.asset('assets/images/Dragonite.png', height: 200),
              ),
              const Spacer(),
              FutureBuilder<bool>(
                future: _isLoggedIn(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data == true) {
                    return Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/mail');
                        },
                        icon: const Icon(Icons.mail),
                        label: const Text('Kiểm tra email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Đăng nhập'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          icon: const Icon(Icons.app_registration),
                          label: const Text('Đăng ký'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
