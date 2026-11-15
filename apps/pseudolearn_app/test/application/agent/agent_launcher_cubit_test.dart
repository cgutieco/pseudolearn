import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/agent_launcher_cubit.dart';
import '../../fakes/in_memory_preferences_store.dart';

void main() {
  test('the launcher is shown until the person hides it', () async {
    final cubit = AgentLauncherCubit(preferences: InMemoryPreferencesStore());
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state, isTrue);
  });

  test('hiding persists and a new cubit reads it back', () async {
    final preferences = InMemoryPreferencesStore();
    final first = AgentLauncherCubit(preferences: preferences);
    await first.setShown(false);
    expect(first.state, isFalse);
    await first.close();
    final second = AgentLauncherCubit(preferences: preferences);
    addTearDown(second.close);
    await second.load();
    expect(second.state, isFalse);
    await second.setShown(true);
    expect((await preferences.read()).agentLauncherShown, isTrue);
  });

  test('a closed cubit ignores late loads', () async {
    final cubit = AgentLauncherCubit(preferences: InMemoryPreferencesStore());
    await cubit.close();
    await expectLater(cubit.load(), completes);
  });
}
