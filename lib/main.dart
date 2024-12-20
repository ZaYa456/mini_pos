import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mini_pos/utils/display_modal.dart';
import 'dart:convert'; // For JSON encoding and decoding
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> login() async {
    const url = 'http://192.168.1.13/mini_pos/backend/login.php';
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _username,
          "password": _password,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          // Save session ID to SharedPreferences
          if (result.containsKey('sessionId')) {
            String sessionId = result['sessionId'];
            await saveSessionId(sessionId);
            // Navigate to HomePage on successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            // Display error message
            displayModal(context,
                title: 'Error.',
                message: result['message'],
                backgroundColor: Colors.red);
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content: Text('Error'),
            // ));
          }
        } else {
          // Display error message
          displayModal(context,
              title: 'Error.',
              message: result['message'],
              backgroundColor: Colors.red);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text(result['message']),
          // ));
        }
      } else {
        displayModal(context,
            title: 'Server error.',
            message: 'Please try again later.',
            backgroundColor: Colors.red);
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Server error. Please try again later.'),
        // ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveSessionId(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionId', sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Login'),
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
                  onChanged: (value) {
                    _username = value;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
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
                  onChanged: (value) {
                    _password = value;
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            login(); // Call login function when the form is validated
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
