import 'package:bloc/bloc.dart';
import '../../domain/ports/preferences_store.dart';

final class AgentLauncherCubit extends Cubit<bool> {
  final PreferencesStore _preferences;

  AgentLauncherCubit({required PreferencesStore preferences})
    : _preferences = preferences,
      super(true);

  Future<void> load() async {
    final stored = await _preferences.read();
    if (!isClosed) emit(stored.agentLauncherShown);
  }

  Future<void> setShown(bool shown) async {
    final stored = await _preferences.read();
    await _preferences.write(stored.copyWith(agentLauncherShown: shown));
    if (!isClosed) emit(shown);
  }
}
