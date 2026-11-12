use super::PythonEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::{
    ExpressionId, HirDimension, HirPlace, HirStatement, LocalId, StatementId, Type,
};
use pseudolearn_source::Span;

impl PythonEmitter<'_, '_> {
    pub(crate) fn body(&mut self, statements: &[StatementId], lines: &mut CodeLines) {
        let mut own = CodeLines::default();
        self.block_statements(statements, &mut own);
        if own.is_empty() {
            own.line("pass");
        }
        lines.append(own);
    }

    pub(crate) fn block_statements(&mut self, statements: &[StatementId], lines: &mut CodeLines) {
        for (position, statement) in statements.iter().enumerate() {
            if let Some(HirStatement::Defer(cleanup)) = self.view.statement(*statement) {
                let rest = statements
                    .get(position.saturating_add(1)..)
                    .unwrap_or_default();
                lines.open("try:");
                self.body(rest, lines);
                lines.dedent();
                lines.open("finally:");
                self.body(cleanup, lines);
                lines.dedent();
                return;
            }
            self.statement(*statement, lines);
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
            HirStatement::Assign {
                destination: HirPlace::Local(local),
                value,
            } if self.scope.aliases.contains_key(local)
                && matches!(
                    self.view.expression(*value),
                    pseudolearn_semantic::HirExpression::Captured { .. }
                ) => {}
            HirStatement::Assign { destination, value } => {
                let value_text = self.value(*value);
                let place = self.place(destination);
                lines.line(&format!("{place} = {value_text}"));
            }
            HirStatement::Dimension(dimensions) => self.dimension(dimensions, lines),
            HirStatement::Write { values, newline } => self.write(values, *newline, lines),
            HirStatement::Read(places) => self.read(places, span, lines),
            HirStatement::Call(expression) | HirStatement::Spawn(expression) => {
                self.call_statement(*expression, lines)
            }
            HirStatement::Return(value) => self.return_statement(*value, lines),
            HirStatement::Break => lines.line("break"),
            other => self.control(other, span, lines),
        }
    }

    pub(crate) fn declare(&mut self, locals: &[LocalId], lines: &mut CodeLines) {
        for local in locals {
            if self.view.is_record_leaf(*local) {
                continue;
            }
            let Some(entry) = self.view.local(*local) else {
                continue;
            };
            if self.is_record(entry.type_id) {
                let name = self.local_name(*local);
                let default = self.default_value(entry.type_id);
                lines.line(&format!("{name} = {default}"));
            }
        }
    }

    pub(crate) fn dimension(&mut self, dimensions: &[HirDimension], lines: &mut CodeLines) {
        let mut seen = Vec::new();
        for dimension in dimensions {
            let local = self.record_owner(dimension.local);
            if seen.contains(&local) {
                continue;
            }
            seen.push(local);
            let Some(entry) = self.view.local(local) else {
                continue;
            };
            let Type::Array { element, .. } = self.view.representation(entry.type_id) else {
                continue;
            };
            let mut text = self.default_value(element);
            for size in dimension.dimensions.iter().rev() {
                let size_text = self.expression(*size);
                text = format!("[{text} for _ in range({size_text})]");
            }
            lines.line(&format!("{} = {text}", self.local_name(local)));
        }
    }

    pub(crate) fn record_owner(&self, local: LocalId) -> LocalId {
        self.view
            .module
            .record_locals
            .iter()
            .find(|(_, leaves)| leaves.contains(&local))
            .map_or(local, |(owner, _)| *owner)
    }

    pub(crate) fn write(&mut self, values: &[ExpressionId], newline: bool, lines: &mut CodeLines) {
        let mut arguments = Vec::new();
        for value in values {
            arguments.push(self.displayed(*value));
        }
        if arguments.is_empty() && !newline {
            return;
        }
        if !arguments.is_empty() {
            arguments.push("sep=\"\"".to_owned());
        }
        if !newline {
            arguments.push("end=\"\"".to_owned());
        }
        lines.line(&format!("print({})", arguments.join(", ")));
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
            lines.line(&format!("{target} = {reader}()"));
        }
    }

    pub(crate) fn return_statement(&mut self, value: Option<ExpressionId>, lines: &mut CodeLines) {
        let value_text = value.map(|expression| self.value(expression));
        if self.scope.reference_parameters.is_empty() {
            match value_text {
                Some(text) => lines.line(&format!("return {text}")),
                None => lines.line("return"),
            }
            return;
        }
        let tail = self.write_back_tuple(value_text);
        lines.line(&format!("return {tail}"));
    }
}
