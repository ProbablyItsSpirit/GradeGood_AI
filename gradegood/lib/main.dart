import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gradegood/pages/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ujpunglgnfwwnrjwoyec.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqcHVuZ2xnbmZ3d25yandveWVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwODEwOTAsImV4cCI6MjA1ODY1NzA5MH0.BexLV2nD_avtt9-MitCHt9pwvVXwIRB1m0sCBG1hM-Q',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GradeGood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF2196F3),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const LandingPage(),
    );
  }
}

