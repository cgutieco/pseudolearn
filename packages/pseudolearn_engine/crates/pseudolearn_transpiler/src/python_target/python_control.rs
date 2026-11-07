use super::PythonEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::{
    ExpressionId, HirCase, HirExpression, HirStatement, Literal, LocalId, StatementId, Type,
};
use pseudolearn_source::Span;

impl PythonEmitter<'_, '_> {
    pub(crate) fn control(&mut self, statement: &HirStatement, span: Span, lines: &mut CodeLines) {
        match statement {
            HirStatement::Conditional {
                condition,
                affirmative,
                negative,
            } => {
                let condition_text = self.expression(*condition);
                lines.open(&format!("if {condition_text}:"));
                self.body(affirmative, lines);
                lines.dedent();
                self.else_branch(negative, lines);
            }
            HirStatement::While { condition, body } => {
                let condition_text = self.expression(*condition);
                lines.open(&format!("while {condition_text}:"));
                self.body(body, lines);
                lines.dedent();
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
                lines.open("while True:");
                self.body(body, lines);
                let condition_text = self.expression(*condition);
                lines.open(&format!("if {condition_text}:"));
                lines.line("break");
                lines.dedent();
                lines.dedent();
            }
            HirStatement::For {
                control,
                initial,
                ending,
                step,
                body,
            } => {
                let range = self.counted_range(*initial, *ending, *step);
                lines.open(&format!("for {} in {range}:", self.local_name(*control)));
                self.body(body, lines);
                lines.dedent();
            }
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
            } => self.switch((*selector, cases, default), lines),
            HirStatement::ForEach {
                collection,
                bindings,
                body,
            } => self.for_each((*collection, bindings, body), lines),
            HirStatement::VariantMatch(matching) => self.variant_match(matching, lines),
            HirStatement::TaskScope { failure, body } => {
                self.task_scope((*failure, body), span, lines)
            }
            _ => {
                self.block("statement", span);
            }
        }
    }

    pub(crate) fn else_branch(&mut self, negative: &[StatementId], lines: &mut CodeLines) {
        if negative.is_empty() {
            return;
        }
        if let [single] = negative
            && let Some(HirStatement::Conditional {
                condition,
                affirmative,
                negative,
            }) = self.view.statement(*single)
        {
            let condition_text = self.expression(*condition);
            lines.open(&format!("elif {condition_text}:"));
            self.body(affirmative, lines);
            lines.dedent();
            self.else_branch(negative, lines);
            return;
        }
        lines.open("else:");
        self.body(negative, lines);
        lines.dedent();
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

    pub(crate) fn counted_range(
        &mut self,
        initial: ExpressionId,
        ending: ExpressionId,
        step: Option<ExpressionId>,
    ) -> String {
        let initial_text = self.expression(initial);
        let ending_text = self.operand(ending, 6);
        let amount = step.map_or(Some(1), |step| self.literal_integer(step));
        match amount {
            Some(1) => format!("range({initial_text}, {ending_text} + 1)"),
            Some(value) if value > 1 => {
                format!("range({initial_text}, {ending_text} + 1, {value})")
            }
            Some(value) if value < 0 => {
                format!("range({initial_text}, {ending_text} - 1, {value})")
            }
            _ => {
                let step_text = step.map_or_else(|| "1".to_owned(), |step| self.expression(step));
                self.require("counted_range");
                format!(
                    "counted_range({initial_text}, {}, {step_text})",
                    self.expression(ending)
                )
            }
        }
    }

    pub(crate) fn switch(
        &mut self,
        (selector, cases, default): (ExpressionId, &[HirCase], &[StatementId]),
        lines: &mut CodeLines,
    ) {
        let selector_text = self.expression(selector);
        let selected = self.temporary("selected");
        lines.line(&format!("{selected} = {selector_text}"));
        for (position, case) in cases.iter().enumerate() {
            let condition = case
                .labels
                .iter()
                .map(|label| format!("{selected} == {}", self.operand(*label, 5)))
                .collect::<Vec<_>>()
                .join(" or ");
            let keyword = if position == 0 { "if" } else { "elif" };
            lines.open(&format!("{keyword} {condition}:"));
            self.body(&case.body, lines);
            lines.dedent();
        }
        if !default.is_empty() {
            if cases.is_empty() {
                self.body(default, lines);
                return;
            }
            lines.open("else:");
            self.body(default, lines);
            lines.dedent();
        }
    }

    pub(crate) fn for_each(
        &mut self,
        (collection, bindings, body): (ExpressionId, &[LocalId], &[StatementId]),
        lines: &mut CodeLines,
    ) {
        let names = bindings
            .iter()
            .map(|binding| self.local_name(*binding))
            .collect::<Vec<_>>();
        let source = self.operand(collection, 10);
        let keyed = match self.view.expression_type(collection) {
            Type::Object(class) => self
                .view
                .module
                .collections
                .get(&class)
                .is_some_and(|entry| entry.key.is_some()),
            _ => false,
        };
        if keyed {
            lines.open(&format!(
                "for {} in list({source}.items()):",
                names.join(", ")
            ));
        } else {
            let single = names.first().cloned().unwrap_or_else(|| "_".to_owned());
            lines.open(&format!("for position in range(len({source})):"));
            lines.line(&format!("{single} = {source}[position]"));
        }
        self.body(body, lines);
        lines.dedent();
    }
}
