import 'package:bloc/bloc.dart';
import '../../domain/ports/agent_consent_store.dart';

enum AgentConsentStatus { unknown, granted, notGranted }

final class AgentConsentCubit extends Cubit<AgentConsentStatus> {
  final AgentConsentStore _store;

  AgentConsentCubit({required this._store})
    : super(AgentConsentStatus.unknown);

  Future<void> load() async {
    final granted = await _store.hasConsented();
    if (!isClosed) emit(granted ? AgentConsentStatus.granted : AgentConsentStatus.notGranted);
  }

  Future<void> grant() async {
    await _store.grant();
    if (!isClosed) emit(AgentConsentStatus.granted);
  }

  Future<void> withdraw() async {
    await _store.withdraw();
    if (!isClosed) emit(AgentConsentStatus.notGranted);
  }
}
