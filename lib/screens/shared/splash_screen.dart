import 'dart:async'; // Gives us access to Timer
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// StatefulWidget instead of StatelessWidget because this screen needs to
// DO something over time (wait, then navigate) — StatelessWidget can't
// hold changing behavior like a timer; StatefulWidget can.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// This is the "brain" half of the StatefulWidget — it holds logic and
// lifecycle methods (like initState, which runs once when the screen loads).
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // initState() runs exactly ONCE, right when this screen first appears.
    // This is the correct place for "do something after a delay" logic —
    // unlike build(), which can re-run many times.
    _navigateAfterDelay();
  }

  // A separate function just to keep initState() clean and readable.
  void _navigateAfterDelay() {
    Timer(const Duration(seconds: 2), () {
      // Always check "mounted" before navigating from inside a Timer —
      // this confirms the screen is still on-screen when the timer fires.
      // (If the user somehow left this screen before 2 seconds passed,
      // this stops a crash from trying to navigate on a screen that's gone.)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
        // pushReplacementNamed (not pushNamed) means the splash screen
        // gets REMOVED from history — so the user can't press "back"
        // and end up staring at the splash screen again.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rounded square icon container — feels more like a modern
            // app logo than a plain circle avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.schedule, // clock-style icon, fits "workload/hours" theme
                color: AppColors.primaryLight,
                size: 40,
              ),
            ),

            const SizedBox(height: 24), // vertical spacing

            Text(
              "Workload Tracker",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Teaching hours, tracked simply",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 32),

            // Small circular spinner, styled with your app's accent color
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}