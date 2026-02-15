import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  String _selectedCountryCode = '+234';

  static const List<Map<String, String>> _countryCodes = [
    {'name': 'Nigeria', 'code': '+234'},
    {'name': 'Ghana', 'code': '+233'},
    {'name': 'Kenya', 'code': '+254'},
    {'name': 'South Africa', 'code': '+27'},
    {'name': 'Cameroon', 'code': '+237'},
    {'name': 'Egypt', 'code': '+20'},
    {'name': 'Ethiopia', 'code': '+251'},
    {'name': 'Rwanda', 'code': '+250'},
    {'name': 'Senegal', 'code': '+221'},
    {'name': 'Tanzania', 'code': '+255'},
    {'name': 'Uganda', 'code': '+256'},
    {'name': 'Morocco', 'code': '+212'},
    {'name': 'Algeria', 'code': '+213'},
    {'name': 'Angola', 'code': '+244'},
    {'name': 'Benin', 'code': '+229'},
    {'name': 'Botswana', 'code': '+267'},
    {'name': 'Burkina Faso', 'code': '+226'},
    {'name': 'Burundi', 'code': '+257'},
    {'name': 'Cape Verde', 'code': '+238'},
    {'name': 'Central African Republic', 'code': '+236'},
    {'name': 'Chad', 'code': '+235'},
    {'name': 'Comoros', 'code': '+269'},
    {'name': 'Congo (DRC)', 'code': '+243'},
    {'name': 'Congo (Republic)', 'code': '+242'},
    {'name': 'Cote d’Ivoire', 'code': '+225'},
    {'name': 'Djibouti', 'code': '+253'},
    {'name': 'Equatorial Guinea', 'code': '+240'},
    {'name': 'Eritrea', 'code': '+291'},
    {'name': 'Eswatini', 'code': '+268'},
    {'name': 'Gabon', 'code': '+241'},
    {'name': 'Gambia', 'code': '+220'},
    {'name': 'Guinea', 'code': '+224'},
    {'name': 'Guinea-Bissau', 'code': '+245'},
    {'name': 'Lesotho', 'code': '+266'},
    {'name': 'Liberia', 'code': '+231'},
    {'name': 'Libya', 'code': '+218'},
    {'name': 'Madagascar', 'code': '+261'},
    {'name': 'Malawi', 'code': '+265'},
    {'name': 'Mali', 'code': '+223'},
    {'name': 'Mauritania', 'code': '+222'},
    {'name': 'Mauritius', 'code': '+230'},
    {'name': 'Mozambique', 'code': '+258'},
    {'name': 'Namibia', 'code': '+264'},
    {'name': 'Niger', 'code': '+227'},
    {'name': 'Sao Tome and Principe', 'code': '+239'},
    {'name': 'Seychelles', 'code': '+248'},
    {'name': 'Sierra Leone', 'code': '+232'},
    {'name': 'Somalia', 'code': '+252'},
    {'name': 'South Sudan', 'code': '+211'},
    {'name': 'Sudan', 'code': '+249'},
    {'name': 'Togo', 'code': '+228'},
    {'name': 'Tunisia', 'code': '+216'},
    {'name': 'Zambia', 'code': '+260'},
    {'name': 'Zimbabwe', 'code': '+263'},
  ];

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
      _selectedCountryCode = prefs.getString('user_country_code') ?? _selectedCountryCode;
      if (remember) {
        _emailController.text = prefs.getString('user_email') ?? '';
        _passwordController.text = prefs.getString('user_password') ?? '';
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _businessController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final businessName = _businessController.text.trim();
      final phone = _phoneController.text.trim();

      // Call API signup
      final response = await ApiService.signup(
        email: email,
        password: password,
        businessName: businessName,
        phoneNumber: phone,
        countryCode: _selectedCountryCode,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Save user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setBool('remember_me', _rememberMe);
      if (_rememberMe) {
        await prefs.setString('user_password', password);
      } else {
        await prefs.remove('user_password');
      }
      await prefs.setString('business_name', businessName);
      await prefs.setString('user_phone', '$_selectedCountryCode$phone');
      await prefs.setString('user_country_code', _selectedCountryCode);
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
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
        SnackBar(content: Text('Signup failed: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Sign Up', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.eco, size: 44, color: Color(0xFFFFC107)),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _businessController,
                        decoration: const InputDecoration(labelText: 'Business name'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter business name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email required';
                          if (!v.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountryCode,
                              decoration: const InputDecoration(labelText: 'Code'),
                              isExpanded: true,
                              selectedItemBuilder: (context) {
                                return _countryCodes
                                    .map(
                                      (item) => Text(item['code'] ?? ''),
                                    )
                                    .toList();
                              },
                              items: _countryCodes
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item['code'],
                                      child: Text(
                                        '${item['name']} (${item['code']})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedCountryCode = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Phone'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password required';
                          final pattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$');
                          if (!pattern.hasMatch(v)) {
                            return 'Use at least 8 chars with letters and numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscure,
                        decoration: const InputDecoration(labelText: 'Confirm password'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirm password';
                          final pattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$');
                          if (!pattern.hasMatch(v)) {
                            return 'Use at least 8 chars with letters and numbers';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
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
                              : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text('Log In'),
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
