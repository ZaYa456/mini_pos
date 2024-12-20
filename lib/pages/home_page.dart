import 'package:flutter/material.dart';
import 'package:mini_pos/pages/products_page.dart';
import 'package:mini_pos/pages/profile_page.dart';
import 'package:mini_pos/pages/checkout_page.dart';
import 'add_product_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages to navigate between
  static final List<Widget> _pages = <Widget>[
    const ProductsPage(),
    const CheckoutPage(),
    Center(child: Text('Sales Page', style: TextStyle(fontSize: 24))),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini POS App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddProductForm page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductForm()),
              );
            },
            tooltip: 'Add Product',
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
