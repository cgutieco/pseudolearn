use super::RustEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::{
    ExpressionId, HirDimension, HirPlace, HirStatement, LocalId, StatementId, Type,
};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn statements(&mut self, statements: &[StatementId], lines: &mut CodeLines) {
        self.scope.cleanups.push(super::CleanupFrame::default());
        for statement in statements {
            if let Some(HirStatement::Defer(body)) = self.view.statement(*statement) {
                if let Some(frame) = self.scope.cleanups.last_mut() {
                    frame.bodies.push(body.clone());
                }
                continue;
            }
            self.statement(*statement, lines);
        }
        let ends_in_exit = statements.last().is_some_and(|last| {
            matches!(
                self.view.statement(*last),
                Some(HirStatement::Return(_) | HirStatement::Break)
            )
        });
        let frame = self.scope.cleanups.pop().unwrap_or_default();
        if !ends_in_exit {
            self.run_cleanups(vec![frame], lines);
        }
    }

    pub(crate) fn statement(&mut self, identifier: StatementId, lines: &mut CodeLines) {
        let Some(statement) = self.view.statement(identifier) else {
            return;
        };
        let span = self.view.statement_span(identifier);
        let saved = std::mem::take(&mut self.preamble);
        let mut own = CodeLines::default();
        own.attributed(span);
        self.statement_kind(statement, span, &mut own);
        let generated = std::mem::replace(&mut self.preamble, saved);
        lines.append(generated);
        lines.append(own);
    }

    pub(crate) fn statement_kind(
        &mut self,
        statement: &HirStatement,
        span: Span,
        lines: &mut CodeLines,
    ) {
        match statement {
            HirStatement::Declare(locals) => self.declare(locals, lines),
            HirStatement::Assign { destination, value } => self.assign(destination, *value, lines),
            HirStatement::Dimension(dimensions) => self.dimension(dimensions, lines),
            HirStatement::Write { values, newline } => self.write(values, *newline, lines),
            HirStatement::Read(places) => self.read(places, span, lines),
            HirStatement::Call(expression) => {
                let text = self.expression(*expression);
                lines.line(&format!("{text};"));
            }
            HirStatement::Return(value) => self.return_statement(*value, lines),
            HirStatement::Break => {
                self.exit_cleanups(true, lines);
                lines.line("break;");
            }
            HirStatement::Spawn(expression) => {
                let text = self.expression(*expression);
                lines.line(&format!("{text};"));
            }
            other => self.control(other, span, lines),
        }
    }

    pub(crate) fn declare(&mut self, locals: &[LocalId], lines: &mut CodeLines) {
        for local in locals {
            if self.view.is_record_leaf(*local) || !self.scope.declared.insert(*local) {
                continue;
            }
            let Some(entry) = self.view.local(*local) else {
                continue;
            };
            let type_text = self.type_text(entry.type_id, entry.span);
            let name = self.local_name(*local);
            let mutability = if self.mutation.needs_mutable(*local, false) {
                "mut "
            } else {
                ""
            };
            lines.line(&format!("let {mutability}{name}: {type_text};"));
        }
    }

    pub(crate) fn first_assignment(
        &mut self,
        local: LocalId,
        value: ExpressionId,
        lines: &mut CodeLines,
    ) {
        self.scope.declared.insert(local);
        let name = self.local_name(local);
        let value_text = self.value(value);
        let Some(entry) = self.view.local(local) else {
            return;
        };
        let type_text = self.type_text(entry.type_id, entry.span);
        let mutability = if self.mutation.needs_mutable(local, true) {
            "mut "
        } else {
            ""
        };
        lines.line(&format!(
            "let {mutability}{name}: {type_text} = {value_text};"
        ));
    }

    pub(crate) fn assign(
        &mut self,
        destination: &HirPlace,
        value: ExpressionId,
        lines: &mut CodeLines,
    ) {
        if let HirPlace::Local(local) = destination
            && !self.scope.declared.contains(local)
        {
            self.first_assignment(*local, value, lines);
            return;
        }
        if let HirPlace::Element { array, indices } = destination
            && self.is_keyed(*array)
        {
            let receiver = self.operand(*array, 10);
            let key = indices
                .first()
                .map(|key| self.value(*key))
                .unwrap_or_default();
            let value_text = self.value(value);
            lines.line(&format!(
                "{receiver}.borrow_mut().set({key}, {value_text});"
            ));
            return;
        }
        let value_text = self.value(value);
        let place = self.place(destination);
        if self.is_optional_field_place(destination) {
            lines.line(&format!("{place} = Some({value_text});"));
            return;
        }
        lines.line(&format!("{place} = {value_text};"));
    }

    pub(crate) fn record_owner(&self, local: LocalId) -> LocalId {
        self.view
            .module
            .record_locals
            .iter()
            .find(|(_, leaves)| leaves.contains(&local))
            .map_or(local, |(owner, _)| *owner)
    }

    pub(crate) fn dimension(&mut self, dimensions: &[HirDimension], lines: &mut CodeLines) {
        for dimension in dimensions {
            let local = self.record_owner(dimension.local);
            if local != dimension.local && self.scope.declared.contains(&local) {
                continue;
            }
            let dimension = &HirDimension {
                local,
                dimensions: dimension.dimensions.clone(),
            };
            let Some(entry) = self.view.local(dimension.local) else {
                continue;
            };
            let Type::Array { element, .. } = self.view.representation(entry.type_id) else {
                continue;
            };
            let initial = match self.default_value(element, entry.span) {
                Some(text) => text,
                None => self.block("array_without_default", entry.span),
            };
            let mut text = initial;
            for size in dimension.dimensions.iter().rev() {
                let size_text = self.expression(*size);
                text = format!("vec![{text}; {size_text} as usize]");
            }
            let name = self.local_name(dimension.local);
            if self.scope.declared.insert(dimension.local) {
                let type_text = self.type_text(entry.type_id, entry.span);
                lines.line(&format!("let mut {name}: {type_text} = {text};"));
            } else {
                lines.line(&format!("{name} = {text};"));
            }
        }
    }

    pub(crate) fn return_statement(&mut self, value: Option<ExpressionId>, lines: &mut CodeLines) {
        let pending = !self
            .pending_cleanups(false)
            .iter()
            .all(|frame| frame.bodies.is_empty());
        match value {
            Some(expression) if pending => {
                let text = self.value(expression);
                lines.line(&format!("let returned = {text};"));
                self.exit_cleanups(false, lines);
                lines.line("return returned;");
            }
            Some(expression) => {
                let text = self.value(expression);
                lines.line(&format!("return {text};"));
            }
            None => {
                self.exit_cleanups(false, lines);
                lines.line("return;");
            }
        }
    }

    pub(crate) fn write(&mut self, values: &[ExpressionId], newline: bool, lines: &mut CodeLines) {
        let mut template = String::new();
        let mut arguments = Vec::new();
        for value in values {
            if let Some(text) = self.literal_text(*value) {
                template.push_str(&text.replace('{', "{{").replace('}', "}}"));
                continue;
            }
            template.push_str("{}");
            arguments.push(self.displayed(*value));
        }
        let macro_name = if newline { "println!" } else { "print!" };
        if template.is_empty() && arguments.is_empty() {
            if newline {
                lines.line("println!();");
            }
            return;
        }
        let template = format!("{template:?}");
        if arguments.is_empty() {
            lines.line(&format!("{macro_name}({template});"));
        } else {
            lines.line(&format!(
                "{macro_name}({template}, {});",
                arguments.join(", ")
            ));
        }
    }

    pub(crate) fn read(&mut self, places: &[HirPlace], span: Span, lines: &mut CodeLines) {
        for place in places {
            let type_id = self.place_type(place);
            let reader = match type_id.map(|type_id| self.view.representation(type_id)) {
                Some(Type::Integer) => self.require("read_integer"),
                Some(Type::Real) => self.require("read_real"),
                Some(Type::String) => self.require("read_text"),
                Some(Type::Character) => self.require("read_character"),
                Some(Type::Boolean) => self.require("read_boolean"),
                _ => {
                    self.block("input:designator", span);
                    continue;
                }
            };
            let target = self.place(place);
            lines.line(&format!("{target} = {reader}();"));
            if let HirPlace::Local(local) = place {
                self.scope.declared.insert(*local);
            }
        }
    }
}
