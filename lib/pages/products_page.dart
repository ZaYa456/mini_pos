import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mini_pos/session_management/session_getter.dart';

import '../utils/display_modal.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List _products = [];
  List<dynamic> _categories = [
    {"id": 0, "name": "All Categories"}
  ];
  String? _selectedCategory = "0";
  String _selectedSort = 'products_name';

  ScrollController _scrollController = ScrollController();
  GlobalKey _filterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchProducts(
      {String? search = '',
      String? categoryID = '0',
      String? sort = 'products_name'}) async {
    try {
      String sessionId = await getSessionId() ?? '';
      final response = await http.post(
        Uri.parse('http://192.168.1.4/mini_pos/backend/getProducts.php'),
        body: jsonEncode({
          'sessionId': sessionId,
          'search': search,
          'categoryID': categoryID == '0' ? '0' : categoryID,
          'sort': sort,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _products = data['products'];
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

  Future<void> fetchCategories() async {
    try {
      var url =
          Uri.parse('http://192.168.1.4/mini_pos/backend/getCategories.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _categories.addAll(data['categories'].map((category) =>
                {"id": category['id'], "name": category['name']}));
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

  // Function to scroll to the filter section
  void scrollToFilter() {
    final RenderBox renderBox =
        _filterKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero).dy;

    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: scrollToFilter, // Scroll to filter section
          ),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: ExpansionTile(
                key: _filterKey, // Key to locate the filter position
                title: const Text('Filter Products'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      onChanged: (value) {
                        fetchProducts(
                            search: value,
                            categoryID: _selectedCategory,
                            sort: _selectedSort);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search by name...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                              fetchProducts(
                                  search: '',
                                  categoryID: newValue,
                                  sort: _selectedSort);
                            },
                            items: _categories
                                .map<DropdownMenuItem<String>>((category) {
                              return DropdownMenuItem<String>(
                                value: category['id'].toString(),
                                child: Text(category['name']),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            isExpanded: true,
                            iconEnabledColor: Colors.black,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedSort,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedSort = newValue!;
                              });
                              fetchProducts(
                                  search: '',
                                  categoryID: _selectedCategory,
                                  sort: newValue);
                            },
                            items: ['name', 'price'].map((sort) {
                              return DropdownMenuItem(
                                value: 'products_$sort',
                                child: Text('Sort by $sort'),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            isExpanded: true,
                            iconEnabledColor: Colors.black,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: _products.isEmpty
            ? const Center(
                child: Text('No products found.'),
              )
            : ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_products[index]['products_name']),
                    subtitle: Text(
                        'Price: \$${_products[index]['price']} - Category: ${_products[index]['category_name']}'),
                  );
                },
              ),
      ),
    );
  }
}
