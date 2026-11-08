import 'agent_turn_step.dart';
import 'code_block.dart';
import 'reply_block.dart';

enum AgentRole { user, assistant }

final class AgentMessage {
  final AgentRole role;
  final String text;
  final List<AgentTurnStep> steps;
  final List<ReplyBlock> blocks;
  final List<CheckedCodeBlock> codeBlocks;

  const AgentMessage({
    required this.role,
    required this.text,
    this.steps = const [],
    this.blocks = const [],
    this.codeBlocks = const [],
  });
}
