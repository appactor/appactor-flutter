import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied: $label'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: mono ? 'monospace' : null,
                    fontSize: mono ? 12 : null,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
