import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';

import '../session_management/session_getter.dart';
import '../utils/display_modal.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String _barcode = '';
  List<dynamic> _categories = [];
  String? _selectedCategory; // Default Category
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories when the widget is initialized
  }

  Future<void> _scanBarcode() async {
    var result = await BarcodeScanner.scan();
    setState(() {
      _barcode = result.rawContent;
    });
  }

  // Fetch categories from the database via PHP API
  Future<void> fetchCategories() async {
    try {
      var url =
          Uri.parse('http://192.168.1.4/mini_pos/backend/getCategories.php');
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
      _formKey.currentState!.save(); // Save the form inputs

      String sessionId = await getSessionId() ?? '';

      // Construct the data to be sent to the PHP backend
      var data = {
        'sessionId': sessionId,
        'name': _name,
        'price': _price.toString(),
        'barcode': _barcode,
        'categoryID': _selectedCategory,
      };

      // Set the PHP endpoint
      var url =
          Uri.parse('http://192.168.1.4/mini_pos/backend/addProduct.php');

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onSaved: (value) => _name = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.parse(value!),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category', // Optional, can also be a hint
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
              const SizedBox(height: 20),
              Text('Barcode: $_barcode'),
              ElevatedButton(
                onPressed: _scanBarcode,
                child: const Text('Scan Barcode'),
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Add Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
