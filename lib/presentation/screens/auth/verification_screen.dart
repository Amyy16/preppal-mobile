// lib/presentation/screens/auth/verification_screen.dart

import 'package:flutter/material.dart';
import 'package:prepal2/presentation/screens/main_shell.dart';

class VerificationScreen extends StatefulWidget {
  final String email; // Passed from signup screen

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // 6 separate controllers — one per OTP digit box
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // Combines all 6 digit boxes into one OTP string
  String get _otp => _controllers.map((c) => c.text).join();

  void _handleVerify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isVerifying = false);
      // Navigate to dashboard after verification
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        // go_router: context.go('/dashboard')
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                child: Text(
                  'P',
                  style: TextStyle(fontSize: 50, color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Verification code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Show which email the code was sent to
              Text(
                'Please input the code sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Row – 6 digit boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1, // Only one digit per box
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '', // Hides the "0/1" character counter
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          // Auto-advance to next box when digit entered
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        }

                        if (value.isEmpty && index > 0) {
                          // Auto-go back when digit deleted
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // Verify button
              ElevatedButton(
                onPressed: _isVerifying ? null : _handleVerify,
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Verify'),
              ),

              const SizedBox(height: 16),

              // Resend code option
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code resent!')),
                  );
                },
                child: const Text(
                  'Resend code',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
