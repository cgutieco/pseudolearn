import 'execution_history_state.dart';

sealed class ExecutionHistoryCommand {
  const ExecutionHistoryCommand();
}

final class SelectHistorySurface extends ExecutionHistoryCommand {
  final ExecutionHistorySurface surface;

  const SelectHistorySurface(this.surface);
}

final class SelectHistoryEvent extends ExecutionHistoryCommand {
  final int event;

  const SelectHistoryEvent(this.event);
}

final class SelectHistoryTask extends ExecutionHistoryCommand {
  final int? taskId;

  const SelectHistoryTask(this.taskId);
}

final class SelectHistoryFrame extends ExecutionHistoryCommand {
  final int frame;

  const SelectHistoryFrame(this.frame);
}

final class SelectHistoryFramePage extends ExecutionHistoryCommand {
  final int frameStart;

  const SelectHistoryFramePage(this.frameStart);
}

final class SelectHistoryRange extends ExecutionHistoryCommand {
  final int start;
  final int count;

  const SelectHistoryRange(this.start, this.count);
}

final class FollowCurrentHistoryEvent extends ExecutionHistoryCommand {
  const FollowCurrentHistoryEvent();
}

final class LoadNextValuePage extends ExecutionHistoryCommand {
  const LoadNextValuePage();
}
