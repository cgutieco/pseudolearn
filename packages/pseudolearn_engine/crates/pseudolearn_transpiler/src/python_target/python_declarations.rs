use super::PythonEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::{python_value_name, type_name};
use crate::module_view::RecordRole;
use pseudolearn_semantic::hir::HirRecord;
use pseudolearn_semantic::variant_model::HirUserVariant;
use pseudolearn_semantic::{RecordId, Type, TypeId};

impl PythonEmitter<'_, '_> {
    pub(crate) fn declarations(&mut self, lines: &mut CodeLines) {
        for (index, entry) in self.view.module.enums.iter().enumerate() {
            let builtin = self
                .view
                .module
                .builtin_enums
                .values()
                .any(|builtin| usize::try_from(builtin.0).ok() == Some(index));
            if !builtin {
                self.enumeration(&entry.name, &entry.members, lines);
            }
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
        (matches!(self.view.record_role(identifier), RecordRole::Plain(entry) if !entry.fields.is_empty())
            || matches!(self.view.record_role(identifier), RecordRole::TaskFailure))
            && !self.view.module.user_variants.values().any(|variant| {
                variant
                    .alternatives
                    .iter()
                    .any(|alternative| alternative.payload == Some(identifier))
            })
    }

    pub(crate) fn enum_name(&self, identifier: u32) -> String {
        usize::try_from(identifier)
            .ok()
            .and_then(|index| self.view.module.enums.get(index))
            .map_or_else(
                || format!("Enumeration{identifier}"),
                |entry| type_name(&entry.name),
            )
    }

    pub(crate) fn record_name(&self, record: RecordId) -> String {
        let name = self
            .view
            .module
            .user_variants
            .get(&record)
            .map(|variant| variant.name.clone())
            .or_else(|| self.view.record(record).map(|entry| entry.name.clone()))
            .unwrap_or_default();
        let spelled = type_name(&name);
        let first = self
            .view
            .module
            .records
            .iter()
            .enumerate()
            .find(|(index, entry)| {
                let identifier = RecordId(u32::try_from(*index).unwrap_or(u32::MAX));
                let shown = self
                    .view
                    .module
                    .user_variants
                    .get(&identifier)
                    .map_or(entry.name.as_str(), |variant| variant.name.as_str());
                type_name(shown) == spelled
                    && (self.is_plain_record(identifier)
                        || self.view.module.user_variants.contains_key(&identifier))
            });
        match first {
            Some((index, _)) if u32::try_from(index).ok() != Some(record.0) => {
                format!("{spelled}{}", record.0)
            }
            _ => spelled,
        }
    }

    pub(crate) fn enumeration(&mut self, name: &str, members: &[String], lines: &mut CodeLines) {
        self.require("enum");
        lines.open(&format!("class {}(Enum):", type_name(name)));
        if members.is_empty() {
            lines.line("pass");
        }
        for member in members {
            lines.line(&format!("{} = {member:?}", type_name(member)));
        }
        lines.blank();
        lines.open("def __str__(self):");
        lines.line("return self.value");
        lines.close("");
        lines.dedent();
        lines.blank();
    }

    pub(crate) fn user_variant(
        &mut self,
        identifier: RecordId,
        variant: &HirUserVariant,
        lines: &mut CodeLines,
    ) {
        self.require("dataclass");
        lines.open(&format!("class {}:", self.record_name(identifier)));
        for alternative in &variant.alternatives {
            lines.line("@dataclass");
            lines.open(&format!("class {}:", type_name(&alternative.spelling)));
            let fields = alternative
                .payload
                .and_then(|payload| self.view.record(payload))
                .map(|payload| payload.fields.clone())
                .unwrap_or_default();
            if fields.is_empty() {
                lines.line("pass");
            }
            for field in &fields {
                lines.line(&format!("{}: object", python_value_name(&field.name)));
            }
            lines.dedent();
            lines.blank();
        }
        lines.dedent();
        lines.blank();
    }

    pub(crate) fn record_declaration(
        &mut self,
        identifier: RecordId,
        record: &HirRecord,
        lines: &mut CodeLines,
    ) {
        self.require("dataclass");
        let name = self.record_name(identifier);
        lines.line("@dataclass");
        lines.open(&format!("class {name}:"));
        for field in &record.fields {
            let default = self.default_value(field.type_id);
            let default = if default.ends_with(')') && !default.starts_with("None") {
                format!("field(default_factory=lambda: {default})")
            } else {
                default
            };
            lines.line(&format!(
                "{}: object = {default}",
                python_value_name(&field.name)
            ));
        }
        lines.blank();
        self.record_copy(&name, record, lines);
        lines.dedent();
        lines.blank();
    }

    pub(crate) fn record_copy(&self, name: &str, record: &HirRecord, lines: &mut CodeLines) {
        lines.open("def copy(self):");
        let copies = record
            .fields
            .iter()
            .map(|field| {
                let name = python_value_name(&field.name);
                if self.is_record(field.type_id) {
                    format!("self.{name}.copy()")
                } else {
                    format!("self.{name}")
                }
            })
            .collect::<Vec<_>>()
            .join(", ");
        lines.line(&format!("return {name}({copies})"));
        lines.dedent();
    }

    pub(crate) fn is_record(&self, type_id: TypeId) -> bool {
        matches!(self.view.representation(type_id), Type::Record(record) if self.is_plain_record(record))
    }

    pub(crate) fn default_value(&self, type_id: TypeId) -> String {
        match self.view.representation(type_id) {
            Type::Integer => "0".to_owned(),
            Type::Real => "0.0".to_owned(),
            Type::Boolean => "False".to_owned(),
            Type::Character => "'\\0'".to_owned(),
            Type::String => "\"\"".to_owned(),
            Type::Enum(identifier) => {
                let first = usize::try_from(identifier.0)
                    .ok()
                    .and_then(|index| self.view.module.enums.get(index))
                    .and_then(|entry| entry.members.first().cloned());
                match first {
                    Some(member) => {
                        format!("{}.{}", self.enum_name(identifier.0), type_name(&member))
                    }
                    None => "None".to_owned(),
                }
            }
            Type::Record(record) if self.is_plain_record(record) => {
                format!("{}()", self.record_name(record))
            }
            _ => "None".to_owned(),
        }
    }
}
