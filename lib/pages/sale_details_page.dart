import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../session_management/session_getter.dart';
import '../utils/display_modal.dart';

class SaleDetailsPage extends StatefulWidget {
  final int saleId;
  final double totalAmount;
  final String date;

  const SaleDetailsPage(
      {super.key,
      required this.saleId,
      required this.totalAmount,
      required this.date});

  @override
  _SaleDetailsPageState createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  List<Map<String, dynamic>>? _saleDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSaleDetails();
  }

  Future<void> fetchSaleDetails() async {
    try {
      String sessionId = await getSessionId() ?? '';
      final response = await http.post(
        Uri.parse('http://192.168.1.4/mini_pos/backend/getSales.php'),
        body: jsonEncode({'sessionId': sessionId, 'saleID': widget.saleId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _saleDetails = List<Map<String, dynamic>>.from(data['sale']);
            _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _saleDetails == null
              ? const Center(child: Text('No details available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sale ID: ${widget.saleId}',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8.0),
                      Text('Date: ${widget.date}',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8.0),
                      Text('Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(height: 20.0),
                      Text('Items:',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _saleDetails!.length,
                          itemBuilder: (context, index) {
                            final item = _saleDetails![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(item['product_name']),
                                subtitle: Text(
                                    'Price: \$${item['price']} - Quantity: ${item['quantity']}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
