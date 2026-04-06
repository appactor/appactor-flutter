import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/method_names.dart';
import '../models/experiment.dart';
import '../models/remote_config.dart';

extension AppActorConfig on AppActor {
  Future<AppActorRemoteConfigs> getRemoteConfigs() async {
    final result = await AppActorPlatform.execute(MethodNames.getRemoteConfigs);
    return AppActorRemoteConfigs.fromJson(result);
  }

  Future<AppActorExperimentAssignment?> getExperimentAssignment(
    String experimentKey,
  ) async {
    final result =
        await AppActorPlatform.execute(MethodNames.getExperimentAssignment, {
      'experiment_key': experimentKey,
    });
    if (result.isEmpty || result['experiment_key'] == null) return null;
    return AppActorExperimentAssignment.fromJson(result);
  }

  Future<AppActorRemoteConfigItem?> getRemoteConfig(String key) async {
    final result = await AppActorPlatform.execute(
      MethodNames.getRemoteConfig,
      {'key': key},
    );
    if (result['value'] == null && !result.containsKey('key')) return null;
    return AppActorRemoteConfigItem.fromJson(result);
  }

  Future<bool?> getRemoteConfigBool(String key) async =>
      (await getRemoteConfig(key))?.boolValue;

  Future<String?> getRemoteConfigString(String key) async =>
      (await getRemoteConfig(key))?.stringValue;

  Future<num?> getRemoteConfigNumber(String key) async =>
      (await getRemoteConfig(key))?.numberValue;

  Future<int?> getRemoteConfigInt(String key) async {
    final n = (await getRemoteConfig(key))?.numberValue;
    if (n == null) return null;
    return n == n.toInt() ? n.toInt() : null;
  }
}
