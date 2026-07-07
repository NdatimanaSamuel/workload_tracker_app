import 'package:flutter/material.dart';
import 'package:workload_tracker_app/main.dart';
import 'package:workload_tracker_app/screens/auth/login_screen.dart';

class MyRoutes extends StatelessWidget {
  const MyRoutes({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
       routes: {
         '/': (context) => MyApp(),
         '/login-page': (context) => LoginPage(),
       },
    );
  }
}
