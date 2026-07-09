import 'package:flutter/material.dart';
import 'package:workload_tracker_app/screens/auth/login_screen.dart';
import 'package:workload_tracker_app/screens/hod/%20hod_dashboard_screen.dart';
import 'package:workload_tracker_app/screens/hod/add_lecturer_screen.dart';
import 'package:workload_tracker_app/screens/hod/assign_module_screen.dart';
import 'package:workload_tracker_app/screens/lecturer/add_module_screen.dart';
import 'package:workload_tracker_app/screens/lecturer/lecturer_dashboard_screen.dart';
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
        '/add-module': (context) => const AddModuleScreen(),
        '/assign-module': (context) => const AssignModuleScreen(),
        '/hod-dashboard': (context) => const HodDashboardScreen(),
        '/add-lecturer': (context) => const AddLecturerScreen(),
        '/lecturer-dashboard': (context) => const LecturerDashboardScreen(),
      },
    );
  }
}