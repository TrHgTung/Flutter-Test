import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_flutter_application/main/mailScreen.dart';
import 'dart:convert';
import 'apiService.dart';
import 'login/loginScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService(baseUrl: 'http://10.0.2.2:4401');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {'/mail': (_) => MailScreen()},
    );
  }
}

// class ApiHomePage extends StatefulWidget {
//   final ApiService apiService;
//   const ApiHomePage({super.key, required this.apiService});

//   @override
//   State<ApiHomePage> createState() => _ApiHomePageState();
// }

// class _ApiHomePageState extends State<ApiHomePage> {
//   List<dynamic> items = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   Future<void> _loadItems() async {
//     final data = await widget.apiService.getAll('Mail');
//     setState(() {
//       items = data;
//     });
//   }

//   Future<void> _createItem() async {
//     final success = await widget.apiService.create('login', {
//       'name': 'New Item',
//       'value': 123,
//     });
//     if (success) _loadItems();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test API')),
//       body: ListView.builder(
//         itemCount: items.length,
//         itemBuilder: (_, index) {
//           final item = items[index];
//           return ListTile(
//             title: Text(item['name'] ?? ''),
//             subtitle: Text('Value: ${item['value']}'),
//             trailing: Row(mainAxisSize: MainAxisSize.min),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _createItem,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
