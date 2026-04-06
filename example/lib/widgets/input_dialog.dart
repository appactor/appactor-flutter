import 'package:flutter/material.dart';

Future<String?> showInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? defaultValue,
}) async {
  final controller = TextEditingController(text: defaultValue);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        autofocus: true,
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('OK')),
      ],
    ),
  );
}
