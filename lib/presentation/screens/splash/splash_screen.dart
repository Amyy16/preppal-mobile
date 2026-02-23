import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepal2/presentation/providers/auth_provider.dart';
import 'package:prepal2/presentation/screens/auth/login_screen.dart';
import 'package:prepal2/presentation/screens/main_shell.dart';
import 'package:prepal2/presentation/screens/auth/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for auth state to resolve then navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenAndNavigate();
    });
  }

  void _listenAndNavigate() {
    final authProvider = context.read<AuthProvider>();

    // If already resolved, navigate immediately
    if (authProvider.status != AuthStatus.initial &&
        authProvider.status != AuthStatus.loading) {
      _navigate(authProvider.status);
      return;
    }

    // Otherwise wait for the status to change
    authProvider.addListener(() {
      if (authProvider.status != AuthStatus.initial &&
          authProvider.status != AuthStatus.loading) {
        _navigate(authProvider.status);
      }
    });
  }

  void _navigate(AuthStatus status) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => status == AuthStatus.authenticated
            ? const MainShell() // Has session → go to main shell
            : const WelcomeScreen(),  // No session → go to welcome
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFD32F2F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder — replace with your actual logo asset
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.black,
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Welcome Screen (first screen from wireframe)
// --------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo
              const CircleAvatar(
                radius: 70,
                backgroundColor: Colors.black,
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 70,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App name
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),

              const SizedBox(height: 8),

              // Tagline from wireframe
              const Text(
                'PrepPal is here to make prepping\nmore effective and profitable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // Log In button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    // go_router: context.go('/login')
                  );
                },
                child: const Text('Log in'),
              ),

              const SizedBox(height: 12),

              // Sign Up button (outlined style)
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                    // go_router: context.go('/signup')
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  foregroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign up'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}