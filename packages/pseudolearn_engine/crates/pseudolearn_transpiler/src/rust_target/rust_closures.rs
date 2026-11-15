use super::RustEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::{ExpressionId, FunctionId, LocalId, Passing, Type};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn indirect_call(
        &mut self,
        callee: ExpressionId,
        arguments: &[ExpressionId],
    ) -> String {
        let passings = match self.view.expression_type(callee) {
            Type::Record(record) => self
                .view
                .module
                .function_types
                .get(&record)
                .map(|signature| {
                    signature
                        .parameters
                        .iter()
                        .map(|(_, passing)| *passing)
                        .collect::<Vec<_>>()
                })
                .unwrap_or_default(),
            _ => Vec::new(),
        };
        let callee_text = self.operand(callee, 10);
        let texts = arguments
            .iter()
            .enumerate()
            .map(|(position, argument)| match passings.get(position) {
                Some(Passing::Reference) => self.reference_argument(*argument),
                _ => self.value(*argument),
            })
            .collect::<Vec<_>>()
            .join(", ");
        format!("({callee_text})({texts})")
    }

    pub(crate) fn capture_clones(&self, captures: &[(LocalId, LocalId)], preamble: &mut CodeLines) {
        for (captured, _) in captures {
            let captured_name = self.local_name(*captured);
            let copies = self
                .view
                .local(*captured)
                .is_some_and(|local| self.is_copy(local.type_id));
            if !copies {
                preamble.line(&format!("let {captured_name} = {captured_name}.clone();"));
            }
        }
    }

    pub(crate) fn closure_value(&mut self, function: FunctionId, span: Span) -> String {
        let (Some(closure), Some(entry)) = (
            self.view.module.closures.get(&function),
            self.view.function(function),
        ) else {
            return self.block("function_literal", span);
        };
        let type_text = match self.view.expression_type_id_of_function_value(function) {
            Some(type_id) => self.type_text(type_id, span),
            None => return self.block("function_literal", span),
        };
        let outer = std::mem::take(&mut self.scope);
        self.enter_function(entry);
        self.scope.owner = outer.owner;
        self.scope.generic_receiver = outer.generic_receiver;
        let parameters = self.parameter_list(entry).join(", ");
        let result = self.result_suffix(entry);
        let mut body = CodeLines::default();
        self.statements(&entry.body, &mut body);
        self.scope = outer;
        self.closures = self.closures.saturating_add(1);
        let name = format!("closure{}", self.closures);
        let mut preamble = CodeLines::default();
        preamble.open(&format!("let {name}: {type_text} = {{"));
        self.capture_clones(&closure.captures, &mut preamble);
        preamble.open(&format!("Rc::new(move |{parameters}|{result} {{"));
        preamble.append(body);
        preamble.close("})");
        preamble.close("};");
        self.preamble.append(preamble);
        self.uses.insert("rc");
        name
    }

    pub(crate) fn captured(&mut self, function: FunctionId, capture: u32) -> String {
        let captured = self
            .view
            .module
            .closures
            .get(&function)
            .and_then(|closure| {
                usize::try_from(capture)
                    .ok()
                    .and_then(|index| closure.captures.get(index))
            })
            .map(|(outer, _)| *outer);
        match captured {
            Some(local) => self.local_name(local),
            None => self.block("closure", Span::default()),
        }
    }

    pub(crate) fn function_value(&mut self, function: FunctionId, span: Span) -> String {
        if self.view.module.closures.contains_key(&function) {
            return self.closure_value(function, span);
        }
        self.uses.insert("rc");
        format!("Rc::new({})", self.function_name(function))
    }

    pub(crate) fn propagate(&mut self, value: ExpressionId) -> String {
        let operand = self.operand(value, 10);
        let Some(cleanup) = self.cleanup_text() else {
            return format!("{operand}?");
        };
        let optional = self
            .expression_record(value)
            .and_then(|record| self.view.variant_family(record))
            .is_some_and(|family| {
                family == pseudolearn_semantic::variant_model::VariantFamily::Optional
            });
        if optional {
            format!(
                "match {operand} {{ Some(value) => value, None => {{ {cleanup} return None; }} }}"
            )
        } else {
            format!(
                "match {operand} {{ Ok(value) => value, Err(error) => {{ {cleanup} return Err(error); }} }}"
            )
        }
    }
}
