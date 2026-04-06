import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventLogTab extends StatelessWidget {
  const EventLogTab({
    super.key,
    required this.eventLog,
    required this.onClear,
  });

  final List<String> eventLog;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
          ),
          child: Row(
            children: [
              Icon(Icons.terminal, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Live Events', style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              Text('${eventLog.length}',
                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: eventLog.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note, size: 48, color: cs.outlineVariant),
                      const SizedBox(height: 8),
                      Text('No events yet',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: eventLog.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (_, i) => GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: eventLog[i]));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i.isEven ? cs.surfaceContainerLow : Colors.transparent,
                      ),
                      child: Text(
                        eventLog[i],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
