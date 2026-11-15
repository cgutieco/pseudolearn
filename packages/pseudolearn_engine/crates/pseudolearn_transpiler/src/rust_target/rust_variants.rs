use super::RustEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::rust_type_name;
use pseudolearn_semantic::variant_model::{HirVariantMatch, VariantFamily};
use pseudolearn_semantic::{
    ExpressionId, HirCase, HirExpression, HirPlace, HirStatement, Literal, LocalId, RecordId,
    StatementId,
};
use pseudolearn_source::Span;

pub(crate) struct Binding {
    pub(crate) local: LocalId,
    pub(crate) offset: Option<u32>,
}

impl RustEmitter<'_, '_> {
    pub(crate) fn variant_new(
        &mut self,
        (record, alternative): (RecordId, u32),
        payload: Option<ExpressionId>,
        span: Span,
    ) -> String {
        let payload_text = payload.map(|value| self.value(value));
        match (self.view.variant_family(record), alternative, payload_text) {
            (Some(VariantFamily::Optional), 0, _) => "None".to_owned(),
            (Some(VariantFamily::Optional), _, Some(text)) => format!("Some({text})"),
            (Some(VariantFamily::Result), 0, Some(text)) => format!("Ok({text})"),
            (Some(VariantFamily::Result), _, Some(text)) => format!("Err({text})"),
            (Some(VariantFamily::User), _, _) => {
                self.user_variant_value((record, alternative), payload, span)
            }
            _ => self.block("variant_construction", span),
        }
    }

    pub(crate) fn user_variant_value(
        &mut self,
        (record, alternative): (RecordId, u32),
        payload: Option<ExpressionId>,
        span: Span,
    ) -> String {
        let enum_name = self.user_variant_name(record);
        let Some(entry) = self.user_alternative(record, alternative) else {
            return self.block("variant_construction", span);
        };
        let label = rust_type_name(&entry.spelling);
        let Some(payload) = payload else {
            return format!("{enum_name}::{label}");
        };
        let HirExpression::RecordNew {
            record: payload_record,
            fields,
        } = self.view.expression(payload)
        else {
            return self.block("variant_construction", span);
        };
        let names = self.payload_field_names(*payload_record);
        let assignments = names
            .iter()
            .zip(fields)
            .map(|(name, value)| format!("{name}: {}", self.value(*value)))
            .collect::<Vec<_>>()
            .join(", ");
        format!("{enum_name}::{label} {{ {assignments} }}")
    }

    pub(crate) fn variant_match(&mut self, matching: &HirVariantMatch, lines: &mut CodeLines) {
        let Some(record) = self.expression_record(matching.value) else {
            self.block("variant_pattern", self.view.expression_span(matching.value));
            return;
        };
        let subject = self.value(matching.value);
        lines.open(&format!("match {subject} {{"));
        for case in &matching.cases {
            self.variant_case((record, matching.storage), case, lines);
        }
        if !matching.default.is_empty() || matching.cases.len() < self.alternative_count(record) {
            lines.open("_ => {");
            self.statements(&matching.default, lines);
            lines.close("}");
        }
        lines.close("}");
    }

    pub(crate) fn alternative_count(&self, record: RecordId) -> usize {
        self.view
            .module
            .variants
            .get(&record)
            .map_or(0, |variant| variant.payloads.len())
    }

    pub(crate) fn variant_case(
        &mut self,
        (record, storage): (RecordId, LocalId),
        case: &HirCase,
        lines: &mut CodeLines,
    ) {
        let (bindings, rest) = self.leading_bindings(storage, &case.body);
        let patterns = case
            .labels
            .iter()
            .filter_map(|label| match self.view.expression(*label) {
                HirExpression::Literal(Literal::Integer(alternative)) => Some(*alternative),
                _ => None,
            })
            .map(|alternative| self.variant_pattern(record, alternative, &bindings))
            .collect::<Vec<_>>()
            .join(" | ");
        for binding in &bindings {
            self.scope.declared.insert(binding.local);
        }
        lines.open(&format!("{patterns} => {{"));
        self.statements(rest, lines);
        lines.close("}");
    }

    pub(crate) fn user_alternative(
        &self,
        record: RecordId,
        alternative: impl TryInto<usize>,
    ) -> Option<&pseudolearn_semantic::variant_model::HirUserAlternative> {
        let index = alternative.try_into().ok()?;
        self.view
            .module
            .user_variants
            .get(&record)?
            .alternatives
            .get(index)
    }

    pub(crate) fn payload_field_names(&self, record: RecordId) -> Vec<String> {
        self.view
            .record(record)
            .map(|entry| {
                entry
                    .fields
                    .iter()
                    .map(|field| self.names.field(&field.name))
                    .collect()
            })
            .unwrap_or_default()
    }

    pub(crate) fn binding_offset(
        &self,
        value: ExpressionId,
        storage: LocalId,
    ) -> Option<Option<u32>> {
        match self.view.expression(value) {
            HirExpression::VariantPayload { value: source, .. }
                if self.reads_local(*source, storage) =>
            {
                Some(None)
            }
            HirExpression::RecordField { record, offset } => match self.view.expression(*record) {
                HirExpression::VariantPayload { value: source, .. }
                    if self.reads_local(*source, storage) =>
                {
                    Some(Some(*offset))
                }
                _ => None,
            },
            _ => None,
        }
    }

    pub(crate) fn leading_bindings<'body>(
        &self,
        storage: LocalId,
        body: &'body [StatementId],
    ) -> (Vec<Binding>, &'body [StatementId]) {
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
            let Some(offset) = self.binding_offset(*value, storage) else {
                break;
            };
            bindings.push(Binding {
                local: *local,
                offset,
            });
            consumed = consumed.saturating_add(1);
        }
        (bindings, body.get(consumed..).unwrap_or_default())
    }

    pub(crate) fn reads_local(&self, expression: ExpressionId, local: LocalId) -> bool {
        matches!(self.view.expression(expression), HirExpression::Local(found) if *found == local)
    }

    pub(crate) fn variant_pattern(
        &self,
        record: RecordId,
        alternative: i64,
        bindings: &[Binding],
    ) -> String {
        let whole = bindings
            .iter()
            .find(|binding| binding.offset.is_none())
            .map_or_else(|| "_".to_owned(), |binding| self.local_name(binding.local));
        match (self.view.variant_family(record), alternative) {
            (Some(VariantFamily::Optional), 0) => "None".to_owned(),
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
        bindings: &[Binding],
    ) -> String {
        let enum_name = self.user_variant_name(record);
        let Some(entry) = self.user_alternative(record, alternative) else {
            return "_".to_owned();
        };
        let label = rust_type_name(&entry.spelling);
        let Some(payload) = entry.payload.and_then(|payload| self.view.record(payload)) else {
            return format!("{enum_name}::{label}");
        };
        let fields = payload
            .fields
            .iter()
            .map(|field| {
                let bound = bindings
                    .iter()
                    .find(|binding| binding.offset == Some(field.offset));
                let name = self.names.field(&field.name);
                match bound {
                    Some(binding) => format!("{name}: {}", self.local_name(binding.local)),
                    None => format!("{name}: _"),
                }
            })
            .collect::<Vec<_>>()
            .join(", ");
        format!("{enum_name}::{label} {{ {fields} }}")
    }
}
