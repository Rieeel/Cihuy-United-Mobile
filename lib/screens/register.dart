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
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24.0),
                  Listener(
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
                      scale: _pressed ? 0.94 : 1.0,
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
                                      content: Text('Passwords do not match.'),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Successfully registered!',
                                        ),
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
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
                                      String bodyText = 'Registration failed.';
                                      if (data != null) {
                                        if (data['message'] != null) {
                                          bodyText = data['message'].toString();
                                        } else if (data['errors'] is Map) {
                                          final errs = (data['errors'] as Map)
                                              .entries
                                              .map(
                                                (e) => '${e.key}: ${e.value}',
                                              )
                                              .join(', ');
                                          if (errs.isNotEmpty) bodyText = errs;
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
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          elevation: _pressed ? 2 : 6,
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
                              : const Text('Register', key: ValueKey('label')),
                        ),
                      ),
                    ),
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
