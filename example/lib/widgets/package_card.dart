import 'package:flutter/material.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({super.key, required this.package, required this.onPurchase});
  final AppActorPackage package;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = package.displayName ?? package.productName ?? package.id;
    final priceStr = package.localizedPriceString ??
        (package.price != null
            ? '\$${package.price!.toStringAsFixed(2)}'
            : null);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerLow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 4),
                      if (priceStr != null)
                        Text(priceStr, style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        )),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: onPurchase,
                  child: const Text('Buy'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _chip(context, package.packageType.wireValue),
                _chip(context, package.productType.wireValue),
                _chip(context, package.store.wireValue),
                if (package.currencyCode != null)
                  _chip(context, package.currencyCode!),
                if (package.tokenAmount != null)
                  _chip(context, '${package.tokenAmount} tokens', highlight: true),
                if (package.position != null)
                  _chip(context, 'pos: ${package.position}'),
              ],
            ),
            if (package.productDescription != null) ...[
              const SizedBox(height: 8),
              Text(package.productDescription!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  )),
            ],
            if (package.basePlanId != null || package.offerId != null || package.serverId != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (package.basePlanId != null)
                    _detail(theme, 'Base Plan', package.basePlanId!),
                  if (package.offerId != null)
                    _detail(theme, 'Offer', package.offerId!),
                  if (package.serverId != null)
                    _detail(theme, 'Server ID', package.serverId!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, {bool highlight = false}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: highlight ? cs.primaryContainer : cs.surfaceContainerHigh,
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: highlight ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          )),
    );
  }

  Widget _detail(ThemeData theme, String label, String value) {
    return Text('$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ));
  }
}
