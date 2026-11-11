use super::RustEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::rust_type_name;
use pseudolearn_semantic::{RecordId, Type, TypeId};

impl RustEmitter<'_, '_> {
    pub(crate) fn write_snapshot_implementations(&self, lines: &mut CodeLines) {
        for (index, entry) in self.view.module.enums.iter().enumerate() {
            if self.is_user_enumeration(index) {
                self.write_enumeration_snapshot(&rust_type_name(&entry.name), lines);
            }
        }
        for (identifier, variant) in &self.view.module.user_variants {
            if self.is_snapshottable_user_variant(*identifier) {
                self.write_variant_snapshot(*identifier, variant, lines);
            }
        }
        for (index, record) in self.view.module.records.iter().enumerate() {
            let identifier = RecordId(u32::try_from(index).unwrap_or(u32::MAX));
            if self.is_snapshottable_plain_record(identifier) {
                self.write_record_snapshot(identifier, record, lines);
            }
        }
    }

    fn is_user_enumeration(&self, index: usize) -> bool {
        !self
            .view
            .module
            .builtin_enums
            .values()
            .any(|builtin| usize::try_from(builtin.0).ok() == Some(index))
    }

    fn is_snapshottable_plain_record(&self, identifier: RecordId) -> bool {
        self.is_plain_record(identifier)
            && self.view.record(identifier).is_some_and(|entry| {
                entry
                    .fields
                    .iter()
                    .all(|field| self.is_snapshottable(field.type_id))
            })
    }

    fn is_snapshottable_user_variant(&self, identifier: RecordId) -> bool {
        !self.view.is_template_variant(identifier)
            && self
                .view
                .module
                .user_variants
                .get(&identifier)
                .is_some_and(|variant| {
                    variant.alternatives.iter().all(|alternative| {
                        alternative
                            .payload
                            .and_then(|payload| self.view.record(payload))
                            .is_none_or(|payload| {
                                payload
                                    .fields
                                    .iter()
                                    .all(|field| self.is_snapshottable(field.type_id))
                            })
                    })
                })
    }

    fn is_snapshottable(&self, type_id: TypeId) -> bool {
        match self.view.representation(type_id) {
            Type::Integer | Type::Real | Type::Boolean | Type::Character | Type::String => true,
            Type::Enum(identifier) => {
                self.is_user_enumeration(usize::try_from(identifier.0).unwrap_or(usize::MAX))
            }
            Type::Record(record) => {
                self.is_snapshottable_plain_record(record)
                    || self.is_snapshottable_user_variant(record)
            }
            Type::Object(class) => self
                .view
                .module
                .collections
                .get(&class)
                .is_some_and(|collection| {
                    collection.key.is_none_or(|key| self.is_snapshottable(key))
                        && self.is_snapshottable(collection.value)
                }),
            _ => false,
        }
    }

    fn write_enumeration_snapshot(&self, name: &str, lines: &mut CodeLines) {
        lines.blank();
        lines.open(&format!("impl Snapshot for {name} {{"));
        lines.open("fn snapshot(&self) -> Self {");
        lines.line("*self");
        lines.close("}");
        lines.close("}");
    }

    fn write_record_snapshot(
        &self,
        identifier: RecordId,
        record: &pseudolearn_semantic::hir::HirRecord,
        lines: &mut CodeLines,
    ) {
        let name = self.unique_record_name(identifier, &record.name);
        lines.blank();
        lines.open(&format!("impl Snapshot for {name} {{"));
        lines.open("fn snapshot(&self) -> Self {");
        lines.open(&format!("{name} {{"));
        for field in &record.fields {
            let field = self.names.field(&field.name);
            lines.line(&format!("{field}: self.{field}.snapshot(),"));
        }
        lines.close("}");
        lines.close("}");
        lines.close("}");
    }

    fn write_variant_snapshot(
        &self,
        identifier: RecordId,
        variant: &pseudolearn_semantic::variant_model::HirUserVariant,
        lines: &mut CodeLines,
    ) {
        let name = self.user_variant_name(identifier);
        lines.blank();
        lines.open(&format!("impl Snapshot for {name} {{"));
        lines.open("fn snapshot(&self) -> Self {");
        lines.open("match self {");
        for alternative in &variant.alternatives {
            let label = rust_type_name(&alternative.spelling);
            let fields = alternative
                .payload
                .and_then(|payload| self.view.record(payload))
                .map(|payload| {
                    payload
                        .fields
                        .iter()
                        .map(|field| self.names.field(&field.name))
                        .collect::<Vec<_>>()
                })
                .unwrap_or_default();
            if fields.is_empty() {
                lines.line(&format!("{name}::{label} => {name}::{label},"));
                continue;
            }
            let bindings = fields.join(", ");
            let copies = fields
                .iter()
                .map(|field| format!("{field}: {field}.snapshot()"))
                .collect::<Vec<_>>()
                .join(", ");
            lines.line(&format!(
                "{name}::{label} {{ {bindings} }} => {name}::{label} {{ {copies} }},"
            ));
        }
        lines.close("}");
        lines.close("}");
        lines.close("}");
    }
}
