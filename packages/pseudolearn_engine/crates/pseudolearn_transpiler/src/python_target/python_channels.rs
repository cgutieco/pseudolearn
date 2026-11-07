use super::PythonEmitter;
use pseudolearn_semantic::channel_model::{ChannelAction, ChannelExpression};
use pseudolearn_semantic::{ExpressionId, FunctionId};
use pseudolearn_source::Span;

impl PythonEmitter<'_, '_> {
    pub(crate) fn spawn(
        &mut self,
        function: FunctionId,
        arguments: &[ExpressionId],
        span: Span,
    ) -> String {
        let Some(scope) = self.scope.task_scopes.last().cloned() else {
            return self.block("spawn_outside_scope", span);
        };
        let texts = arguments
            .iter()
            .map(|argument| self.value(*argument))
            .collect::<Vec<_>>();
        let name = self.function_name(function);
        let suspendible = self
            .view
            .function(function)
            .is_some_and(|entry| entry.suspendible);
        if suspendible {
            format!("{scope}.spawn({name}({}))", texts.join(", "))
        } else {
            self.require("tasks");
            format!("{scope}.spawn(as_task({name}, {}))", texts.join(", "))
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
            (ChannelAction::New, _, Some(capacity)) => format!("Channel({capacity})"),
            (ChannelAction::Send, Some(receiver), Some(value)) => {
                format!("await {receiver}.send({value})")
            }
            (ChannelAction::Receive, Some(receiver), _) => format!("await {receiver}.receive()"),
            (ChannelAction::Close, Some(receiver), _) => format!("{receiver}.close()"),
            _ => self.block("channel", span),
        }
    }
}
