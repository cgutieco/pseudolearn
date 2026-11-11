use super::PythonEmitter;
use crate::effect_functions::effect_function;
use pseudolearn_semantic::{EFFECT_OPERATIONS, ExpressionId, HirExpression};
use pseudolearn_source::Span;

impl PythonEmitter<'_, '_> {
    pub(crate) fn effect(&mut self, identifier: ExpressionId, span: Span) -> String {
        let HirExpression::Effect {
            awaited,
            operation,
            receiver,
            arguments,
            ..
        } = self.view.expression(identifier).clone()
        else {
            return self.block("capability", span);
        };
        let Some(found) = EFFECT_OPERATIONS.iter().find(|entry| entry.id == operation) else {
            return self.block("capability", span);
        };
        let suspends = awaited && self.scope.asynchronous;
        let Some(function) = effect_function(found.identity, suspends) else {
            return self.block("capability", span);
        };
        self.require(function);
        let mut parts = Vec::new();
        if let Some(receiver) = receiver {
            parts.push(self.operand(receiver, 10));
        }
        for argument in &arguments {
            let text = match crate::effect_functions::literal_text(self.view, *argument) {
                Some(text) => super::python_expressions::python_string(&text),
                None => self.value(*argument),
            };
            parts.push(text);
        }
        let call = format!("{function}({})", parts.join(", "));
        if function == "timer_wait" {
            format!("await {call}")
        } else {
            call
        }
    }
}
