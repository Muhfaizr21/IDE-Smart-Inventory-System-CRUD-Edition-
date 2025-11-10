import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'utils/secure_storage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EntryPoint(),
    );
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});
  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  String? token;
  @override
  void initState() {
    super.initState();
    checkToken();
  }

  void checkToken() async {
    final t = await readToken();
    setState(() => token = t);
  }

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return const LoginScreen();
    } else {
      return const ProductListScreen();
    }
  }
}
