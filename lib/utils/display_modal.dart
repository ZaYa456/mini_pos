import 'package:flutter/material.dart';

Future<void> displayModal(
  BuildContext context, {
  required String title,
  required String message,
  Color backgroundColor = Colors.white,
  Color foregroundColor = Colors.white,
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
            style:
                TextStyle(color: foregroundColor, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: foregroundColor)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        actions: confirmation
            ? [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('No', style: TextStyle(color: foregroundColor)),
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
                  child: Text(
                    'Yes',
                    style: TextStyle(color: backgroundColor),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child:
                      Text('Close', style: TextStyle(color: foregroundColor)),
                ),
              ],
      );
    },
  );
}
