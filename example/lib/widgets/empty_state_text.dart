import 'package:flutter/material.dart';

class EmptyStateText extends StatelessWidget {
  const EmptyStateText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }
}
