import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:i_wakili/Auth/auth_gate.dart';
import 'package:i_wakili/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
    url: 'https://aphmcacwbrtxcpabyuef.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwaG1jYWN3YnJ0eGNwYWJ5dWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNTg2MDMsImV4cCI6MjA5MTgzNDYwM30.4E7hF-LqGapJ8BjzjjyBLEYbUBWHBZTv61Q3bFoPLj4',

  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(), // 🔥 IMPORTANT CHANGE
    );
  }
}