import 'package:eishen_matrix/pages/home_page.dart';
import 'package:eishen_matrix/task.dart';
import 'package:eishen_matrix/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Ensure that plugin services are initialized before running the app
  // This is necessary for using plugins like path_provider.
    WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register your Task adapter (generated)
  Hive.registerAdapter(TaskAdapter());
  
  // Open the tasks box (like a table)
  await Hive.openBox<Task>('tasks');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().lightTheme,
      home: HomePage(),
    );
  }
}
