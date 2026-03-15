import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://lkkivjvqyngwryuapaaz.supabase.co',       
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxra2l2anZxeW5nd3J5dWFwYWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1NTcwNjYsImV4cCI6MjA4OTEzMzA2Nn0.QzkQkbAsoY1ER8Bb_vekDowNY0M6_3kLRDOdUzQZn10',
  );
  ApiClient().init();
  runApp(const CareerLensApp());
}

class CareerLensApp extends StatelessWidget {
  const CareerLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareerLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}