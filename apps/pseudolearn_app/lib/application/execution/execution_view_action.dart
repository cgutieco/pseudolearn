sealed class ExecutionViewAction {
  const ExecutionViewAction();

  static const ExecutionViewAction toggleOutputPanel =
      ToggleOutputPanelViewAction();
  static const ExecutionViewAction showTrace = ShowTraceViewAction();
  static const ExecutionViewAction showTasks = ShowTasksViewAction();
  static const ExecutionViewAction showOtherTab = ShowOtherTabViewAction();

  const factory ExecutionViewAction.openDocument(String documentId) =
      OpenDocumentViewAction;
}

final class ToggleOutputPanelViewAction extends ExecutionViewAction {
  const ToggleOutputPanelViewAction();
}

final class ShowTraceViewAction extends ExecutionViewAction {
  const ShowTraceViewAction();
}

final class ShowTasksViewAction extends ExecutionViewAction {
  const ShowTasksViewAction();
}

final class ShowOtherTabViewAction extends ExecutionViewAction {
  const ShowOtherTabViewAction();
}

final class OpenDocumentViewAction extends ExecutionViewAction {
  final String documentId;

  const OpenDocumentViewAction(this.documentId);
}
