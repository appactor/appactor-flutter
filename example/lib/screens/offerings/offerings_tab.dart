import 'package:flutter/material.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

import '../../widgets/section_card.dart';
import '../../widgets/info_row.dart';
import '../../widgets/package_card.dart';
import '../../widgets/empty_state_text.dart';

class OfferingsTab extends StatelessWidget {
  const OfferingsTab({
    super.key,
    required this.offerings,
    required this.onPurchasePackage,
    required this.onRefresh,
  });

  final AppActorOfferings? offerings;
  final void Function(AppActorPackage package) onPurchasePackage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (offerings == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyStateText('No offerings loaded'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Fetch Offerings'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (offerings!.current != null) ...[
          _buildCurrentOffering(context),
          const SizedBox(height: 12),
        ],
        for (final entry in offerings!.all.entries.where(
            (e) => e.value.id != offerings!.current?.id)) ...[
          _buildOffering(context, entry.value, isCurrent: false),
          const SizedBox(height: 12),
        ],
        if (offerings!.productEntitlements.isNotEmpty) ...[
          _buildProductEntitlements(context),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCurrentOffering(BuildContext context) {
    return _buildOffering(context, offerings!.current!, isCurrent: true);
  }

  Widget _buildOffering(BuildContext context, AppActorOffering offering,
      {required bool isCurrent}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SectionCard(
      title: isCurrent ? 'Current Offering' : offering.id,
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: cs.primaryContainer,
              ),
              child: Text('ACTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimaryContainer,
                  )),
            )
          : null,
      children: [
        InfoRow('ID', offering.id, mono: true),
        InfoRow('Display Name', offering.displayName),
        if (offering.lookupKey != null)
          InfoRow('Lookup Key', offering.lookupKey!),
        if (offering.metadata != null && offering.metadata!.isNotEmpty)
          InfoRow('Metadata', offering.metadata!.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ')),
        const SizedBox(height: 8),
        Text('${offering.packages.length} Packages',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 4),
        for (final pkg in offering.packages)
          PackageCard(
            package: pkg,
            onPurchase: () => onPurchasePackage(pkg),
          ),
      ],
    );
  }

  Widget _buildProductEntitlements(BuildContext context) {
    return SectionCard(
      title: 'Product Entitlement Mapping',
      children: [
        for (final entry in offerings!.productEntitlements.entries)
          InfoRow(entry.key, entry.value.join(', '), mono: true),
        if (offerings!.productEntitlements.isEmpty)
          const EmptyStateText('No mappings'),
      ],
    );
  }
}
