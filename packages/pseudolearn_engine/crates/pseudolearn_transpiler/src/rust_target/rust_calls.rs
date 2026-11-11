use super::RustEmitter;
use pseudolearn_semantic::{ExpressionId, FunctionId, HirExpression, RecordId, Type};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn compound(&mut self, identifier: ExpressionId, span: Span) -> String {
        match self.view.expression(identifier) {
            HirExpression::Field { receiver, field } => self.object_field(*receiver, *field, false),
            HirExpression::Element { array, indices } => self.element(*array, indices, false),
            HirExpression::RecordField { record, offset } => self.record_field(*record, *offset),
            HirExpression::Call {
                function,
                arguments,
            } => self.call(*function, arguments),
            HirExpression::TaskSpawn {
                function,
                arguments,
            } => self.spawn(*function, arguments, span),
            HirExpression::AwaitTask(task) => {
                let task = self.operand(*task, 10);
                self.awaited(format!("{task}.clone()"))
            }
            HirExpression::VirtualCall {
                receiver,
                function,
                arguments,
            } => self.virtual_call(*receiver, *function, arguments),
            HirExpression::New { class, arguments } => {
                let arguments = self.arguments(None, arguments);
                format!("{}::new({arguments})", self.class_name(*class))
            }
            _ => self.compound_rest(identifier, span),
        }
    }

    pub(crate) fn compound_rest(&mut self, identifier: ExpressionId, span: Span) -> String {
        match self.view.expression(identifier) {
            HirExpression::This(_) => self.this_value(span),
            HirExpression::SuperCall {
                function,
                arguments,
                ..
            } => self.super_call(*function, arguments, span),
            HirExpression::RecordNew { record, fields } => self.record_new(*record, fields, span),
            HirExpression::VariantNew {
                record,
                alternative,
                payload,
            } => self.variant_new((*record, *alternative), *payload, span),
            HirExpression::Propagate { value, .. } => self.propagate(*value),
            HirExpression::FunctionValue(function) => self.function_value(*function, span),
            HirExpression::IndirectCall { callee, arguments } => {
                self.indirect_call(*callee, arguments)
            }
            HirExpression::Captured { function, capture } => self.captured(*function, *capture),
            _ => self.block("expression", span),
        }
    }

    pub(crate) fn arguments(
        &mut self,
        function: Option<FunctionId>,
        arguments: &[ExpressionId],
    ) -> String {
        let parameters = function
            .and_then(|identifier| self.view.function(identifier))
            .map(|entry| entry.parameters.clone())
            .unwrap_or_default();
        arguments
            .iter()
            .enumerate()
            .map(|(position, argument)| {
                let by_reference = parameters
                    .get(position)
                    .is_some_and(|parameter| self.is_reference_parameter(*parameter));
                if by_reference {
                    self.reference_argument(*argument)
                } else {
                    self.value(*argument)
                }
            })
            .collect::<Vec<_>>()
            .join(", ")
    }

    pub(crate) fn reference_argument(&mut self, argument: ExpressionId) -> String {
        if let HirExpression::Local(local) = self.view.expression(argument)
            && self.is_reference_parameter(*local)
        {
            return self.local_name(*local);
        }
        let text = match self.view.expression(argument) {
            HirExpression::Field { receiver, field } => self.object_field(*receiver, *field, true),
            HirExpression::Element { array, indices } => self.element(*array, indices, true),
            _ => self.expression(argument),
        };
        format!("&mut {text}")
    }

    pub(crate) fn call(&mut self, function: FunctionId, arguments: &[ExpressionId]) -> String {
        let name = self.function_name(function);
        let arguments = self.arguments(Some(function), arguments);
        let suspendible = self
            .view
            .function(function)
            .is_some_and(|entry| entry.suspendible);
        if suspendible {
            self.awaited(format!("{name}({arguments})"))
        } else {
            format!("{name}({arguments})")
        }
    }

    pub(crate) fn virtual_call(
        &mut self,
        receiver: ExpressionId,
        function: FunctionId,
        arguments: &[ExpressionId],
    ) -> String {
        let method = self.function_name(function);
        let arguments = self.arguments(Some(function), arguments);
        let suspendible = if self
            .view
            .function(function)
            .is_some_and(|entry| entry.suspendible)
        {
            ".await"
        } else {
            ""
        };
        if let HirExpression::This(_) = self.view.expression(receiver)
            && self.scope.owner.is_some()
        {
            let receiver_text = if self.scope.generic_receiver {
                "this"
            } else {
                "self"
            };
            return format!("{receiver_text}.{method}({arguments}){suspendible}");
        }
        let receiver_text = self.operand(receiver, 10);
        if arguments.contains(".borrow") {
            return format!(
                "{{ let arguments = ({arguments},); {receiver_text}.borrow_mut().{method}(arguments.0) }}"
            );
        }
        format!("{receiver_text}.borrow_mut().{method}({arguments}){suspendible}")
    }

    pub(crate) fn this_value(&mut self, span: Span) -> String {
        self.block("this_object", span)
    }

    pub(crate) fn super_call(
        &mut self,
        function: Option<FunctionId>,
        arguments: &[ExpressionId],
        span: Span,
    ) -> String {
        let Some(function) = function else {
            return self.block("super_constructor", span);
        };
        let Some(entry) = self.view.function(function) else {
            return self.block("super_call", span);
        };
        let name = self.method_function_name(function);
        let arguments = self.arguments(Some(function), arguments);
        let separator = if arguments.is_empty() { "" } else { ", " };
        let _ = entry;
        format!("{name}(this{separator}{arguments})")
    }

    pub(crate) fn record_new(
        &mut self,
        record: RecordId,
        fields: &[ExpressionId],
        span: Span,
    ) -> String {
        let Some(entry) = self.view.record(record) else {
            return self.block("record", span);
        };
        let assignments = entry
            .fields
            .iter()
            .zip(fields)
            .map(|(field, value)| {
                let name = self.names.field(&field.name);
                format!("{name}: {}", self.value(*value))
            })
            .collect::<Vec<_>>()
            .join(", ");
        format!(
            "{} {{ {assignments} }}",
            self.unique_record_name(record, &entry.name)
        )
    }

    pub(crate) fn expression_record(&self, identifier: ExpressionId) -> Option<RecordId> {
        match self.view.expression_type(identifier) {
            Type::Record(record) => Some(record),
            _ => None,
        }
    }
}
