use super::RustEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::channel_model::{ChannelAction, ChannelExpression, HirSelect};
use pseudolearn_semantic::{ExpressionId, FunctionId, LocalId, StatementId};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn task_scope(
        &mut self,
        (failure, body): (Option<LocalId>, &[StatementId]),
        span: Span,
        lines: &mut CodeLines,
    ) {
        if failure.is_some() {
            self.block("task_failure", span);
            return;
        }
        self.require("tasks");
        let name = match self.scope.task_scopes.len() {
            0 => "task_scope".to_owned(),
            depth => format!("task_scope_{}", depth.saturating_add(1)),
        };
        lines.open("{");
        lines.line(&format!("let {name} = TaskScope::new();"));
        self.scope.task_scopes.push(name.clone());
        self.statements(body, lines);
        self.scope.task_scopes.pop();
        lines.line(&format!("{name}.join().await;"));
        lines.close("}");
    }

    pub(crate) fn spawn(
        &mut self,
        function: FunctionId,
        arguments: &[ExpressionId],
        span: Span,
    ) -> String {
        let Some(scope) = self.scope.task_scopes.last().cloned() else {
            return self.block("spawn_outside_scope", span);
        };
        let name = self.function_name(function);
        let arguments = self.arguments(Some(function), arguments);
        let suspendible = self
            .view
            .function(function)
            .is_some_and(|entry| entry.suspendible);
        if suspendible {
            format!("{scope}.spawn({name}({arguments}))")
        } else {
            format!("{scope}.spawn(async move {{ {name}({arguments}) }})")
        }
    }

    pub(crate) fn channel_operation(&mut self, channel: &ChannelExpression, span: Span) -> String {
        self.require("channel");
        let receiver = channel.receiver.map(|receiver| self.operand(receiver, 10));
        let argument = channel
            .arguments
            .first()
            .map(|argument| self.value(*argument));
        match (&channel.action, receiver, argument) {
            (ChannelAction::New, _, Some(capacity)) => format!("Channel::new({capacity})"),
            (ChannelAction::Send, Some(receiver), Some(value)) => {
                format!("{receiver}.send({value}).await")
            }
            (ChannelAction::Receive, Some(receiver), _) => format!("{receiver}.receive().await"),
            (ChannelAction::Close, Some(receiver), _) => format!("{receiver}.close()"),
            _ => self.block("channel", span),
        }
    }

    pub(crate) fn select(&mut self, _selection: &HirSelect, span: Span, _lines: &mut CodeLines) {
        self.block("select_statement", span);
    }
}
