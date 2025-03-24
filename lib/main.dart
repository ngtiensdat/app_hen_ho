import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/login_screen.dart';
//import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wzlswcgrcqqmdpucxdjb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6bHN3Y2dyY3FxbWRwdWN4ZGpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI3MTY2NjQsImV4cCI6MjA1ODI5MjY2NH0.0H_1R4xaP8mND-WR_W4WAabkF2iAKCuVJePnb0djnTo', // Thay bằng Anon Key từ Supabase
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
