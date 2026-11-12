import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/settings/app_preferences.dart';

mixin PreferenceUpdateFollower<S> on Cubit<S> {
  StreamSubscription<AppPreferences>? _preferenceUpdates;

  void followPreferenceUpdates(
    Stream<AppPreferences> updates,
    void Function(AppPreferences preferences) onUpdate,
  ) {
    _preferenceUpdates = updates.listen((preferences) {
      if (!isClosed) onUpdate(preferences);
    });
  }

  @override
  Future<void> close() async {
    await _preferenceUpdates?.cancel();
    return super.close();
  }
}
