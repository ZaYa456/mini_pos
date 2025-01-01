import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'dart:convert';
import 'products_page.dart';
import 'profile_page.dart';
import 'checkout_page.dart';
import 'sales_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session_management/session_getter.dart';
import '../utils/display_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggingOut = false;
  int _selectedIndex = 0;

  // Pages to navigate between
  static final List<Widget> _pages = <Widget>[
    const ProductsPage(),
    const CheckoutPage(),
    const SalesPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout() async {
    setState(() {
      _isLoggingOut = true;
    });
    try {
      String sessionId = await getSessionId() ?? '';
      if (sessionId.isEmpty) {
        if (mounted) {
          displayModal(context,
              title: 'Error.',
              message: 'Session ID is empty.',
              backgroundColor: Colors.red);
        }
        return;
      }
      const url = 'http://192.168.1.6/mini_pos/backend/logout.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "sessionId": sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          // Clear session ID from the SharedPreferences
          await clearSessionId(sessionId);
          // Navigate to HomePage on successful login
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
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
        _isLoggingOut = false;
      });
    }
  }

  Future<void> clearSessionId(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini POS App'),
        actions: [
          _isLoggingOut
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator()),
                )
              : IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    displayModal(context,
                        title: 'Log Out',
                        message: 'Are you sure you want to log out?',
                        foregroundColor: Colors.black,
                        confirmation: true,
                        confirmationFunction: logout);
                  },
                ),
        ],
      ),
      body: _pages[_selectedIndex], // Displays the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Checkout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
