import 'package:flutter/material.dart';
import 'dart:async';
import '../services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  String? _gender; // dropdown selection
  final _confirmPassword = TextEditingController();

  Timer? _debounceEmail;
  Timer? _debounceUsername;
  bool _emailTaken = false;
  bool _usernameTaken = false;
  bool _checkingEmail = false;
  bool _checkingUsername = false;
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _address = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  final _service = UserService();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
  _confirmPassword.dispose();
    _contact.dispose();
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _service.registerUser(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        age: _age.text.trim(),
        gender: _gender ?? '',
        contactNumber: _contact.text.trim(),
        email: _email.text.trim(),
        username: _username.text.trim(),
        password: _password.text,
        address: _address.text.trim(),
      );
      // Auto-login after successful registration
      final loginResp = await _service.loginUser(_email.text.trim(), _password.text);
      // Merge with original registration details (login response lacks them)
      final merged = {
        ...loginResp,
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'age': _age.text.trim(),
        'gender': _gender ?? '',
        'contactNumber': _contact.text.trim(),
        'email': _email.text.trim(),
        'address': _address.text.trim(),
      };
      await _service.saveUserData(merged);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful. Logging you in...')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  void _onEmailChanged(String value) {
    _debounceEmail?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() { _emailTaken = false; });
      return;
    }
    _debounceEmail = Timer(const Duration(milliseconds: 600), () async {
      setState(() { _checkingEmail = true; });
      final taken = await _service.isEmailTaken(trimmed);
      if (mounted) {
        setState(() { _emailTaken = taken; _checkingEmail = false; });
      }
    });
  }

  void _onUsernameChanged(String value) {
    _debounceUsername?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() { _usernameTaken = false; });
      return;
    }
    _debounceUsername = Timer(const Duration(milliseconds: 600), () async {
      setState(() { _checkingUsername = true; });
      final taken = await _service.isUsernameTaken(trimmed);
      if (mounted) {
        setState(() { _usernameTaken = taken; _checkingUsername = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstName,
                      decoration: _dec('First Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastName,
                      decoration: _dec('Last Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _age,
                      decoration: _dec('Age', icon: Icons.numbers),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _dec('Gender'),
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (val) => setState(() => _gender = val),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contact,
                  decoration: _dec('Contact Number', icon: Icons.phone),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: _dec('Email', icon: Icons.email).copyWith(
                    suffixIcon: _checkingEmail
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_email.text.isEmpty
                            ? null
                            : (_emailTaken
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check_circle, color: Colors.green))),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          final emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                    if (!emailRegex.hasMatch(v)) return 'Invalid email';
                    if (_emailTaken) return 'Email already in use';
          return null;
                  },
                  onChanged: _onEmailChanged,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _username,
                  decoration: _dec('Username', icon: Icons.person).copyWith(
                    suffixIcon: _checkingUsername
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_username.text.isEmpty
                            ? null
                            : (_usernameTaken
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check_circle, color: Colors.green))),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (_usernameTaken) return 'Username taken';
                    return null;
                  },
                  onChanged: _onUsernameChanged,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: _dec('Password', icon: Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 5 ? 'Min 5 chars' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: _obscure,
                  decoration: _dec('Confirm Password', icon: Icons.lock_outline),
                  validator: (v) => v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: _dec('Address', icon: Icons.home),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sign Up'),
                  ),
                ),
                // Removed bottom status row; indicators are now suffix icons
              ],
            ),
          ),
        ),
      ),
    );
  }
}