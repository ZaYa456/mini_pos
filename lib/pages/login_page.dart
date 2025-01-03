import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mini_pos/utils/ip_address.dart';
import 'dart:convert'; // For json.decode
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/display_modal.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController =
      TextEditingController(text: 'zak');
  final TextEditingController _passwordController =
      TextEditingController(text: 'zak');
  bool _isLoggingIn = false;

  Future<void> login() async {
    setState(() {
      _isLoggingIn = true;
    });
    try {
      const url = 'http://$ipAddress/mini_pos/backend/login.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] && result.containsKey('sessionId')) {
          // Save session ID to SharedPreferences
          String sessionId = result['sessionId'];
          await saveSessionId(sessionId);
          // Navigate to HomePage on successful login
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          if (mounted) {
            displayModal(context,
                title: 'Error.',
                message: result['message'],
                backgroundColor: Colors.red);
          }
        }
      } else {
        if (mounted) {
          displayModal(context,
              title: 'Server Error: ${response.statusCode}',
              message: response.body,
              backgroundColor: Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        displayModal(context,
            title: 'Error.', message: '$e', backgroundColor: Colors.red);
      }
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  Future<void> saveSessionId(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionId', sessionId);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoggingIn
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            login();
                          }
                        },
                        child: const Text('Login'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
