import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mini_pos/session_management/session_getter.dart';

import '../utils/display_modal.dart';
import 'sale_details_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List _sales = [];
  DateTime? _selectedDatetime = DateTime.now();
  String _selectedSort = 'datetime';
  bool _isLoadingSales = false;

  ScrollController _scrollController = ScrollController();
  GlobalKey _filterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchSales(
      datetime: _selectedDatetime?.toIso8601String(),
      sort: _selectedSort,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchSales({String? datetime, String? sort = 'datetime'}) async {
    try {
      setState(() {
        _isLoadingSales = true;
      });
      String sessionId = await getSessionId() ?? '';
      final response = await http.post(
        Uri.parse('http://192.168.1.4/mini_pos/backend/getSales.php'),
        body: jsonEncode({
          'sessionId': sessionId,
          'datetime': datetime ?? '',
          'sort': sort,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _sales = data['sales'];
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
    } finally {
      setState(() {
        _isLoadingSales = false;
      });
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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDatetime) {
      setState(() {
        _selectedDatetime = picked;
      });
      fetchSales(
        datetime: _selectedDatetime?.toIso8601String(),
        sort: _selectedSort,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
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
                title: const Text('Filter Sales'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _selectDateTime(context),
                            child: Text(_selectedDatetime == null
                                ? 'Select Datetime'
                                : 'Selected: ${_selectedDatetime!.toLocal().toString().split(' ')[0]}'),
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
                              fetchSales(
                                datetime: _selectedDatetime?.toIso8601String(),
                                sort: newValue,
                              );
                            },
                            items: ['datetime', 'total_amount'].map((sort) {
                              return DropdownMenuItem(
                                value: sort,
                                child: Text(
                                    'Sort by ${sort.replaceAll('_', ' ')}'),
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
        body: _isLoadingSales
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _sales.isEmpty
                ? const Center(
                    child: Text('No sales found.'),
                  )
                : ListView.builder(
                    itemCount: _sales.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        splashColor: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SaleDetailsPage(
                                saleId: _sales[index]['id'],
                                totalAmount:
                                    double.parse(_sales[index]['total_amount']),
                                date: _sales[index]['date'],
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(_sales[index]['id'].toString()),
                          subtitle: Text(
                              'Total: \$${_sales[index]['total_amount']} - Date: ${_sales[index]['date']}'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
