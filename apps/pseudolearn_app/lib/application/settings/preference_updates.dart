import 'dart:async';
import '../../domain/model/settings/app_preferences.dart';

final class PreferenceUpdates {
  final StreamController<AppPreferences> _controller =
      StreamController<AppPreferences>.broadcast();

  Stream<AppPreferences> get stream => _controller.stream;

  void publish(AppPreferences preferences) => _controller.add(preferences);
}
