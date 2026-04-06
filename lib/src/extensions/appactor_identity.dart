import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/method_names.dart';
import '../models/customer_info.dart';

extension AppActorIdentity on AppActor {
  Future<AppActorCustomerInfo> logIn(String appUserId) async {
    final result = await AppActorPlatform.execute(MethodNames.logIn, {
      'new_app_user_id': appUserId,
    });
    return AppActorCustomerInfo.fromJson(result);
  }

  Future<bool> logOut() async {
    final result = await AppActorPlatform.execute(MethodNames.logOut);
    return result['value'] == true;
  }

  Future<String?> getAppUserId() async {
    final result = await AppActorPlatform.execute(MethodNames.getAppUserId);
    return result['value'] as String?;
  }

  Future<bool> getIsAnonymous() async {
    final result = await AppActorPlatform.execute(MethodNames.getIsAnonymous);
    return result['value'] == true;
  }
}
