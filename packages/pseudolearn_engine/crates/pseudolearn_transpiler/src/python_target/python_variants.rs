use super::PythonEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::python_type_name;
use pseudolearn_semantic::variant_model::{HirVariantMatch, VariantFamily};
use pseudolearn_semantic::{
    ExpressionId, HirExpression, HirPlace, HirStatement, LocalId, RecordId, StatementId, Type,
};

impl PythonEmitter<'_, '_> {
    pub(crate) fn variant_match(&mut self, matching: &HirVariantMatch, lines: &mut CodeLines) {
        let Type::Record(record) = self.view.expression_type(matching.value) else {
            self.block("variant_pattern", self.view.expression_span(matching.value));
            return;
        };
        let subject = self.expression(matching.value);
        lines.open(&format!("match {subject}:"));
        for case in &matching.cases {
            let (bindings, rest) = self.leading_bindings(matching.storage, &case.body);
            let alternatives = case
                .labels
                .iter()
                .filter_map(|label| self.literal_integer(*label))
                .collect::<Vec<_>>();
            let patterns = alternatives
                .into_iter()
                .map(|alternative| self.variant_pattern(record, alternative, &bindings))
                .collect::<Vec<_>>()
                .join(" | ");
            lines.open(&format!("case {patterns}:"));
            self.body(rest, lines);
            lines.dedent();
        }
        lines.open("case _:");
        self.body(&matching.default, lines);
        lines.dedent();
        lines.dedent();
    }

    pub(crate) fn leading_bindings<'body>(
        &self,
        storage: LocalId,
        body: &'body [StatementId],
    ) -> (Vec<(LocalId, Option<u32>)>, &'body [StatementId]) {
        let mut bindings = Vec::new();
        let mut consumed: usize = 0;
        for statement in body {
            let Some(HirStatement::Assign {
                destination: HirPlace::Local(local),
                value,
            }) = self.view.statement(*statement)
            else {
                break;
            };
            let offset = match self.view.expression(*value) {
                HirExpression::VariantPayload { value: source, .. }
                    if self.reads(*source, storage) =>
                {
                    None
                }
                HirExpression::RecordField { record, offset } => {
                    match self.view.expression(*record) {
                        HirExpression::VariantPayload { value: source, .. }
                            if self.reads(*source, storage) =>
                        {
                            Some(*offset)
                        }
                        _ => break,
                    }
                }
                _ => break,
            };
            bindings.push((*local, offset));
            consumed = consumed.saturating_add(1);
        }
        (bindings, body.get(consumed..).unwrap_or_default())
    }

    pub(crate) fn reads(&self, expression: ExpressionId, local: LocalId) -> bool {
        matches!(self.view.expression(expression), HirExpression::Local(found) if *found == local)
    }

    pub(crate) fn variant_pattern(
        &mut self,
        record: RecordId,
        alternative: i64,
        bindings: &[(LocalId, Option<u32>)],
    ) -> String {
        let whole = bindings
            .iter()
            .find(|(_, offset)| offset.is_none())
            .map_or_else(|| "_".to_owned(), |(local, _)| self.local_name(*local));
        self.require("variants");
        match (self.view.variant_family(record), alternative) {
            (Some(VariantFamily::Optional), 0) => "Nothing()".to_owned(),
            (Some(VariantFamily::Optional), _) => format!("Some({whole})"),
            (Some(VariantFamily::Result), 0) => format!("Ok({whole})"),
            (Some(VariantFamily::Result), _) => format!("Err({whole})"),
            _ => self.user_pattern(record, alternative, bindings),
        }
    }

    pub(crate) fn user_pattern(
        &self,
        record: RecordId,
        alternative: i64,
        bindings: &[(LocalId, Option<u32>)],
    ) -> String {
        let Some(entry) = self
            .view
            .module
            .user_variants
            .get(&record)
            .and_then(|variant| {
                usize::try_from(alternative)
                    .ok()
                    .and_then(|index| variant.alternatives.get(index))
            })
        else {
            return "_".to_owned();
        };
        let path = format!(
            "{}.{}",
            self.record_name(record),
            python_type_name(&entry.spelling)
        );
        let fields = entry
            .payload
            .and_then(|payload| self.view.record(payload))
            .map(|payload| self.payload_bindings(payload, bindings))
            .unwrap_or_default();
        format!("{path}({fields})")
    }

    pub(crate) fn payload_bindings(
        &self,
        payload: &pseudolearn_semantic::hir::HirRecord,
        bindings: &[(LocalId, Option<u32>)],
    ) -> String {
        payload
            .fields
            .iter()
            .filter_map(|field| {
                bindings
                    .iter()
                    .find(|(_, offset)| *offset == Some(field.offset))
                    .map(|(local, _)| {
                        format!(
                            "{}={}",
                            crate::identifier_spelling::python_value_name(&field.name),
                            self.local_name(*local)
                        )
                    })
            })
            .collect::<Vec<_>>()
            .join(", ")
    }
}
