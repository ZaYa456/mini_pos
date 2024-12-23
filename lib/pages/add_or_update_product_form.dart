import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';

import '../session_management/session_getter.dart';
import '../utils/display_modal.dart';

class AddOrUpdateProductForm extends StatefulWidget {
  const AddOrUpdateProductForm({super.key});

  @override
  _AddOrUpdateProductFormState createState() => _AddOrUpdateProductFormState();
}

class _AddOrUpdateProductFormState extends State<AddOrUpdateProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  List<dynamic> _categories = [];
  String? _selectedCategory; // Default Category
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories when the widget is initialized
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    var result = await BarcodeScanner.scan();
    setState(() {
      _barcodeController.text = result.rawContent;
    });
  }

  // Fetch categories from the database via PHP API
  Future<void> fetchCategories() async {
    try {
      var url =
          Uri.parse('http://192.168.1.11/mini_pos/backend/getCategories.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _categories = data['categories'];
          });
        } else {
          displayModal(context,
              title: 'Error.',
              message: data['message'],
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

  // Function to send data to the PHP file
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String sessionId = await getSessionId() ?? '';

      // Construct the data to be sent to the PHP backend
      var data = {
        'sessionId': sessionId,
        'name': _nameController.text,
        'price': _priceController.text,
        'barcode': _barcodeController.text,
        'categoryID': _selectedCategory,
      };

      // Set the PHP endpoint
      var url = Uri.parse(
          'http://192.168.1.11/mini_pos/backend/addOrUpdateProduct.php');

      try {
        setState(() {
          _isSubmitting = true;
        });

        // Send the POST request with the form data
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(data), // Convert data to JSON
        );

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
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the product\'s name'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  items: _categories.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category['id'].toString(),
                      child: Text(category['name']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                      labelText: 'Barcode',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                      )),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the product\'s barcode'
                      : null,
                ),
                const SizedBox(height: 20),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: const Text('Add Product'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}