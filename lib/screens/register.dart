import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cihuy_united/screens/login.dart';

// Base URL inlined (tutorial style). Adjust if server host/port changes.
const String _baseUrl = 'http://localhost:8000';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _submitting = false;
  bool _pressed = false; // for press animation

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      backgroundColor: const Color(0xFF1A252F), // Dark background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            color: const Color(0xFF2C3E50), // Dark blue card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Join Us',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB), // Light blue
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your Cihuy United account',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 32.0),
                  // Username field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Choose a username',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: const Color(0xFF34495E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: const Color(0xFF34495E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Confirm Password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confirm Password',
                        style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: const Color(0xFF34495E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28.0),
                  // Create Account button
                  SizedBox(
                    width: double.infinity,
                    child: Listener(
                      onPointerDown: (_) {
                        if (_submitting) return;
                        setState(() => _pressed = true);
                      },
                      onPointerUp: (_) {
                        if (_pressed) setState(() => _pressed = false);
                      },
                      onPointerCancel: (_) {
                        if (_pressed) setState(() => _pressed = false);
                      },
                      child: AnimatedScale(
                        scale: _pressed ? 0.96 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: ElevatedButton(
                          onPressed: _submitting
                              ? null
                              : () async {
                                  final username = _usernameController.text
                                      .trim();
                                  final password1 = _passwordController.text;
                                  final password2 =
                                      _confirmPasswordController.text;

                                  if (username.isEmpty ||
                                      password1.isEmpty ||
                                      password2.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill all the fields.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (password1 != password2) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Passwords do not match.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _submitting = true);
                                  try {
                                    final response = await request.postJson(
                                      "$_baseUrl/auth/register/",
                                      jsonEncode({
                                        'username': username,
                                        'password': password1,
                                        'password1': password1,
                                        'password2': password2,
                                      }),
                                    );
                                    if (!mounted) return;

                                    final bool ok =
                                        response is Map &&
                                        ((response['status'] == 'success') ||
                                            (response['status'] == true) ||
                                            (response['success'] == true));
                                    if (ok) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Successfully registered!',
                                          ),
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                      return;
                                    }

                                    // Fallback: form-encoded POST
                                    final uri = Uri.parse(
                                      "$_baseUrl/auth/register/",
                                    );
                                    final res = await http.post(
                                      uri,
                                      headers: {
                                        'Content-Type':
                                            'application/x-www-form-urlencoded',
                                      },
                                      body: {
                                        'username': username,
                                        'password': password1,
                                        'password1': password1,
                                        'password2': password2,
                                      },
                                    );
                                    if (!mounted) return;

                                    if (res.statusCode >= 200 &&
                                        res.statusCode < 300) {
                                      Map<String, dynamic>? data;
                                      try {
                                        data =
                                            jsonDecode(res.body)
                                                as Map<String, dynamic>;
                                      } catch (_) {
                                        data = null;
                                      }

                                      final bool ok2 =
                                          data != null &&
                                          ((data['status'] == 'success') ||
                                              (data['status'] == true) ||
                                              (data['success'] == true));
                                      if (ok2) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Successfully registered!',
                                            ),
                                          ),
                                        );
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(),
                                          ),
                                        );
                                      } else {
                                        String bodyText =
                                            'Registration failed.';
                                        if (data != null) {
                                          if (data['message'] != null) {
                                            bodyText = data['message']
                                                .toString();
                                          } else if (data['errors'] is Map) {
                                            final errs = (data['errors'] as Map)
                                                .entries
                                                .map(
                                                  (e) => '${e.key}: ${e.value}',
                                                )
                                                .join(', ');
                                            if (errs.isNotEmpty)
                                              bodyText = errs;
                                          } else {
                                            bodyText = jsonEncode(data);
                                          }
                                        } else if (res.body.isNotEmpty) {
                                          bodyText = res.body;
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(bodyText)),
                                        );
                                      }
                                    } else {
                                      final errText =
                                          'HTTP ${res.statusCode}: ${res.body}';
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(errText)),
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    // Network/JSON error — try form-encoded fallback
                                    try {
                                      final uri = Uri.parse(
                                        "$_baseUrl/auth/register/",
                                      );
                                      final res = await http.post(
                                        uri,
                                        headers: {
                                          'Content-Type':
                                              'application/x-www-form-urlencoded',
                                        },
                                        body: {
                                          'username': username,
                                          'password': password1,
                                          'password1': password1,
                                          'password2': password2,
                                        },
                                      );
                                      if (!mounted) return;

                                      if (res.statusCode >= 200 &&
                                          res.statusCode < 300) {
                                        Map<String, dynamic>? data;
                                        try {
                                          data =
                                              jsonDecode(res.body)
                                                  as Map<String, dynamic>;
                                        } catch (_) {
                                          data = null;
                                        }

                                        final bool ok2 =
                                            data != null &&
                                            ((data['status'] == 'success') ||
                                                (data['status'] == true) ||
                                                (data['success'] == true));
                                        if (ok2) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Successfully registered!',
                                              ),
                                            ),
                                          );
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage(),
                                            ),
                                          );
                                        } else {
                                          final bodyText = res.body.isNotEmpty
                                              ? res.body
                                              : 'Registration failed.';
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text(bodyText)),
                                          );
                                        }
                                      } else {
                                        final errText =
                                            'HTTP ${res.statusCode}: ${res.body}';
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(errText)),
                                        );
                                      }
                                    } catch (e2) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${e.toString()}\nFallback: ${e2.toString()}',
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted)
                                      setState(() => _submitting = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: _pressed ? 2 : 3,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: _submitting
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    key: ValueKey('label'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Sign In link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF3498DB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
