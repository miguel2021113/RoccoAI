import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await Supabase.initialize(
    url: 'https://efeikhgaavpvgdsneaty.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmZWlraGdhYXZwdmdkc25lYXR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE1MzU2MDMsImV4cCI6MjA0NzExMTYwM30.lU_y2rd1-VmiX9ifk77kvLDnj_vbHMio2zJDVrlYxTk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoccoAI',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const LoginScreen(),
    );
  }
}