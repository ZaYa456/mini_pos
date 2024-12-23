import 'package:flutter/material.dart';

Future<void> displayModal(
  BuildContext context, {
  required String title,
  required String message,
  Color backgroundColor = Colors.white,
  bool confirmation = false,
  VoidCallback? confirmationFunction,
}) async {
  showDialog(
    context: context,
    barrierDismissible:
        true, // Allows the user to dismiss the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        actions: confirmation
            ? [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('No', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    if (confirmationFunction != null) {
                      confirmationFunction(); // Execute the confirmation function
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Yes'),
                ),
              ]
            : [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child:
                      const Text('Close', style: TextStyle(color: Colors.grey)),
                ),
              ],
      );
    },
  );
}
