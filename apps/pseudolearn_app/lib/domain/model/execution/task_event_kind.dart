enum TaskEventKind {
  spawn,
  ready,
  resume,
  suspend,
  complete,
  cancelRequest,
  join,
  channelCreate,
  channelSend,
  channelReceive,
  channelEmpty,
  channelClose,
  effectDelivered,
  call,
  callReturn,
  decision,
  output,
  input,
  failure,
  statementEnter,
  statementExit,
  other;

  bool get isQuiet => switch (this) {
    statementEnter || statementExit || decision || other => true,
    _ => false,
  };
}

enum TaskWaitCause {
  task,
  join,
  channelSend,
  channelReceive,
  select,
  effect,
  unknown,
}
