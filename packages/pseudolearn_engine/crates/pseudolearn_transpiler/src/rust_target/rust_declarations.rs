use super::RustEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::{rust_value_name, type_name};
use crate::module_view::RecordRole;
use pseudolearn_semantic::hir::HirRecord;
use pseudolearn_semantic::variant_model::HirUserVariant;
use pseudolearn_semantic::{RecordId, Type, TypeId};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn declarations(&mut self, lines: &mut CodeLines) {
        for (index, entry) in self.view.module.enums.iter().enumerate() {
            if self
                .view
                .module
                .builtin_enums
                .values()
                .any(|builtin| usize::try_from(builtin.0).ok() == Some(index))
            {
                continue;
            }
            self.enumeration(&entry.name, &entry.members, lines);
        }
        for (identifier, variant) in &self.view.module.user_variants {
            if self.view.is_template_variant(*identifier) {
                continue;
            }
            self.user_variant(*identifier, variant, lines);
        }
        for (index, record) in self.view.module.records.iter().enumerate() {
            let identifier = RecordId(u32::try_from(index).unwrap_or(u32::MAX));
            if self.is_plain_record(identifier) {
                self.record_declaration(identifier, record, lines);
            }
        }
    }

    pub(crate) fn is_plain_record(&self, identifier: RecordId) -> bool {
        matches!(self.view.record_role(identifier), RecordRole::Plain(entry) if !entry.fields.is_empty())
            && !self.view.module.user_variants.values().any(|variant| {
                variant
                    .alternatives
                    .iter()
                    .any(|alternative| alternative.payload == Some(identifier))
            })
    }

    pub(crate) fn enumeration(&mut self, name: &str, members: &[String], lines: &mut CodeLines) {
        let enum_name = type_name(name);
        if members.is_empty() {
            lines.line("#[derive(Clone, Copy, PartialEq, Eq)]");
        } else {
            lines.line("#[derive(Clone, Copy, Default, PartialEq, Eq)]");
        }
        lines.open(&format!("enum {enum_name} {{"));
        for (position, member) in members.iter().enumerate() {
            if position == 0 {
                lines.line("#[default]");
            }
            lines.line(&format!("{},", type_name(member)));
        }
        lines.close("}");
        lines.blank();
        lines.open(&format!("impl std::fmt::Display for {enum_name} {{"));
        lines.open("fn fmt(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {");
        lines.open("let name = match self {");
        for member in members {
            lines.line(&format!(
                "{enum_name}::{} => {member:?},",
                type_name(member)
            ));
        }
        lines.close("};");
        lines.line("formatter.write_str(name)");
        lines.close("}");
        lines.close("}");
        lines.blank();
    }

    pub(crate) fn user_variant(
        &mut self,
        identifier: RecordId,
        variant: &HirUserVariant,
        lines: &mut CodeLines,
    ) {
        let name = self.user_variant_name(identifier);
        lines.line("#[derive(Clone, PartialEq)]");
        lines.open(&format!("enum {name} {{"));
        for alternative in &variant.alternatives {
            let fields = alternative
                .payload
                .and_then(|payload| self.view.record(payload))
                .map(|payload| self.field_list(payload, Span::default()));
            let label = type_name(&alternative.spelling);
            match fields {
                Some(fields) => lines.line(&format!("{label} {{ {} }},", fields.join(", "))),
                None => lines.line(&format!("{label},")),
            }
        }
        lines.close("}");
        lines.blank();
    }

    pub(crate) fn field_list(&mut self, record: &HirRecord, span: Span) -> Vec<String> {
        record
            .fields
            .iter()
            .map(|field| {
                let type_text = self.type_text(field.type_id, span);
                format!("{}: {type_text}", rust_value_name(&field.name))
            })
            .collect()
    }

    pub(crate) fn record_declaration(
        &mut self,
        identifier: RecordId,
        record: &HirRecord,
        lines: &mut CodeLines,
    ) {
        let defaultable = record
            .fields
            .iter()
            .all(|field| self.has_default(field.type_id));
        let comparable = record
            .fields
            .iter()
            .all(|field| self.is_comparable(field.type_id));
        let mut derives = vec!["Clone"];
        if defaultable {
            derives.push("Default");
        }
        if comparable {
            derives.push("PartialEq");
        }
        lines.line(&format!("#[derive({})]", derives.join(", ")));
        lines.open(&format!(
            "struct {} {{",
            self.unique_record_name(identifier, &record.name)
        ));
        for field in self.field_list(record, Span::default()) {
            lines.line(&format!("{field},"));
        }
        lines.close("}");
        lines.blank();
    }

    pub(crate) fn has_default(&self, type_id: TypeId) -> bool {
        match self.view.representation(type_id) {
            Type::Integer | Type::Real | Type::Boolean | Type::Character | Type::String => true,
            Type::Enum(_) => true,
            Type::Array { .. } => true,
            Type::Record(record) => self.view.record(record).is_some_and(|entry| {
                self.is_plain_record(record)
                    && entry
                        .fields
                        .iter()
                        .all(|field| self.has_default(field.type_id))
            }),
            Type::Object(class) => self.view.module.collections.contains_key(&class),
            _ => false,
        }
    }

    pub(crate) fn is_comparable(&self, type_id: TypeId) -> bool {
        match self.view.representation(type_id) {
            Type::Integer | Type::Real | Type::Boolean | Type::Character | Type::String => true,
            Type::Enum(_) => true,
            Type::Record(record) => self.view.record(record).is_some_and(|entry| {
                entry
                    .fields
                    .iter()
                    .all(|field| self.is_comparable(field.type_id))
            }),
            _ => false,
        }
    }
}
