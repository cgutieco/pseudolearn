use super::RustEmitter;
use crate::identifier_spelling::rust_type_name;
use crate::module_view::RecordRole;
use pseudolearn_semantic::function_model::FunctionSignature;
use pseudolearn_semantic::variant_model::{HirVariant, VariantFamily};
use pseudolearn_semantic::{ClassId, Passing, RecordId, Type, TypeId};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn type_text(&mut self, type_id: TypeId, span: Span) -> String {
        match self.view.representation(type_id) {
            Type::Integer => "i64".to_owned(),
            Type::Real => "f64".to_owned(),
            Type::Boolean => "bool".to_owned(),
            Type::Character => "char".to_owned(),
            Type::String => "String".to_owned(),
            Type::Unit | Type::Never => "()".to_owned(),
            Type::Array { element, rank } => self.array_type(element, rank, span),
            Type::Object(class) => self.object_type(class, span),
            Type::Enum(identifier) => self.enum_name(identifier.0),
            Type::Record(record) => self.record_type(record, span),
            Type::Task(inner) => {
                self.require("tasks");
                format!("Task<{}>", self.type_text(inner, span))
            }
            Type::Immutable(_) | Type::Unknown | Type::Error => self.block("type:unknown", span),
        }
    }

    pub(crate) fn array_type(&mut self, element: TypeId, rank: u32, span: Span) -> String {
        let mut text = self.type_text(element, span);
        for _ in 0..rank {
            text = format!("Vec<{text}>");
        }
        text
    }

    pub(crate) fn enum_name(&self, identifier: u32) -> String {
        usize::try_from(identifier)
            .ok()
            .and_then(|index| self.view.module.enums.get(index))
            .map_or_else(
                || format!("Enumeration{identifier}"),
                |entry| rust_type_name(&entry.name),
            )
    }

    pub(crate) fn object_type(&mut self, class: ClassId, span: Span) -> String {
        if let Some(collection) = self.view.module.collections.get(&class) {
            self.uses.insert("rc");
            let value = self.type_text(collection.value, span);
            return match collection.key {
                Some(key) => {
                    self.require("dictionary");
                    let key = self.type_text(key, span);
                    format!("Rc<RefCell<Dictionary<{key}, {value}>>>")
                }
                None => format!("Rc<RefCell<Vec<{value}>>>"),
            };
        }
        if self.view.module.opaque_types.contains_key(&class) {
            return self.block("capability", span);
        }
        self.uses.insert("rc");
        let name = self.class_name(class);
        if self.is_polymorphic(class) {
            format!("Rc<RefCell<dyn {name}Kind>>")
        } else {
            format!("Rc<RefCell<{name}>>")
        }
    }

    pub(crate) fn class_name(&self, class: ClassId) -> String {
        if let Some(spelled) = self.names.class(class) {
            return spelled.to_owned();
        }
        self.view.class(class).map_or_else(
            || format!("Class{}", class.0),
            |entry| rust_type_name(&entry.name),
        )
    }

    pub(crate) fn is_polymorphic(&self, class: ClassId) -> bool {
        let has_parent = self
            .view
            .class(class)
            .is_some_and(|entry| entry.superclass.is_some());
        has_parent
            || self
                .view
                .module
                .classes
                .iter()
                .any(|entry| entry.superclass == Some(class))
    }

    pub(crate) fn record_type(&mut self, record: RecordId, span: Span) -> String {
        match self.view.record_role(record) {
            RecordRole::Plain(entry) => self.unique_record_name(record, &entry.name),
            RecordRole::Channel(element) => {
                self.require("channel");
                format!("Channel<{}>", self.type_text(element, span))
            }
            RecordRole::Variant(variant, identifier) => {
                self.variant_type(variant, identifier, span)
            }
            RecordRole::Function(signature) => self.function_type(signature, span),
            RecordRole::TaskFailure => {
                let name = self
                    .view
                    .record(record)
                    .map(|entry| entry.name.clone())
                    .unwrap_or_default();
                self.unique_record_name(record, &name)
            }
            RecordRole::Unknown => self.block("type:record", span),
        }
    }

    pub(crate) fn variant_type(
        &mut self,
        variant: &HirVariant,
        record: RecordId,
        span: Span,
    ) -> String {
        let payload = |index: usize| variant.payloads.get(index).copied().flatten();
        match variant.family {
            VariantFamily::Optional => match payload(1) {
                Some(inner) => format!("Option<{}>", self.type_text(inner, span)),
                None => self.block("type:optional", span),
            },
            VariantFamily::Result => match (payload(0), payload(1)) {
                (Some(success), Some(failure)) => format!(
                    "Result<{}, {}>",
                    self.type_text(success, span),
                    self.type_text(failure, span)
                ),
                _ => self.block("type:result", span),
            },
            VariantFamily::User => self.user_variant_name(record),
        }
    }

    pub(crate) fn user_variant_name(&self, record: RecordId) -> String {
        self.view.module.user_variants.get(&record).map_or_else(
            || format!("Variant{}", record.0),
            |entry| self.unique_record_name(record, &entry.name),
        )
    }

    pub(crate) fn unique_record_name(&self, record: RecordId, name: &str) -> String {
        let spelled = rust_type_name(name);
        let mut same = self
            .view
            .module
            .records
            .iter()
            .enumerate()
            .filter(|(index, entry)| {
                let identifier = RecordId(u32::try_from(*index).unwrap_or(u32::MAX));
                let shown = self
                    .view
                    .module
                    .user_variants
                    .get(&identifier)
                    .map_or(entry.name.as_str(), |variant| variant.name.as_str());
                rust_type_name(shown) == spelled
                    && (self.is_plain_record(identifier)
                        || self.view.module.user_variants.contains_key(&identifier))
            })
            .map(|(index, _)| index);
        let first = same.next();
        let position = usize::try_from(record.0).unwrap_or(usize::MAX);
        if first.is_none_or(|first| first == position) {
            return spelled;
        }
        format!("{spelled}{}", record.0)
    }

    pub(crate) fn function_type(&mut self, signature: &FunctionSignature, span: Span) -> String {
        self.uses.insert("rc");
        let parameters = signature
            .parameters
            .iter()
            .map(|(type_id, passing)| {
                let text = self.type_text(*type_id, span);
                match passing {
                    Passing::Value => text,
                    Passing::Reference => format!("&mut {text}"),
                }
            })
            .collect::<Vec<_>>()
            .join(", ");
        let result = self.type_text(signature.result, span);
        if result == "()" {
            format!("Rc<dyn Fn({parameters})>")
        } else {
            format!("Rc<dyn Fn({parameters}) -> {result}>")
        }
    }

    pub(crate) fn is_copy(&self, type_id: TypeId) -> bool {
        matches!(
            self.view.representation(type_id),
            Type::Integer
                | Type::Real
                | Type::Boolean
                | Type::Character
                | Type::Enum(_)
                | Type::Unit
        )
    }

    pub(crate) fn default_value(&mut self, type_id: TypeId, span: Span) -> Option<String> {
        match self.view.representation(type_id) {
            Type::Integer => Some("0".to_owned()),
            Type::Real => Some("0.0".to_owned()),
            Type::Boolean => Some("false".to_owned()),
            Type::Character => Some("'\\0'".to_owned()),
            Type::String => Some("String::new()".to_owned()),
            Type::Enum(identifier) => {
                let name = self.enum_name(identifier.0);
                Some(format!("{name}::default()"))
            }
            Type::Record(record)
                if matches!(self.view.record_role(record), RecordRole::Plain(_)) =>
            {
                Some(format!("{}::default()", self.record_type(record, span)))
            }
            Type::Object(class) if self.view.module.collections.contains_key(&class) => {
                Some(format!(
                    "{}::default()",
                    self.object_type(class, span).replace('<', "::<")
                ))
            }
            _ => None,
        }
    }
}
