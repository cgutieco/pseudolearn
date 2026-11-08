import 'package:bloc/bloc.dart';
import '../../domain/model/agent/agent_message.dart';
import '../../domain/model/agent/model_item.dart';
import '../../domain/model/credits/credit_balance.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/agent_consent_store.dart';
import 'agent_loop.dart';
import 'agent_loop_outcome.dart';
import 'agent_session_state.dart';
import 'agent_turn.dart';
import 'code_block_checker.dart';

final class AgentEditorial {
  final SyntaxProfileId Function() profile;
  final UiLanguageId Function() language;

  const AgentEditorial({required this.profile, required this.language});
}

final class AgentSessionCubit extends Cubit<AgentSessionState> {
  final AgentLoop _loop;
  final AgentConsentStore _consent;
  final CodeBlockChecker _checker;
  final AgentEditorial _editorial;
  List<ModelItem> _conversation = const [];
  AgentTurn? _suspended;
  CreditBalance? _balanceBeforeTurn;

  AgentSessionCubit({
    required AgentLoop loop,
    required AgentConsentStore consent,
    required CodeBlockChecker checker,
    required AgentEditorial editorial,
  }) : _loop = loop,
       _consent = consent,
       _checker = checker,
       _editorial = editorial,
       super(const AgentSessionState());

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || state.isBusy || state.confirmation != null) return;
    if (!await _consent.hasConsented()) {
      emit(state.copyWith(status: AgentSessionStatus.needsConsent, draftAwaitingConsent: () => message));
      return;
    }
    _balanceBeforeTurn = state.balance;
    emit(state.copyWith(
      status: AgentSessionStatus.thinking,
      messages: [...state.messages, AgentMessage(role: AgentRole.user, text: message)],
      liveSteps: const [],
      failure: () => null,
      draftAwaitingConsent: () => null,
    ));
    await _continue(_loop.start(_conversation, message));
  }

  Future<void> resumeAfterConsent() async {
    final draft = state.draftAwaitingConsent;
    emit(state.copyWith(status: AgentSessionStatus.idle, draftAwaitingConsent: () => null));
    if (draft != null) await send(draft);
  }

  Future<void> answerConfirmation({required bool approved}) async {
    final turn = _suspended;
    if (turn == null || state.confirmation == null) return;
    _suspended = null;
    emit(state.copyWith(status: AgentSessionStatus.thinking, confirmation: () => null));
    await _continue(_loop.decide(turn, approved: approved));
  }

  void markSeen() {
    if (state.hasUnseenReply) emit(state.copyWith(hasUnseenReply: false));
  }

  void startOver() {
    _conversation = const [];
    _suspended = null;
    emit(AgentSessionState(balance: state.balance));
  }

  Future<void> _continue(AgentTurn turn) async {
    final outcome = await _loop.advance(turn);
    if (isClosed) return;
    emit(state.copyWith(
      liveSteps: outcome.turn.steps,
      balance: outcome.turn.balance,
      lastRequestSpent: outcome.turn.balance?.spentSince(_balanceBeforeTurn) ?? state.lastRequestSpent,
    ));
    switch (outcome) {
      case AgentAwaitsConfirmation(:final call, :final tool, :final arguments):
        _suspended = outcome.turn;
        emit(state.copyWith(
          status: AgentSessionStatus.awaitingConfirmation,
          confirmation: () => PendingConfirmation(
            toolName: call.name,
            label: tool.stepLabel,
            risk: tool.risk,
            arguments: arguments.values,
          ),
        ));
      case AgentAnswered():
        _finishTurn(outcome.turn, AgentSessionStatus.idle);
      case AgentExhausted():
        _finishTurn(outcome.turn, AgentSessionStatus.exhausted);
      case AgentFailed(:final failure):
        emit(state.copyWith(status: AgentSessionStatus.failed, failure: () => failure));
    }
  }

  void _finishTurn(AgentTurn turn, AgentSessionStatus status) {
    _conversation = turn.history;
    final text = turn.answerText;
    final reply = AgentMessage(
      role: AgentRole.assistant,
      text: text,
      steps: turn.steps,
      codeBlocks: _checker.check(
        text,
        profileId: _editorial.profile(),
        languageId: _editorial.language(),
      ),
    );
    emit(state.copyWith(
      status: status,
      messages: [...state.messages, reply],
      liveSteps: const [],
      hasUnseenReply: true,
    ));
  }
}
