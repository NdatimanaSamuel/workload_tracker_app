import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // A GlobalKey lets us "talk to" the Form widget from code — e.g. to check
  // "are all fields valid?" before submitting. Without this, TextFormField's
  // validator functions never actually get triggered.
  final _formKey = GlobalKey<FormState>();

  // Controllers let us READ what the user typed into each field.
  // Without a controller, you have no way to grab the email/password
  // values when the Login button is pressed.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Tracks whether the password is currently visible or hidden (dots).
  // This is just a plain boolean stored in this screen's state.
  bool _obscurePassword = true;

  // Tracks whether a login request is currently in progress, so we can
  // show a spinner on the button and stop the user from double-tapping.
  bool _isLoading = false;

  // dispose() runs when this screen is removed from the app (e.g. user
  // navigates away). We MUST dispose controllers here, or they leak memory —
  // Flutter won't clean them up automatically for you.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // This function will later call your AuthService and hit /auth/login.
  // For now it's just a placeholder showing the pattern.
  void _handleLogin() async {
    // .validate() runs every TextFormField's validator function.
    // It returns false immediately if ANY field fails validation,
    // and shows the error text under that field automatically.
    if (!_formKey.currentState!.validate()) {
      return; // stop here if the form isn't valid — don't attempt login
    }

    setState(() => _isLoading = true); // show spinner, disable button

    // TODO: replace this with a real call to AuthService.login(...)
    await Future.delayed(const Duration(seconds: 2)); // fake network delay for now

    setState(() => _isLoading = false); // hide spinner again
  }

  @override
  Widget build(BuildContext context) {
    // No MaterialApp here — just return the Scaffold directly.
    // MaterialApp belongs ONLY in main.dart, wrapping the whole app once.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // SafeArea keeps content away from notches/status bars/system UI
        child: Center(
          child: SingleChildScrollView(
            // SingleChildScrollView prevents overflow errors when the
            // on-screen keyboard pops up and shrinks available space
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo container — same rounded-square style as splash screen,
                  // keeps visual consistency across the app
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.primaryLight,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Welcome back",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sign in to continue",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    // validator runs when .validate() is called — return a
                    // String to show as an error, or null if the input is fine
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null; // valid
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: AppColors.textPrimary),
                    obscureText: _obscurePassword, // hides/shows text based on state
                    decoration: _inputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline,
                    ).copyWith(
                      // A tappable eye icon to toggle password visibility
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Login button — full width, shows a spinner while loading
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      // onPressed: null disables the button — this stops
                      // double-submitting while a request is already in flight
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Signup link — TextButton so it's actually tappable,
                  // not just plain unclickable Text like before
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // A small helper function so both TextFormFields share the same styling
  // instead of repeating this decoration code twice
  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
    );
  }
}