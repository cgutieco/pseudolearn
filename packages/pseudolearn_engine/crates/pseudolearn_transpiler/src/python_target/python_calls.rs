use super::PythonEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::{python_type_name, python_value_name};
use pseudolearn_semantic::variant_model::VariantFamily;
use pseudolearn_semantic::{ExpressionId, FunctionId, HirExpression, RecordId};
use pseudolearn_source::Span;

impl PythonEmitter<'_, '_> {
    pub(crate) fn compound(&mut self, identifier: ExpressionId, span: Span) -> String {
        match self.view.expression(identifier) {
            HirExpression::Field { receiver, field } => self.object_field(*receiver, *field),
            HirExpression::Element { array, indices } => self.element(*array, indices),
            HirExpression::RecordField { record, offset } => self.record_field(*record, *offset),
            HirExpression::Call {
                function,
                arguments,
            } => self.call(*function, arguments, None),
            HirExpression::VirtualCall {
                receiver,
                function,
                arguments,
            } => {
                let receiver_text = self.operand(*receiver, 10);
                self.call(*function, arguments, Some(receiver_text))
            }
            HirExpression::TaskSpawn {
                function,
                arguments,
            } => self.spawn(*function, arguments, span),
            HirExpression::AwaitTask(task) => format!("await {}", self.operand(*task, 10)),
            HirExpression::New { class, arguments } => {
                let texts = arguments
                    .iter()
                    .map(|argument| self.value(*argument))
                    .collect::<Vec<_>>();
                format!("{}({})", self.class_name(*class), texts.join(", "))
            }
            HirExpression::This(_) => "self".to_owned(),
            _ => self.compound_rest(identifier, span),
        }
    }

    pub(crate) fn compound_rest(&mut self, identifier: ExpressionId, span: Span) -> String {
        match self.view.expression(identifier) {
            HirExpression::SuperCall {
                function,
                arguments,
                ..
            } => self.super_call(*function, arguments),
            HirExpression::RecordNew { record, fields } => {
                let texts = fields
                    .iter()
                    .map(|value| self.value(*value))
                    .collect::<Vec<_>>();
                format!("{}({})", self.record_name(*record), texts.join(", "))
            }
            HirExpression::VariantNew {
                record,
                alternative,
                payload,
            } => self.variant_new(*record, *alternative, *payload),
            HirExpression::Propagate { value, .. } => {
                self.require("propagation");
                format!("propagate({})", self.expression(*value))
            }
            HirExpression::FunctionValue(function) => self.function_value(*function, span),
            HirExpression::Captured { function, capture } => self.captured(*function, *capture),
            HirExpression::IndirectCall { callee, arguments } => {
                let callee_text = self.operand(*callee, 10);
                let texts = arguments
                    .iter()
                    .map(|argument| self.value(*argument))
                    .collect::<Vec<_>>();
                format!("{callee_text}({})", texts.join(", "))
            }
            HirExpression::Channel(channel) => self.channel_operation(channel, span),
            HirExpression::Collection(collection) => self.collection_operation(collection),
            _ => self.block("expression", span),
        }
    }

    pub(crate) fn call_text(
        &mut self,
        function: FunctionId,
        arguments: &[ExpressionId],
        receiver: Option<String>,
    ) -> String {
        let texts = arguments
            .iter()
            .map(|argument| self.value(*argument))
            .collect::<Vec<_>>();
        let name = self.function_name(function);
        let target = match receiver {
            Some(receiver) => format!("{receiver}.{name}"),
            None => name,
        };
        let awaited = self
            .view
            .function(function)
            .is_some_and(|entry| entry.suspendible);
        let call = format!("{target}({})", texts.join(", "));
        if awaited {
            format!("await {call}")
        } else {
            call
        }
    }

    pub(crate) fn reference_targets(
        &mut self,
        function: FunctionId,
        arguments: &[ExpressionId],
    ) -> Vec<String> {
        let write_backs = self.write_backs(function);
        let parameters = self
            .view
            .function(function)
            .map(|entry| entry.parameters.clone())
            .unwrap_or_default();
        parameters
            .iter()
            .zip(arguments)
            .filter(|(parameter, _)| write_backs.contains(parameter))
            .map(|(_, argument)| self.expression(*argument))
            .collect()
    }

    pub(crate) fn call(
        &mut self,
        function: FunctionId,
        arguments: &[ExpressionId],
        receiver: Option<String>,
    ) -> String {
        let targets = self.reference_targets(function, arguments);
        let call = self.call_text(function, arguments, receiver);
        if targets.is_empty() {
            return call;
        }
        let returns = self.view.function(function).is_some_and(|entry| {
            !matches!(
                self.view.representation(entry.result),
                pseudolearn_semantic::Type::Unit | pseudolearn_semantic::Type::Never
            )
        });
        let result = self.temporary("result");
        let mut names = Vec::new();
        if returns {
            names.push(result.clone());
        }
        names.extend(targets);
        let mut preamble = CodeLines::default();
        preamble.line(&format!("{} = {call}", names.join(", ")));
        self.preamble.append(preamble);
        if returns { result } else { "None".to_owned() }
    }

    pub(crate) fn call_statement(&mut self, expression: ExpressionId, lines: &mut CodeLines) {
        let text = self.expression(expression);
        if text != "None" {
            lines.line(&text);
        }
    }

    pub(crate) fn super_call(
        &mut self,
        function: Option<FunctionId>,
        arguments: &[ExpressionId],
    ) -> String {
        let texts = arguments
            .iter()
            .map(|argument| self.value(*argument))
            .collect::<Vec<_>>();
        let name = match function.and_then(|identifier| self.view.function(identifier)) {
            Some(entry) if entry.kind == pseudolearn_semantic::hir::FunctionKind::Method => {
                python_value_name(&entry.name)
            }
            _ => "__init__".to_owned(),
        };
        format!("super().{name}({})", texts.join(", "))
    }

    pub(crate) fn variant_new(
        &mut self,
        record: RecordId,
        alternative: u32,
        payload: Option<ExpressionId>,
    ) -> String {
        self.require("variants");
        let payload_text = payload.map(|value| self.value(value)).unwrap_or_default();
        match (self.view.variant_family(record), alternative) {
            (Some(VariantFamily::Optional), 0) => "Nothing()".to_owned(),
            (Some(VariantFamily::Optional), _) => format!("Some({payload_text})"),
            (Some(VariantFamily::Result), 0) => format!("Ok({payload_text})"),
            (Some(VariantFamily::Result), _) => format!("Err({payload_text})"),
            _ => {
                let label = self
                    .view
                    .module
                    .user_variants
                    .get(&record)
                    .and_then(|variant| {
                        usize::try_from(alternative)
                            .ok()
                            .and_then(|index| variant.alternatives.get(index))
                    })
                    .map(|entry| python_type_name(&entry.spelling))
                    .unwrap_or_default();
                let fields = match payload.map(|value| self.view.expression(value)) {
                    Some(HirExpression::RecordNew { fields, .. }) => fields
                        .iter()
                        .map(|field| self.value(*field))
                        .collect::<Vec<_>>()
                        .join(", "),
                    _ => String::new(),
                };
                format!("{}.{label}({fields})", self.record_name(record))
            }
        }
    }

    pub(crate) fn function_value(&mut self, function: FunctionId, span: Span) -> String {
        if !self.view.module.closures.contains_key(&function) {
            return self.function_name(function);
        }
        let Some(entry) = self.view.function(function) else {
            return self.block("function_literal", span);
        };
        let outer = std::mem::take(&mut self.scope);
        let name = self.temporary("closure");
        let parameters = {
            self.enter_function(function, entry);
            if let Some(closure) = self.view.module.closures.get(&function) {
                self.scope.aliases = closure
                    .captures
                    .iter()
                    .map(|(captured, inner)| (*inner, *captured))
                    .collect();
            }
            self.scope.task_scopes = outer.task_scopes.clone();
            self.visible_parameters(entry)
        };
        let keyword = if entry.suspendible {
            "async def"
        } else {
            "def"
        };
        let mut preamble = CodeLines::default();
        preamble.open(&format!("{keyword} {name}({}):", parameters.join(", ")));
        self.function_body(entry, &mut preamble);
        preamble.dedent();
        self.scope = outer;
        self.preamble.append(preamble);
        name
    }

    pub(crate) fn captured(&mut self, function: FunctionId, capture: u32) -> String {
        self.view
            .module
            .closures
            .get(&function)
            .and_then(|closure| {
                usize::try_from(capture)
                    .ok()
                    .and_then(|index| closure.captures.get(index))
            })
            .map_or_else(|| "None".to_owned(), |(outer, _)| self.local_name(*outer))
    }
}
