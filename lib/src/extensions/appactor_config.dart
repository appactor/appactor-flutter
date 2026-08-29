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
    final result = await AppActorPlatform.execute(
      MethodNames.getExperimentAssignment,
      {'experiment_key': experimentKey},
    );
    if (result.isEmpty || result['experiment_key'] == null) return null;
    return AppActorExperimentAssignment.fromJson(result);
  }

  /// Resolves the user's standing in an experiment.
  ///
  /// Never `null`: when the user is not in the experiment the result reports
  /// `isEnrolled == false`, `variantKey == null`, and every typed getter
  /// returns its default. Same caching and errors as [getExperimentAssignment].
  ///
  /// ```dart
  /// final paywall = await AppActor.instance.getExperiment('paywall_test');
  /// if (paywall.isVariant('annual_first')) showAnnualFirst();
  ///
  /// final showOnboarding = (await AppActor.instance.getExperiment('has_onboard'))
  ///     .boolValue(defaultValue: true);
  /// final title = (await AppActor.instance.getExperiment('onboarding_flow'))['title']
  ///     as String? ?? 'Welcome';
  /// ```
  Future<AppActorExperiment> getExperiment(String experimentKey) async =>
      AppActorExperiment(
        experimentKey: experimentKey,
        assignment: await getExperimentAssignment(experimentKey),
      );

  Future<AppActorRemoteConfigItem?> getRemoteConfig(String key) async {
    final result = await AppActorPlatform.execute(MethodNames.getRemoteConfig, {
      'key': key,
    });
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
