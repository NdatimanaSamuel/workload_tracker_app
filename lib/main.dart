import 'package:flutter/material.dart';
import 'package:workload_tracker_app/screens/auth/login_screen.dart';
import 'screens/shared/splash_screen.dart';
// You'll add these imports once those screens exist:
// import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workload Tracker',
      debugShowCheckedModeBanner: false, // removes the red "DEBUG" banner
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // clean default; swap later if you add a custom font
      ),
      // initialRoute tells the app which screen to show FIRST when it launches
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(), // add once built
      },
    );
  }
}