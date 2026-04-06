import 'appactor_platform.dart';

class AppActor {
  static final AppActor instance = AppActor._();

  AppActor._() {
    AppActorPlatform.ensureInitialized();
  }
}
