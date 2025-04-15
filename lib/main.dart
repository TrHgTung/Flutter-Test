import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_flutter_application/login/registerScreen.dart';
import 'package:my_first_flutter_application/main/ProfileScreen.dart';
import 'package:my_first_flutter_application/main/addMailScreen.dart';
import 'package:my_first_flutter_application/main/mailScreen.dart';
import 'dart:convert';
import 'apiService.dart';
import 'login/loginScreen.dart';
import 'welcome/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final ApiService apiService = ApiService(baseUrl: 'http://10.0.2.2:4401');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mail App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // route mặc định
      // home: Registerscreen(),
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
        '/register': (context) => Registerscreen(),
        '/mail': (context) => MailScreen(),
        '/addMail': (context) => AddMailScreen(),
      },
    );
  }
}
