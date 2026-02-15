import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(initialLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool initialLoggedIn;
  const MyApp({super.key, required this.initialLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prepal: A Food Waste Management System',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: WelcomeScreen(initialLoggedIn: initialLoggedIn),
      debugShowCheckedModeBanner: false,
    );
  }
}
