// lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepal2/presentation/providers/auth_provider.dart';
import 'package:prepal2/presentation/screens/auth/signup_screen.dart';
import 'package:prepal2/presentation/screens/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key to identify and validate the form
  final _formKey = GlobalKey<FormState>();

  // Controllers to read TextField values
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Tracks whether password is visible or hidden
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate all form fields first
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous errors
    context.read<AuthProvider>().clearError();

    final success = await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Replace login screen with dashboard (can't go back to login)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainShell(),
        ),
        // go_router: context.go('/dashboard')
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this widget whenever AuthProvider changes
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Prevents overflow when keyboard opens
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // Logo
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black,
                  child: Text(
                    'P',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Please Input Email and Password',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),

                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => authProvider.clearError(),
                  decoration: const InputDecoration(
                    hintText: 'Email/Username',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null; // null means valid
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) => authProvider.clearError(),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    // Eye icon to toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscurePassword = !_obscurePassword,
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // API error message (from provider)
                if (authProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFB00020),
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed:
                      authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Log in'),
                ),

                const SizedBox(height: 24),

                // Navigate to Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                          // go_router: context.go('/signup')
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
