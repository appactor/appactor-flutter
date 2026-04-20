/// Wire method names for the AppActor platform channel.
/// Internal — not exported in the public API.
abstract class MethodNames {
  static const configure = 'configure';
  static const reset = 'reset';
  static const getSdkVersion = 'get_sdk_version';
  static const logIn = 'log_in';
  static const logOut = 'log_out';
  static const purchasePackage = 'purchase_package';
  static const restorePurchases = 'restore_purchases';
  static const syncPurchases = 'sync_purchases';
  static const quietSyncPurchases = 'quiet_sync_purchases';
  static const drainReceiptQueueAndRefreshCustomer =
      'drain_receipt_queue_and_refresh_customer';
  static const getCustomerInfo = 'get_customer_info';
  static const getOfferings = 'get_offerings';
  static const activeEntitlementsOffline = 'active_entitlement_keys_offline';
  static const getRemoteConfigs = 'get_remote_configs';
  static const getExperimentAssignment = 'get_experiment_assignment';
  static const setLogLevel = 'set_log_level';
  static const enableAppleSearchAdsTracking =
      'enable_apple_search_ads_tracking';
  static const presentOfferCode = 'present_offer_code_redeem_sheet';
  static const getAsaDiagnostics = 'get_asa_diagnostics';
  static const getPendingAsaPurchaseEventCount =
      'get_pending_asa_purchase_event_count';
  static const getAsaFirstInstallOnDevice = 'get_asa_first_install_on_device';
  static const getAsaFirstInstallOnAccount = 'get_asa_first_install_on_account';
  static const getAppUserId = 'get_app_user_id';
  static const getIsAnonymous = 'get_is_anonymous';
  static const getCachedOfferings = 'get_cached_offerings';
  static const getCachedRemoteConfigs = 'get_cached_remote_configs';
  static const getCachedCustomerInfo = 'get_cached_customer_info';
  static const getRemoteConfig = 'get_remote_config';
  static const purchaseFromIntent = 'purchase_from_intent';
  static const enableInstallReferrer = 'enable_install_referrer';
  static const setFallbackOfferings = 'set_fallback_offerings';
  static const canMakePurchases = 'can_make_purchases';
  static const getStorefront = 'get_storefront';
  static const getStoreCapabilities = 'get_store_capabilities';
}
