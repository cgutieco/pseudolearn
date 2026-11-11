use super::RustEmitter;
use super::rust_effect_catalog::capability_type;
use super::rust_expressions::ATOM;
use crate::effect_functions::effect_function;
use pseudolearn_semantic::{EFFECT_OPERATIONS, EffectValueKind, ExpressionId, HirExpression};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
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
        let Some(function) = effect_function(found.identity, suspends)
            .filter(|function| !super::rust_effect_catalog::is_pending(function))
        else {
            return self.block("capability", span);
        };
        self.require(function);
        let mut parts = Vec::new();
        if let Some(receiver) = receiver {
            parts.push(format!("&{}", self.operand(receiver, ATOM)));
        }
        for (argument, kind) in arguments.iter().zip(found.parameters) {
            parts.push(self.effect_argument(*argument, *kind));
        }
        let call = format!("{function}({})", parts.join(", "));
        if function == "timer_wait" {
            self.awaited(call)
        } else {
            call
        }
    }

    fn effect_argument(&mut self, argument: ExpressionId, kind: EffectValueKind) -> String {
        match kind {
            EffectValueKind::Integer | EffectValueKind::Real | EffectValueKind::Boolean => {
                self.value(argument)
            }
            EffectValueKind::Text => {
                match crate::effect_functions::literal_text(self.view, argument) {
                    Some(text) => format!("{text:?}"),
                    None => format!("&{}", self.operand(argument, ATOM)),
                }
            }
            _ => format!("&{}", self.operand(argument, ATOM)),
        }
    }

    pub(crate) fn opaque_type(&mut self, kind: EffectValueKind, span: Span) -> String {
        if kind == EffectValueKind::Bytes {
            return "Vec<u8>".to_owned();
        }
        let Some((name, support)) = capability_type(kind) else {
            return self.block("capability", span);
        };
        self.require(support);
        name.to_owned()
    }

    pub(crate) fn sets_exit_code(&self) -> bool {
        crate::effect_functions::sets_exit_code(self.view.module)
    }
}
