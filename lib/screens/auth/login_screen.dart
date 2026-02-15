import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

/// Simple Login Screen for PrePal
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? true;
      if (!mounted) return;
      setState(() => _rememberMe = remember);
      if (remember) {
        _emailController.text = prefs.getString('user_email') ?? '';
        _passwordController.text = prefs.getString('user_password') ?? '';
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Call API login
      final response = await ApiService.login(email: email, password: password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Save credentials if "remember me" is checked
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('remember_me', _rememberMe);
      
      if (_rememberMe) {
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);
      } else {
        await prefs.remove('user_password');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          duration: Duration(milliseconds: 500),
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool _isValidPassword(String value) {
    // Pattern requires: letters, at least one digit (0-9) or special char (#$%*), and 8+ chars
    final pattern = RegExp('^(?=.*[A-Za-z])(?=.*[\\d#\$%*]).{8,}\$');
    return pattern.hasMatch(value);
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm new password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final current = currentController.text;
                final next = newController.text;
                final confirm = confirmController.text;
                final email = _emailController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter your email first')),
                  );
                  return;
                }
                if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }
                if (!_isValidPassword(next)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use at least 8 chars with letters and numbers')),
                  );
                  return;
                }
                if (next != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final storedEmail = prefs.getString('user_email');
                final storedPassword = prefs.getString('user_password');

                if (storedEmail != email || storedPassword != current) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Current password is incorrect')),
                  );
                  return;
                }

                await prefs.setString('user_password', next);
                if (!mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Log In', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Logo area
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.eco, size: 52, color: Color(0xFFFFC107)),
                ),
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        final pattern = RegExp('^(?=.*[A-Za-z])(?=.*[\\d#\$%*]).{8,}\$');
                        if (!pattern.hasMatch(v)) {
                          return 'Use at least 8 chars: letters, numbers, #, \$, %, *';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Forgot password (demo)')),
                              );
                            },
                            child: const Text('Forgot password?'),
                          ),
                          const SizedBox(width: 6),
                          TextButton(
                            onPressed: _showChangePasswordDialog,
                            child: const Text('Change password'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _rememberMe = value);
                          },
                          activeColor: const Color(0xFFFFC107),
                        ),
                        const Text('Remember me'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Login button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Continue to Home button
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          // Mark as logged in and go to home
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true);
                          } catch (_) {}
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        },
                        child: const Text(
                          'Continue to Home',
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
