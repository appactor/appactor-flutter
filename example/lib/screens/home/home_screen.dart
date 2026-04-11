import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

import '../../widgets/input_dialog.dart';
import '../customer/customer_tab.dart';
import '../offerings/offerings_tab.dart';
import '../config/config_tab.dart';
import '../event_log/event_log_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _configured = false;
  String _sdkVersion = '';
  String? _error;

  AppActorCustomerInfo? _customerInfo;
  AppActorOfferings? _offerings;
  AppActorRemoteConfigs? _remoteConfigs;
  AppActorExperimentAssignment? _experiment;
  Set<String> _offlineKeys = {};
  AppActorAsaDiagnostics? _asaDiagnostics;

  StreamSubscription<AppActorCustomerInfo>? _customerInfoSub;
  StreamSubscription<AppActorReceiptPipelineEvent>? _receiptEventSub;
  final List<String> _eventLog = [];

  bool _loading = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _configure();
  }

  @override
  void dispose() {
    _customerInfoSub?.cancel();
    _receiptEventSub?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    _customerInfoSub =
        AppActor.instance.onCustomerInfoUpdated.listen((info) {
      if (!mounted) return;
      setState(() {
        _customerInfo = info;
        _addLog('Customer info updated: ${info.activeEntitlementKeys}');
      });
    });

    _receiptEventSub =
        AppActor.instance.onReceiptPipelineEvent.listen((event) {
      if (!mounted) return;
      setState(() {
        _addLog('Receipt: ${event.type} — ${event.productId}');
      });
    });
  }

  void _addLog(String message) {
    _eventLog.insert(0, '[${TimeOfDay.now().format(context)}] $message');
    if (_eventLog.length > 50) _eventLog.removeLast();
  }


  Future<T?> _fetch<T>(String label, Future<T> Function() action) async {
    try {
      final result = await action();
      if (!mounted) return null;
      return result;
    } on AppActorError catch (e) {
      _addLog('$label error: ${e.message}');
      return null;
    }
  }

  // Run with: flutter run --dart-define=APPACTOR_API_KEY=pk_YOUR_PUBLIC_API_KEY
  static const _apiKey = String.fromEnvironment(
    'APPACTOR_API_KEY',
    defaultValue: 'pk_YOUR_PUBLIC_API_KEY',
  );

  Future<void> _configure() async {
    setState(() => _loading = true);
    try {
      // Dart marks ASA intent first; native iOS enable runs right after configure().
      AppActor.instance.enableSearchAdsTracking();
      await AppActor.instance.configure(
        _apiKey,
        options: const AppActorOptions(
          logLevel: AppActorLogLevel.debug,
        ),
      );
      await AppActor.instance.enableInstallReferrer();
      final version = await AppActor.instance.sdkVersion();
      final configured = await AppActor.instance.isConfigured();
      setState(() {
        _configured = configured;
        _sdkVersion = version;
        _error = null;
      });
      _addLog('SDK configured (v$version)');
      await _refreshAll();
    } on AppActorError catch (e) {
      setState(() => _error = e.toString());
      _addLog('Configure failed: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _fetchCustomerInfo(),
      _fetchOfferings(),
      _fetchRemoteConfigs(),
      _fetchExperiment('pricing_test'),
      _fetchOfflineKeys(),
      if (Platform.isIOS) _fetchAsaDiagnostics(),
    ]);
  }

  Future<void> _fetchCustomerInfo() async {
    final info = await _fetch('CustomerInfo', AppActor.instance.getCustomerInfo);
    if (info != null) setState(() => _customerInfo = info);
  }

  Future<void> _fetchOfferings() async {
    final offerings = await _fetch('Offerings', AppActor.instance.getOfferings);
    if (offerings != null) setState(() => _offerings = offerings);
  }

  Future<void> _fetchRemoteConfigs() async {
    final configs =
        await _fetch('RemoteConfigs', AppActor.instance.getRemoteConfigs);
    if (configs != null) setState(() => _remoteConfigs = configs);
  }

  Future<void> _fetchExperiment(String key) async {
    final assignment = await _fetch(
      'Experiment',
      () => AppActor.instance.getExperimentAssignment(key),
    );
    setState(() => _experiment = assignment);
    _addLog(assignment != null
        ? 'Experiment "$key": variant=${assignment.variantKey}'
        : 'Experiment "$key": no assignment');
  }

  Future<void> _fetchOfflineKeys() async {
    final keys = await _fetch(
        'OfflineKeys', AppActor.instance.activeEntitlementKeysOffline);
    if (keys != null) setState(() => _offlineKeys = keys);
  }

  Future<void> _fetchAsaDiagnostics() async {
    final diag = await _fetch('ASA', AppActor.instance.getAsaDiagnostics);
    setState(() => _asaDiagnostics = diag);
  }

  Future<void> _logIn() async {
    final userId = await showInputDialog(
      context,
      title: 'Log In',
      label: 'App User ID',
      defaultValue: 'test_user_123',
    );
    if (userId == null || userId.isEmpty) return;

    setState(() => _loading = true);
    try {
      final info = await AppActor.instance.logIn(userId);
      setState(() => _customerInfo = info);
      _addLog('Logged in as $userId');
      await _refreshAll();
    } on AppActorError catch (e) {
      _addLog('Login error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logOut() async {
    setState(() => _loading = true);
    try {
      await AppActor.instance.logOut();
      _addLog('Logged out');
      await _refreshAll();
    } on AppActorError catch (e) {
      _addLog('Logout error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _loading = true);
    try {
      final info = await AppActor.instance.restorePurchases(
        syncWithAppStore: Platform.isIOS ? true : null,
      );
      setState(() => _customerInfo = info);
      _addLog('Purchases restored');
    } on AppActorError catch (e) {
      _addLog('Restore error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _syncPurchases() async {
    setState(() => _loading = true);
    try {
      final info = await AppActor.instance.syncPurchases();
      setState(() => _customerInfo = info);
      _addLog('Purchases synced');
    } on AppActorError catch (e) {
      _addLog('Sync error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _purchasePackage(AppActorPackage package) async {
    setState(() => _loading = true);
    try {
      final result = await AppActor.instance.purchasePackage(package);
      if (!mounted) return;
      setState(() {
        if (result.customerInfo != null) _customerInfo = result.customerInfo;
      });
      _addLog('Purchase ${result.status.name}: ${package.productId}');

      final msg = switch (result.status) {
        AppActorPurchaseStatus.purchased => 'Purchase successful!',
        AppActorPurchaseStatus.cancelled => 'Purchase cancelled',
        AppActorPurchaseStatus.pending => 'Purchase pending...',
        _ => 'Status: ${result.status.name}',
      };
      _showSnackBar(msg);
    } on AppActorError catch (e) {
      _addLog('Purchase error: ${e.message}');
      _showSnackBar('Error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    setState(() => _loading = true);
    try {
      await AppActor.instance.reset();
      setState(() {
        _configured = false;
        _customerInfo = null;
        _offerings = null;
        _remoteConfigs = null;
        _experiment = null;
        _offlineKeys = {};
        _asaDiagnostics = null;
      });
      _addLog('SDK reset');
    } on AppActorError catch (e) {
      _addLog('Reset error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _setLogLevel(AppActorLogLevel level) async {
    try {
      await AppActor.instance.setLogLevel(level);
      _addLog('Log level set to ${level.name}');
      _showSnackBar('Log level: ${level.name}');
    } on AppActorError catch (e) {
      _addLog('SetLogLevel error: ${e.message}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppActor Example'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _configured ? _refreshAll : null,
            tooltip: 'Refresh all',
          ),
        ],
      ),
      body: _error != null && !_configured
          ? _buildErrorState()
          : _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) => setState(() => _selectedTab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Customer'),
          NavigationDestination(
              icon: Icon(Icons.shopping_bag), label: 'Offerings'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Config'),
          NavigationDestination(
              icon: Icon(Icons.terminal), label: 'Event Log'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Configuration Error', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _configure,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _selectedTab,
      children: [
        CustomerTab(
          configured: _configured,
          sdkVersion: _sdkVersion,
          customerInfo: _customerInfo,
          offlineKeys: _offlineKeys,
          onLogIn: _logIn,
          onLogOut: _logOut,
          onRestorePurchases: _restorePurchases,
          onSyncPurchases: _syncPurchases,
          onRedeemOfferCode: () async {
            try {
              await AppActor.instance.presentOfferCodeRedeemSheet();
            } on AppActorError catch (e) {
              _addLog('Offer code error: ${e.message}');
            }
          },
          onReset: _reset,
          onRefresh: _fetchCustomerInfo,
        ),
        OfferingsTab(
          offerings: _offerings,
          onPurchasePackage: _purchasePackage,
          onRefresh: _fetchOfferings,
        ),
        ConfigTab(
          remoteConfigs: _remoteConfigs,
          experiment: _experiment,
          asaDiagnostics: _asaDiagnostics,
          onRefreshConfigs: _fetchRemoteConfigs,
          onFetchExperiment: _fetchExperiment,
          onSetLogLevel: _setLogLevel,
          onRefreshAsa: Platform.isIOS ? _fetchAsaDiagnostics : null,
        ),
        EventLogTab(
          eventLog: _eventLog,
          onClear: () => setState(() => _eventLog.clear()),
        ),
      ],
    );
  }
}
