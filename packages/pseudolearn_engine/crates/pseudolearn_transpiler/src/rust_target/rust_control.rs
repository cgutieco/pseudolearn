use super::RustEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::{
    ExpressionId, HirCase, HirExpression, HirStatement, Literal, LocalId, StatementId, Type,
};
use pseudolearn_source::Span;

pub(crate) struct CountedLoop<'statement> {
    pub(crate) control: LocalId,
    pub(crate) initial: ExpressionId,
    pub(crate) ending: ExpressionId,
    pub(crate) step: Option<ExpressionId>,
    pub(crate) body: &'statement [StatementId],
}

impl RustEmitter<'_, '_> {
    pub(crate) fn control(&mut self, statement: &HirStatement, span: Span, lines: &mut CodeLines) {
        match statement {
            HirStatement::Conditional {
                condition,
                affirmative,
                negative,
            } => {
                self.conditional(*condition, (affirmative, negative), lines);
            }
            HirStatement::While { condition, body } => {
                let condition_text = self.expression(*condition);
                lines.open(&format!("while {condition_text} {{"));
                self.loop_body(body, lines);
                lines.close("}");
            }
            _ => self.control_more(statement, span, lines),
        }
    }

    pub(crate) fn control_more(
        &mut self,
        statement: &HirStatement,
        span: Span,
        lines: &mut CodeLines,
    ) {
        match statement {
            HirStatement::Repeat { body, condition } => {
                lines.open("loop {");
                self.loop_body(body, lines);
                let condition_text = self.expression(*condition);
                lines.open(&format!("if {condition_text} {{"));
                lines.line("break;");
                lines.close("}");
                lines.close("}");
            }
            HirStatement::For {
                control,
                initial,
                ending,
                step,
                body,
            } => self.counted_loop(
                &CountedLoop {
                    control: *control,
                    initial: *initial,
                    ending: *ending,
                    step: *step,
                    body,
                },
                lines,
            ),
            _ => self.control_rest(statement, span, lines),
        }
    }

    pub(crate) fn control_rest(
        &mut self,
        statement: &HirStatement,
        span: Span,
        lines: &mut CodeLines,
    ) {
        match statement {
            HirStatement::Switch {
                selector,
                cases,
                default,
            } => {
                self.switch((*selector, cases, default), lines);
            }
            HirStatement::ForEach {
                collection,
                bindings,
                body,
            } => {
                self.for_each((*collection, bindings, body), lines);
            }
            HirStatement::VariantMatch(matching) => self.variant_match(matching, lines),
            HirStatement::TaskScope { failure, body } => {
                self.task_scope((*failure, body), span, lines)
            }
            HirStatement::Select(selection) => self.select(selection, span, lines),
            _ => {
                self.block("statement", span);
            }
        }
    }

    pub(crate) fn conditional(
        &mut self,
        condition: ExpressionId,
        (affirmative, negative): (&[StatementId], &[StatementId]),
        lines: &mut CodeLines,
    ) {
        let condition_text = self.expression(condition);
        lines.open(&format!("if {condition_text} {{"));
        self.statements(affirmative, lines);
        if negative.is_empty() {
            lines.close("}");
            return;
        }
        if let [single] = negative
            && let Some(HirStatement::Conditional {
                condition,
                affirmative,
                negative,
            }) = self.view.statement(*single)
        {
            let nested = self.expression(*condition);
            lines.dedent();
            lines.open(&format!("}} else if {nested} {{"));
            self.statements(affirmative, lines);
            self.else_tail(negative, lines);
            return;
        }
        self.else_tail(negative, lines);
    }

    pub(crate) fn else_tail(&mut self, negative: &[StatementId], lines: &mut CodeLines) {
        if negative.is_empty() {
            lines.close("}");
            return;
        }
        lines.dedent();
        lines.open("} else {");
        self.statements(negative, lines);
        lines.close("}");
    }

    pub(crate) fn literal_integer(&self, expression: ExpressionId) -> Option<i64> {
        match self.view.expression(expression) {
            HirExpression::Literal(Literal::Integer(value)) => Some(*value),
            HirExpression::Unary { operand, .. } => {
                self.literal_integer(*operand).map(i64::wrapping_neg)
            }
            _ => None,
        }
    }

    pub(crate) fn switch(
        &mut self,
        (selector, cases, default): (ExpressionId, &[HirCase], &[StatementId]),
        lines: &mut CodeLines,
    ) {
        let literal = cases
            .iter()
            .flat_map(|case| case.labels.iter())
            .all(|label| {
                matches!(self.view.expression(*label), HirExpression::Literal(_))
                    || self.literal_integer(*label).is_some()
            });
        if !literal {
            self.switch_chain((selector, cases, default), lines);
            return;
        }
        let selector_text = self.expression(selector);
        let textual = matches!(self.view.expression_type(selector), Type::String);
        let subject = if textual {
            format!("{selector_text}.as_str()")
        } else {
            selector_text
        };
        lines.open(&format!("match {subject} {{"));
        for case in cases {
            let labels = case
                .labels
                .iter()
                .map(|label| self.pattern_text(*label))
                .collect::<Vec<_>>()
                .join(" | ");
            lines.open(&format!("{labels} => {{"));
            self.statements(&case.body, lines);
            lines.close("}");
        }
        lines.open("_ => {");
        self.statements(default, lines);
        lines.close("}");
        lines.close("}");
    }

    pub(crate) fn switch_chain(
        &mut self,
        (selector, cases, default): (ExpressionId, &[HirCase], &[StatementId]),
        lines: &mut CodeLines,
    ) {
        let selector_text = self.value(selector);
        lines.line(&format!("let selected = {selector_text};"));
        for (position, case) in cases.iter().enumerate() {
            let condition = case
                .labels
                .iter()
                .map(|label| format!("selected == {}", self.expression(*label)))
                .collect::<Vec<_>>()
                .join(" || ");
            if position == 0 {
                lines.open(&format!("if {condition} {{"));
            } else {
                lines.dedent();
                lines.open(&format!("}} else if {condition} {{"));
            }
            self.statements(&case.body, lines);
        }
        if cases.is_empty() {
            self.statements(default, lines);
            return;
        }
        self.else_tail(default, lines);
    }

    pub(crate) fn pattern_text(&mut self, label: ExpressionId) -> String {
        match self.view.expression(label) {
            HirExpression::Literal(Literal::String(text)) => format!("{text:?}"),
            HirExpression::Literal(_) => self.expression(label),
            _ => self
                .literal_integer(label)
                .map(|value| value.to_string())
                .unwrap_or_default(),
        }
    }
}

impl RustEmitter<'_, '_> {
    pub(crate) fn element_copies(&self, collection: ExpressionId) -> bool {
        match self.view.expression_type(collection) {
            Type::Array { element, .. } => self.is_copy(element),
            Type::Object(class) => self
                .view
                .module
                .collections
                .get(&class)
                .is_some_and(|entry| self.is_copy(entry.value)),
            _ => false,
        }
    }
}
