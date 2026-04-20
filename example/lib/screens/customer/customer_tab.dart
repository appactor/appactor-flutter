import 'dart:io';

import 'package:flutter/material.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

import '../../widgets/section_card.dart';
import '../../widgets/info_row.dart';
import '../../widgets/empty_state_text.dart';

class CustomerTab extends StatelessWidget {
  const CustomerTab({
    super.key,
    required this.ready,
    required this.sdkVersion,
    required this.customerInfo,
    required this.offlineKeys,
    required this.onLogIn,
    required this.onLogOut,
    required this.onRestorePurchases,
    required this.onSyncPurchases,
    required this.onQuietSyncPurchases,
    required this.onRedeemOfferCode,
    required this.onReset,
    required this.onRefresh,
  });

  final bool ready;
  final String sdkVersion;
  final AppActorCustomerInfo? customerInfo;
  final Set<String> offlineKeys;
  final VoidCallback onLogIn;
  final VoidCallback onLogOut;
  final VoidCallback onRestorePurchases;
  final VoidCallback onSyncPurchases;
  final VoidCallback onQuietSyncPurchases;
  final VoidCallback onRedeemOfferCode;
  final VoidCallback onReset;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSdkStatus(context),
        const SizedBox(height: 12),
        _buildIdentity(context),
        const SizedBox(height: 12),
        _buildEntitlements(context),
        const SizedBox(height: 12),
        _buildSubscriptions(context),
        if (customerInfo?.nonSubscriptions.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _buildNonSubscriptions(context),
        ],
        if (customerInfo?.tokenBalance != null) ...[
          const SizedBox(height: 12),
          _buildTokenBalance(context),
        ],
        if (customerInfo?.consumableBalances != null &&
            customerInfo!.consumableBalances!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildConsumableBalances(context),
        ],
        const SizedBox(height: 12),
        _buildActions(context),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSdkStatus(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SectionCard(
      title: 'SDK Status',
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ready ? Colors.green : cs.error,
        ),
      ),
      children: [
        InfoRow('Ready', ready ? 'Yes' : 'No'),
        InfoRow('SDK Version', sdkVersion.isEmpty ? '—' : sdkVersion),
        if (customerInfo != null)
          InfoRow(
            'Offline Mode',
            customerInfo!.isComputedOffline ? 'Yes' : 'No',
          ),
      ],
    );
  }

  Widget _buildIdentity(BuildContext context) {
    return SectionCard(
      title: 'Identity',
      children: [
        InfoRow('User ID', customerInfo?.appUserId ?? 'anonymous', mono: true),
        InfoRow('First Seen', customerInfo?.firstSeen ?? '—'),
        InfoRow('Last Seen', customerInfo?.lastSeen ?? '—'),
        InfoRow('Request ID', customerInfo?.requestId ?? '—', mono: true),
        if (customerInfo?.managementUrl != null)
          InfoRow('Management URL', customerInfo!.managementUrl!),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onLogIn,
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Log In'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onLogOut,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntitlements(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final entitlements = customerInfo?.entitlements ?? {};

    return SectionCard(
      title: 'Entitlements (${entitlements.length})',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${customerInfo?.activeEntitlementKeys.length ?? 0} active',
            style: theme.textTheme.labelSmall?.copyWith(color: cs.primary),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: onRefresh,
            visualDensity: VisualDensity.compact,
            tooltip: 'Refresh customer info',
          ),
        ],
      ),
      children: [
        if (customerInfo?.activeEntitlementKeys.isNotEmpty ?? false)
          _buildChipRow(
            context,
            'Active',
            customerInfo!.activeEntitlementKeys.toList(),
            cs.primaryContainer,
            cs.onPrimaryContainer,
          ),
        if (offlineKeys.isNotEmpty)
          _buildChipRow(
            context,
            'Offline',
            offlineKeys.toList(),
            cs.tertiaryContainer,
            cs.onTertiaryContainer,
          ),
        if (entitlements.isEmpty) const EmptyStateText('No entitlements'),
        for (final entry in entitlements.entries) ...[
          const Divider(height: 20),
          _buildEntitlementDetail(context, entry.value),
        ],
      ],
    );
  }

  Widget _buildChipRow(
    BuildContext context,
    String label,
    List<String> keys,
    Color bg,
    Color fg,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          for (final key in keys)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: bg,
              ),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntitlementDetail(
    BuildContext context,
    AppActorEntitlementInfo e,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: e.isActive ? Colors.green : cs.error,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              e.identifier,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InfoRow('Product', e.productIdentifier ?? '—'),
        InfoRow('Store', e.store.wireValue),
        InfoRow('Ownership', e.ownershipType.wireValue),
        InfoRow('Period', e.periodType.wireValue),
        InfoRow('Will Renew', e.willRenew ? 'Yes' : 'No'),
        if (e.subscriptionStatus != null)
          InfoRow('Sub Status', e.subscriptionStatus!.wireValue),
        if (e.expirationDate != null) InfoRow('Expires', e.expirationDate!),
        if (e.originalPurchaseDate != null)
          InfoRow('Orig Purchase', e.originalPurchaseDate!),
        if (e.cancellationReason != null)
          InfoRow('Cancel Reason', e.cancellationReason!.wireValue),
        if (e.gracePeriodExpiresAt != null)
          InfoRow('Grace Expires', e.gracePeriodExpiresAt!),
        if (e.grantedBy != null) InfoRow('Granted By', e.grantedBy!),
        if (e.activePromotionalOfferType != null)
          InfoRow('Promo Type', e.activePromotionalOfferType!),
        if (e.activePromotionalOfferId != null)
          InfoRow('Promo ID', e.activePromotionalOfferId!),
        if (e.isSandbox == true) InfoRow('Sandbox', 'Yes'),
      ],
    );
  }

  Widget _buildSubscriptions(BuildContext context) {
    final subs = customerInfo?.subscriptions ?? {};
    return SectionCard(
      title: 'Subscriptions (${subs.length})',
      children: [
        if (subs.isEmpty) const EmptyStateText('No subscriptions'),
        for (final entry in subs.entries) ...[
          if (entry.key != subs.keys.first) const Divider(height: 20),
          _buildSubscriptionDetail(context, entry.value),
        ],
      ],
    );
  }

  Widget _buildSubscriptionDetail(
    BuildContext context,
    AppActorSubscriptionInfo s,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.isActive ? Colors.green : cs.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.subscriptionKey,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InfoRow('Product', s.productIdentifier),
        InfoRow('Store', s.store.wireValue),
        if (s.periodType != null) InfoRow('Period', s.periodType!.wireValue),
        if (s.status != null) InfoRow('Status', s.status!),
        InfoRow(
          'Auto Renew',
          s.autoRenew == true
              ? 'Yes'
              : s.autoRenew == false
              ? 'No'
              : '—',
        ),
        if (s.expiresDate != null) InfoRow('Expires', s.expiresDate!),
        if (s.purchaseDate != null) InfoRow('Purchased', s.purchaseDate!),
        if (s.cancellationReason != null)
          InfoRow('Cancel Reason', s.cancellationReason!.wireValue),
        if (s.gracePeriodExpiresAt != null)
          InfoRow('Grace Expires', s.gracePeriodExpiresAt!),
        if (s.originalTransactionId != null)
          InfoRow('Orig Txn', s.originalTransactionId!, mono: true),
        if (s.activePromotionalOfferType != null)
          InfoRow('Promo Type', s.activePromotionalOfferType!),
        if (s.activePromotionalOfferId != null)
          InfoRow('Promo ID', s.activePromotionalOfferId!),
        if (s.isSandbox == true) InfoRow('Sandbox', 'Yes'),
      ],
    );
  }

  Widget _buildNonSubscriptions(BuildContext context) {
    final nonSubs = customerInfo!.nonSubscriptions;
    return SectionCard(
      title: 'Non-Subscriptions',
      children: [
        for (final entry in nonSubs.entries)
          for (final ns in entry.value) ...[
            InfoRow('Product', ns.productIdentifier),
            InfoRow('Store', ns.store.wireValue),
            if (ns.purchaseDate != null) InfoRow('Purchased', ns.purchaseDate!),
            if (ns.isConsumable == true) InfoRow('Consumable', 'Yes'),
            if (ns.isRefund == true) InfoRow('Refund', 'Yes'),
            const Divider(height: 16),
          ],
      ],
    );
  }

  Widget _buildTokenBalance(BuildContext context) {
    final tb = customerInfo!.tokenBalance!;
    return SectionCard(
      title: 'Token Balance',
      trailing: Text(
        '${tb.total}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        InfoRow('Renewable', '${tb.renewable}'),
        InfoRow('Non-Renewable', '${tb.nonRenewable}'),
        InfoRow('Total', '${tb.total}'),
      ],
    );
  }

  Widget _buildConsumableBalances(BuildContext context) {
    return SectionCard(
      title: 'Consumable Balances',
      children: [
        for (final entry in customerInfo!.consumableBalances!.entries)
          InfoRow(entry.key, '${entry.value}'),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return SectionCard(
      title: 'Actions',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.restore, size: 16),
              label: const Text('Restore Purchases'),
              onPressed: onRestorePurchases,
            ),
            ActionChip(
              avatar: const Icon(Icons.sync, size: 16),
              label: const Text('Sync + Refresh'),
              onPressed: onSyncPurchases,
            ),
            ActionChip(
              avatar: const Icon(Icons.sync_disabled, size: 16),
              label: const Text('Quiet Sync'),
              onPressed: onQuietSyncPurchases,
            ),
            if (Platform.isIOS)
              ActionChip(
                avatar: const Icon(Icons.card_giftcard, size: 16),
                label: const Text('Redeem Offer Code'),
                onPressed: onRedeemOfferCode,
              ),
            ActionChip(
              avatar: const Icon(Icons.restart_alt, size: 16),
              label: const Text('Reset SDK'),
              onPressed: onReset,
            ),
          ],
        ),
      ],
    );
  }
}
