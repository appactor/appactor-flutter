enum AppActorStore {
  playStore,
  appStore,
  stripe,
  promotional,
  unknown;

  String get wireValue => switch (this) {
        playStore => 'play_store',
        appStore => 'app_store',
        _ => name,
      };

  static AppActorStore fromString(String value) {
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return unknown;
  }
}

enum AppActorPackageType {
  weekly,
  monthly,
  twoMonth,
  threeMonth,
  sixMonth,
  annual,
  lifetime,
  consumable,
  custom;

  String get wireValue => switch (this) {
        twoMonth => 'two_month',
        threeMonth => 'three_month',
        sixMonth => 'six_month',
        _ => name,
      };

  static AppActorPackageType fromString(String value) {
    return switch (value) {
      'two_month' || 'two_months' || 'twoMonth' => twoMonth,
      'three_month' || 'three_months' || 'threeMonth' => threeMonth,
      'six_month' || 'six_months' || 'sixMonth' => sixMonth,
      _ => () {
          for (final e in values) {
            if (e.wireValue == value || e.name == value) return e;
          }
          return custom;
        }(),
    };
  }
}

enum AppActorProductType {
  subscription,
  nonConsumable,
  consumable,
  unknown;

  String get wireValue => switch (this) {
        nonConsumable => 'non_consumable',
        _ => name,
      };

  static AppActorProductType fromString(String value) {
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return unknown;
  }
}

enum AppActorOwnershipType {
  purchased,
  familyShared,
  unknown;

  String get wireValue => switch (this) {
        familyShared => 'family_shared',
        _ => name,
      };

  static AppActorOwnershipType fromString(String value) {
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return unknown;
  }
}

enum AppActorPeriodType {
  weekly,
  monthly,
  twoMonth,
  threeMonth,
  sixMonth,
  annual,
  lifetime,
  normal,
  trial,
  intro,
  unknown;

  String get wireValue => switch (this) {
        twoMonth => 'two_month',
        threeMonth => 'three_month',
        sixMonth => 'six_month',
        _ => name,
      };

  static AppActorPeriodType fromString(String value) {
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return unknown;
  }
}

enum AppActorSubscriptionStatus {
  active,
  gracePeriod,
  billingRetry,
  expired,
  revoked,
  upgraded,
  unknown;

  String get wireValue => switch (this) {
        gracePeriod => 'grace_period',
        billingRetry => 'billing_retry',
        _ => name,
      };

  static AppActorSubscriptionStatus fromString(String value) {
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return unknown;
  }
}

enum AppActorCancellationReason {
  customerCancelled,
  developerCancelled,
  unknown;

  String get wireValue => switch (this) {
        customerCancelled => 'customer_cancelled',
        developerCancelled => 'developer_cancelled',
        _ => name,
      };

  static AppActorCancellationReason fromString(String value) {
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return unknown;
  }
}

enum AppActorConfigValueType {
  boolean,
  number,
  string,
  json,
  unknown;

  String get wireValue => name;

  static AppActorConfigValueType fromString(String value) {
    for (final e in values) {
      if (e.name == value) return e;
    }
    return unknown;
  }
}

enum AppActorStoreCapability {
  purchases,
  subscriptions,
  inAppProducts,
  purchaseHistory,
  storefront;

  String get wireValue => switch (this) {
        inAppProducts => 'in_app_products',
        purchaseHistory => 'purchase_history',
        _ => name,
      };

  static AppActorStoreCapability? fromString(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return null;
  }
}

enum AppActorSubscriptionReplacementMode {
  withTimeProration,
  chargeProrated,
  withoutProration,
  chargeFullPrice,
  deferred;

  String get wireValue => switch (this) {
        withTimeProration => 'with_time_proration',
        chargeProrated => 'charge_prorated',
        withoutProration => 'without_proration',
        chargeFullPrice => 'charge_full_price',
        _ => name,
      };

  static AppActorSubscriptionReplacementMode? fromString(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return null;
  }
}
