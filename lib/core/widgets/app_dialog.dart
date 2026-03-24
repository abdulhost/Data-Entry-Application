// lib/core/widgets/app_dialog.dart

import 'package:flutter/material.dart';

class AppDialog {
  static void show(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }
}