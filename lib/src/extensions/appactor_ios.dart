import 'dart:io';

import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/method_names.dart';
import '../models/asa_diagnostics.dart';
import '../models/purchase_intent.dart';
import '../models/purchase_result.dart';

extension AppActorIOS on AppActor {
  Future<void> presentOfferCodeRedeemSheet() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('presentOfferCodeRedeemSheet is iOS only');
    }
    await AppActorPlatform.execute(MethodNames.presentOfferCode);
  }

  Future<AppActorAsaDiagnostics?> getAsaDiagnostics() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('getAsaDiagnostics is iOS only');
    }
    final result = await AppActorPlatform.execute(MethodNames.getAsaDiagnostics);
    if (result['value'] == null && !result.containsKey('attribution_completed')) {
      return null;
    }
    return AppActorAsaDiagnostics.fromJson(result);
  }

  Future<int> getPendingAsaPurchaseEventCount() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('getPendingAsaPurchaseEventCount is iOS only');
    }
    final result = await AppActorPlatform.execute(MethodNames.getPendingAsaPurchaseEventCount);
    return (result['value'] as num?)?.toInt() ?? 0;
  }

  Future<bool> getAsaFirstInstallOnDevice() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('getAsaFirstInstallOnDevice is iOS only');
    }
    final result = await AppActorPlatform.execute(MethodNames.getAsaFirstInstallOnDevice);
    return result['value'] == true;
  }

  Future<bool> getAsaFirstInstallOnAccount() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('getAsaFirstInstallOnAccount is iOS only');
    }
    final result = await AppActorPlatform.execute(MethodNames.getAsaFirstInstallOnAccount);
    return result['value'] == true;
  }

  Future<AppActorPurchaseResult> purchaseFromIntent(
    AppActorPurchaseIntent intent,
  ) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('purchaseFromIntent is iOS only');
    }
    final result = await AppActorPlatform.execute(
      MethodNames.purchaseFromIntent,
      {'intent_id': intent.intentId},
    );
    return AppActorPurchaseResult.fromJson(result);
  }
}
