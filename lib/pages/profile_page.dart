import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../session_management/session_getter.dart';
import '../utils/display_modal.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for username form fields
  final _currentUsernameController = TextEditingController();
  final _newUsernameController = TextEditingController();
  final _confirmUsernameController = TextEditingController();
  final _passwordForUsernameController = TextEditingController();

  // Controllers for password form fields
  final _usernameForPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  // URL endpoints for PHP files
  final String changeUsernameUrl =
      'http://192.168.1.11/mini_pos/backend/updateUsername.php';
  final String changePasswordUrl =
      'http://192.168.1.11/mini_pos/backend/updatePassword.php';

  // Function to submit the username form
  Future<void> _changeUsername() async {
    if (_newUsernameController.text != _confirmUsernameController.text) {
      displayModal(context,
          title: 'Error.',
          message: 'The username\'s confirmation is not identical.',
          backgroundColor: Colors.red);
      return;
    }

    try {
      String sessionId = await getSessionId() ?? '';
      final response = await http.post(Uri.parse(changeUsernameUrl),
          body: json.encode({
            'sessionId': sessionId,
            'currentUsername': _currentUsernameController.text,
            'newUsername': _newUsernameController.text,
            'password': _passwordForUsernameController.text,
          }));

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        // Handle successful submission
        if (result['success'] == true) {
          displayModal(context,
              title: 'Success.',
              message: result['message'],
              backgroundColor: Colors.green);
        } else {
          displayModal(context,
              title: 'Error.',
              message: result['message'],
              backgroundColor: Colors.red);
        }
      } else {
        displayModal(context,
            title: 'Server Error: ${response.statusCode}',
            message: response.body,
            backgroundColor: Colors.red);
      }
    } catch (e) {
      displayModal(context,
          title: 'Error.', message: '$e', backgroundColor: Colors.red);
    }
  }

  // Function to submit the password form
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      displayModal(context,
          title: 'Error.',
          message: 'The password\'s confirmation is not identical.',
          backgroundColor: Colors.red);
      return;
    }

    try {
      String sessionId = await getSessionId() ?? '';
      final response = await http.post(Uri.parse(changePasswordUrl),
          body: json.encode({
            'sessionId': sessionId,
            'username': _usernameForPasswordController.text,
            'currentPassword': _currentPasswordController.text,
            'newPassword': _newPasswordController.text,
          }));

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        // Handle successful submission
        if (result['success'] == true) {
          displayModal(context,
              title: 'Success.',
              message: result['message'],
              backgroundColor: Colors.green);
        } else {
          displayModal(context,
              title: 'Error.',
              message: result['message'],
              backgroundColor: Colors.red);
        }
      } else {
        displayModal(context,
            title: 'Server Error: ${response.statusCode}',
            message: response.body,
            backgroundColor: Colors.red);
      }
    } catch (e) {
      displayModal(context,
          title: 'Error.', message: '$e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username change form
              const Text('Change Username', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _currentUsernameController,
                decoration: const InputDecoration(labelText: 'Current Username'),
              ),
              TextField(
                controller: _newUsernameController,
                decoration: const InputDecoration(labelText: 'New Username'),
              ),
              TextField(
                controller: _confirmUsernameController,
                decoration: const InputDecoration(labelText: 'Confirm New Username'),
              ),
              TextField(
                controller: _passwordForUsernameController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _changeUsername,
                child: const Text('Update Username'),
              ),
              const Divider(),

              // Password change form
              const Text('Change Password', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _usernameForPasswordController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmNewPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _currentUsernameController.dispose();
    _newUsernameController.dispose();
    _confirmUsernameController.dispose();
    _passwordForUsernameController.dispose();
    _usernameForPasswordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}
