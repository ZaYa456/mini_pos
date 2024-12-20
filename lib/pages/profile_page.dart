import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../session_management/session_getter.dart';

class ProfilePage extends StatefulWidget {
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
      'http://192.168.1.13/mini_pos/backend/updateUsername.php';
  final String changePasswordUrl =
      'http://192.168.1.13/mini_pos/backend/updatePassword.php';

  // Function to submit the username form
  Future<void> _changeUsername() async {
    if (_newUsernameController.text != _confirmUsernameController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm new username error')),
      );
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error ${response.statusCode}: Server Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Function to submit the password form
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm new password error')),
      );
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error ${response.statusCode}: Server Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Settings')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username change form
              Text('Change Username', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _currentUsernameController,
                decoration: InputDecoration(labelText: 'Current Username'),
              ),
              TextField(
                controller: _newUsernameController,
                decoration: InputDecoration(labelText: 'New Username'),
              ),
              TextField(
                controller: _confirmUsernameController,
                decoration: InputDecoration(labelText: 'Confirm New Username'),
              ),
              TextField(
                controller: _passwordForUsernameController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _changeUsername,
                child: const Text('Update Username'),
              ),
              Divider(),

              // Password change form
              Text('Change Password', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _usernameForPasswordController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
              SizedBox(height: 10),
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
