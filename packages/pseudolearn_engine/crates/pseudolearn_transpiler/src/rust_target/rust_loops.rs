use super::RustEmitter;
use super::rust_control::CountedLoop;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::{ExpressionId, LocalId, StatementId, Type};

impl RustEmitter<'_, '_> {
    pub(crate) fn counted_loop(&mut self, counted: &CountedLoop<'_>, lines: &mut CodeLines) {
        self.scope.declared.insert(counted.control);
        let name = self.local_name(counted.control);
        let initial = self.expression(counted.initial);
        let ending = self.expression(counted.ending);
        let step = counted
            .step
            .map_or(Some(1), |step| self.literal_integer(step));
        match step {
            Some(1) => lines.open(&format!("for {name} in {initial}..={ending} {{")),
            Some(amount) if amount > 1 => {
                lines.open(&format!(
                    "for {name} in ({initial}..={ending}).step_by({amount}) {{"
                ));
            }
            Some(-1) => lines.open(&format!("for {name} in ({ending}..={initial}).rev() {{")),
            Some(amount) if amount < 0 => lines.open(&format!(
                "for {name} in ({ending}..={initial}).rev().step_by({}) {{",
                amount.unsigned_abs()
            )),
            _ => {
                let step_text = counted
                    .step
                    .map_or_else(|| "1".to_owned(), |step| self.expression(step));
                let helper = self.require("counted_range");
                lines.open(&format!(
                    "for {name} in {helper}({initial}, {ending}, {step_text}) {{"
                ));
            }
        }
        self.loop_body(counted.body, lines);
        lines.close("}");
    }

    pub(crate) fn sequence_loop(
        &mut self,
        (collection, source, single): (ExpressionId, &str, &str),
        body: &[StatementId],
        lines: &mut CodeLines,
    ) {
        let shared = matches!(self.view.expression_type(collection), Type::Object(_));
        let access = if shared {
            format!("{source}.borrow()")
        } else {
            source.to_owned()
        };
        let copy = if self.element_copies(collection) {
            ""
        } else {
            ".clone()"
        };
        if shared {
            lines.line(&format!("let count = {access}.len();"));
            lines.open("for position in 0..count {");
        } else {
            lines.open(&format!("for position in 0..{access}.len() {{"));
        }
        lines.line(&format!("let {single} = {access}[position]{copy};"));
        self.loop_body(body, lines);
        lines.close("}");
    }

    pub(crate) fn for_each(
        &mut self,
        (collection, bindings, body): (ExpressionId, &[LocalId], &[StatementId]),
        lines: &mut CodeLines,
    ) {
        self.scope.declared.extend(bindings.iter().copied());
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
        if !keyed && let [single] = names.as_slice() {
            self.sequence_loop((collection, &source, single), body, lines);
            return;
        }
        let iterated = format!("{source}.borrow().entries()");
        let pattern = format!("({})", names.join(", "));
        lines.open(&format!("for {pattern} in {iterated} {{"));
        self.loop_body(body, lines);
        lines.close("}");
    }
}
