import 'dart:io';

import 'package:flutter/material.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

import '../../widgets/section_card.dart';
import '../../widgets/info_row.dart';
import '../../widgets/input_dialog.dart';
import '../../widgets/empty_state_text.dart';

class ConfigTab extends StatelessWidget {
  const ConfigTab({
    super.key,
    required this.remoteConfigs,
    required this.experiment,
    this.asaDiagnostics,
    required this.onRefreshConfigs,
    required this.onFetchExperiment,
    required this.onSetLogLevel,
    this.onRefreshAsa,
  });

  final AppActorRemoteConfigs? remoteConfigs;
  final AppActorExperimentAssignment? experiment;
  final AppActorAsaDiagnostics? asaDiagnostics;
  final VoidCallback onRefreshConfigs;
  final void Function(String key) onFetchExperiment;
  final void Function(AppActorLogLevel level) onSetLogLevel;
  final VoidCallback? onRefreshAsa;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRemoteConfigs(context),
        const SizedBox(height: 12),
        _buildExperiment(context),
        const SizedBox(height: 12),
        _buildLogLevel(context),
        if (Platform.isIOS) ...[
          const SizedBox(height: 12),
          _buildAsaDiagnostics(context),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRemoteConfigs(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final items = remoteConfigs?.items ?? [];

    return SectionCard(
      title: 'Remote Configs (${items.length})',
      trailing: IconButton(
        icon: const Icon(Icons.refresh, size: 20),
        onPressed: onRefreshConfigs,
        tooltip: 'Refresh configs',
        visualDensity: VisualDensity.compact,
      ),
      children: [
        if (items.isEmpty)
          const EmptyStateText('No remote configs'),
        for (final item in items) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: cs.surfaceContainerLow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.key, style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: cs.secondaryContainer,
                      ),
                      child: Text(item.valueType.wireValue,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: cs.onSecondaryContainer,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${item.value}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExperiment(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SectionCard(
      title: 'Experiment Assignment',
      trailing: IconButton(
        icon: const Icon(Icons.science, size: 20),
        onPressed: () async {
          final key = await showInputDialog(
            context,
            title: 'Fetch Experiment',
            label: 'Experiment Key',
            defaultValue: 'pricing_test',
          );
          if (key != null && key.isNotEmpty) {
            onFetchExperiment(key);
          }
        },
        tooltip: 'Fetch experiment',
        visualDensity: VisualDensity.compact,
      ),
      children: [
        if (experiment == null) ...[
          const EmptyStateText('No experiment assignment'),
        ] else ...[
          InfoRow('Experiment', experiment!.experimentKey, mono: true),
          InfoRow('Variant', experiment!.variantKey, mono: true),
          InfoRow('Value Type', experiment!.valueType.wireValue),
          InfoRow('Assigned At', experiment!.assignedAt),
          if (experiment!.payload != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: cs.surfaceContainerLow,
              ),
              child: Text('Payload: ${experiment!.payload}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  )),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildLogLevel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Log Level',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in AppActorLogLevel.values)
              ActionChip(
                label: Text(level.wireValue),
                backgroundColor: cs.surfaceContainerLow,
                side: BorderSide(color: cs.outlineVariant),
                onPressed: () => onSetLogLevel(level),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAsaDiagnostics(BuildContext context) {
    final asa = asaDiagnostics;
    return SectionCard(
      title: 'ASA Diagnostics',
      trailing: onRefreshAsa != null
          ? IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: onRefreshAsa,
              tooltip: 'Refresh ASA',
              visualDensity: VisualDensity.compact,
            )
          : null,
      children: [
        if (asa == null)
          const EmptyStateText('ASA not configured or no data')
        else ...[
          InfoRow('Attribution Done', asa.attributionCompleted ? 'Yes' : 'No'),
          InfoRow('Pending Events', '${asa.pendingPurchaseEventCount}'),
          InfoRow('Auto Track', asa.autoTrackPurchases ? 'Yes' : 'No'),
          InfoRow('Sandbox', asa.trackInSandbox ? 'Yes' : 'No'),
          InfoRow('Debug', asa.debugMode ? 'Yes' : 'No'),
        ],
      ],
    );
  }
}
