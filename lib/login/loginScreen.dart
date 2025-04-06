import 'package:flutter/material.dart';
import '../apiService.dart';

class LoginScreen extends StatefulWidget {
  final ApiService apiService;

  const LoginScreen({super.key, required this.apiService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? error;

  void _handleLogin() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await widget.apiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final token = result['token'];
      final displayName = result['display_name'];
      final smtpPassword = result['SMTP_pswrd'];
      final user = result['user'];

      // Gợi ý: Lưu token vào local storage (SharedPreferences) nếu cần
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xin chào $displayName')));

      // TODO: Chuyển sang trang chính sau khi login
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
