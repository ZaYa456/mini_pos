import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../session_management/session_getter.dart';
import '../utils/display_modal.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final MobileScannerController controller = MobileScannerController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, dynamic>> scannedProducts = [];
  bool _isCheckingOut = false;
  bool isScanning = true;
  double total = 0.0;

  @override
  void initState() {
    super.initState();

    // Start listening to the barcode stream directly from the controller
    controller.barcodes.listen((barcodeCapture) {
      if (isScanning && barcodeCapture.barcodes.isNotEmpty) {
        final barcode = barcodeCapture.barcodes.first;
        if (barcode.rawValue != null) {
          String barcodeValue = barcode.rawValue!;
          setState(() => isScanning = false); // Pause scanning
          fetchProductInfo(barcodeValue);
        }
      }
    });
  }

  Future<void> fetchProductInfo(String barcode) async {
    try {
      String sessionId = await getSessionId() ?? '';
      final response = await http.post(
        Uri.parse('http://192.168.1.4/mini_pos/backend/getProducts.php'),
        body: json.encode({'sessionId': sessionId, 'barcode': barcode}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            // Check if the product already exists in the list
            final existingProductIndex = scannedProducts.indexWhere(
              (item) => item['id'] == data['product']['id'],
            );

            if (existingProductIndex != -1) {
              // Update the quantity if the product already exists
              scannedProducts[existingProductIndex]['quantity'] =
                  (scannedProducts[existingProductIndex]['quantity'] ?? 1) + 1;

              total += double.parse(
                  scannedProducts[existingProductIndex]['price'].toString());

              // Remove the item and reinsert it to update the AnimatedList
              _listKey.currentState?.removeItem(
                existingProductIndex,
                (context, animation) =>
                    _buildProductItem(context, existingProductIndex, animation),
                duration: const Duration(milliseconds: 300),
              );

              _listKey.currentState?.insertItem(existingProductIndex);
            } else {
              scannedProducts.add(data['product']);
              total += double.parse(data['product']['price'].toString());

              // Notify the AnimatedList of the new item
              _listKey.currentState?.insertItem(scannedProducts.length - 1);
            }
          });

          // Trigger the flash blink animation
          blinkFlash();
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

      // Add a short delay before resuming scanning
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isScanning = true); // Resume scanning after delay
    } catch (e) {
      displayModal(context,
          title: 'Error.', message: '$e', backgroundColor: Colors.red);
    }
  }

  void blinkFlash() async {
    // Check the current flash state
    bool isFlashOn = controller.value.torchState == TorchState.on;

    // Toggle flash off if it’s on, or on if it’s off
    await controller.toggleTorch();
    await Future.delayed(
        const Duration(milliseconds: 200)); // Adjust delay as needed

    // Toggle flash back to its original state
    if (isFlashOn != (controller.value.torchState == TorchState.on)) {
      await controller.toggleTorch();
    }
  }

  void removeProduct(int index) {
    final removedProduct = scannedProducts[index];
    setState(() {
      total -= double.parse(removedProduct['price'].toString());
      scannedProducts.removeAt(index);
    });
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedProduct, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  void removeAllProducts() {
    // Make a copy of the scannedProducts list
    final List<Map<String, dynamic>> productsToRemove =
        List.from(scannedProducts);

    // Remove each item one by one with animation
    for (int i = productsToRemove.length - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            _buildRemovedItem(productsToRemove[i], animation),
        duration: const Duration(milliseconds: 300),
      );
    }

    // Clear the list and reset the total after the animations
    setState(() {
      scannedProducts.clear();
      total = 0.0;
    });
  }

  Widget _buildRemovedItem(
      Map<String, dynamic> product, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(product['products_name']),
        subtitle: Text(
            "Price: \$${product['price']} - Category: ${product['category_name']}"),
      ),
    );
  }

  Widget _buildProductItem(
      BuildContext context, int index, Animation<double> animation) {
    final product = scannedProducts[index];
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(product['products_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Price: \$${product['price']} - Category: ${product['category_name']}"),
            Row(
              children: [
                Text(
                  "Quantity: ${product['quantity'] ?? 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      product['quantity'] = (product['quantity'] ?? 1) + 1;
                      total += double.parse(product['price'].toString());
                    });
                    // Optionally refresh AnimatedList for smooth updates
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    if ((product['quantity'] ?? 1) > 1) {
                      setState(() {
                        product['quantity'] = (product['quantity'] ?? 1) - 1;
                        total -= double.parse(product['price'].toString());
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => removeProduct(index),
        ),
      ),
    );
  }

  Future<void> handleCheckout() async {
    try {
      setState(() {
        _isCheckingOut = true;
      });
      String sessionId = await getSessionId() ?? '';
      final response = await http.post(
        Uri.parse('http://192.168.1.4/mini_pos/backend/checkout.php'),
        body:
            json.encode({'sessionId': sessionId, 'products': scannedProducts}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Uncomment the following statement if you prefer to clear the products list on successful checkout
          // removeAllProducts();
          displayModal(context,
              title: 'Success.',
              message: data['message'],
              backgroundColor: Colors.green);
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
        _isCheckingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        actions: [
          _isCheckingOut
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator()),
                )
              : IconButton(
                  icon: const Icon(Icons.check_circle),
                  onPressed: scannedProducts.isNotEmpty ? handleCheckout : null,
                  color:
                      scannedProducts.isNotEmpty ? Colors.green : Colors.grey,
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                ),
                // Optional overlay for the scanning rectangle
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Delete All button
                  ElevatedButton.icon(
                    onPressed:
                        scannedProducts.isNotEmpty ? removeAllProducts : null,
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete All"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: scannedProducts.length,
              itemBuilder: (context, index, animation) =>
                  _buildProductItem(context, index, animation),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
