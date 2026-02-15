import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/inventory_item.dart';
import 'models/waste_log.dart';
import 'screens/welcome/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(WasteLogAdapter());
  
  // Open Hive boxes
  await Hive.openBox<InventoryItem>('inventory');
  await Hive.openBox<WasteLog>('waste_logs');
  
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
