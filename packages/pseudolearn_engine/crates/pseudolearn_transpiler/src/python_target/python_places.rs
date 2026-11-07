use super::PythonEmitter;
use crate::identifier_spelling::python_value_name;
use pseudolearn_semantic::collection_model::{CollectionAction, CollectionExpression};
use pseudolearn_semantic::hir::HirField;
use pseudolearn_semantic::{
    ExpressionId, FieldId, HirExpression, HirPlace, RecordId, Type, TypeId,
};

impl PythonEmitter<'_, '_> {
    pub(crate) fn field(&self, field: FieldId) -> Option<&HirField> {
        self.view
            .module
            .class_record_fields
            .iter()
            .map(|entry| &entry.field)
            .chain(
                self.view
                    .module
                    .classes
                    .iter()
                    .flat_map(|class| class.fields.iter()),
            )
            .find(|entry| entry.id == field)
    }

    pub(crate) fn field_path(name: &str) -> String {
        name.split('.')
            .map(python_value_name)
            .collect::<Vec<_>>()
            .join(".")
    }

    pub(crate) fn object_field(&mut self, receiver: ExpressionId, field: FieldId) -> String {
        let name = self
            .field(field)
            .map(|entry| Self::field_path(&entry.name))
            .unwrap_or_default();
        format!("{}.{name}", self.operand(receiver, 10))
    }

    pub(crate) fn element(&mut self, array: ExpressionId, indices: &[ExpressionId]) -> String {
        let mut text = self.operand(array, 10);
        for index in indices {
            let index_text = self.expression(*index);
            if self.is_keyed(array) {
                text = format!("{text}[{index_text}]");
            } else {
                self.require("index");
                text = format!("{text}[index({index_text})]");
            }
        }
        text
    }

    pub(crate) fn is_keyed(&self, collection: ExpressionId) -> bool {
        match self.view.expression_type(collection) {
            Type::Object(class) => self
                .view
                .module
                .collections
                .get(&class)
                .is_some_and(|entry| entry.key.is_some()),
            _ => false,
        }
    }

    pub(crate) fn record_path(&self, record: RecordId, offset: u32) -> String {
        let Some(entry) = self.view.record(record) else {
            return format!(".field{offset}");
        };
        for field in &entry.fields {
            let name = python_value_name(&field.name);
            let nested = matches!(self.view.representation(field.type_id), Type::Record(_));
            if field.offset == offset && !nested {
                return format!(".{name}");
            }
            if offset >= field.offset && offset < field.offset.saturating_add(field.width) {
                if let Type::Record(inner) = self.view.representation(field.type_id) {
                    return format!(
                        ".{name}{}",
                        self.record_path(inner, offset.saturating_sub(field.offset))
                    );
                }
                return format!(".{name}");
            }
        }
        format!(".field{offset}")
    }

    pub(crate) fn record_field(&mut self, record: ExpressionId, offset: u32) -> String {
        let Type::Record(identifier) = self.view.expression_type(record) else {
            return self.block("record_field", self.view.expression_span(record));
        };
        format!(
            "{}{}",
            self.operand(record, 10),
            self.record_path(identifier, offset)
        )
    }

    pub(crate) fn element_record(&self, array: ExpressionId) -> Option<RecordId> {
        let element = match self.view.expression_type(array) {
            Type::Array { element, .. } => element,
            Type::Object(class) => self.view.module.collections.get(&class)?.value,
            _ => return None,
        };
        match self.view.representation(element) {
            Type::Record(record) => Some(record),
            _ => None,
        }
    }

    pub(crate) fn place(&mut self, place: &HirPlace) -> String {
        match place {
            HirPlace::Local(local) | HirPlace::WholeArray(local) => self.local_name(*local),
            HirPlace::Field { receiver, field } => self.object_field(*receiver, *field),
            _ => self.place_rest(place),
        }
    }

    pub(crate) fn local_record_place(
        &self,
        local: pseudolearn_semantic::LocalId,
        offset: u32,
    ) -> String {
        let name = self.local_name(local);
        match self
            .view
            .local(local)
            .map(|entry| self.view.representation(entry.type_id))
        {
            Some(Type::Record(record)) => format!("{name}{}", self.record_path(record, offset)),
            _ => name,
        }
    }

    pub(crate) fn place_rest(&mut self, place: &HirPlace) -> String {
        match place {
            HirPlace::Element { array, indices } => self.element(*array, indices),
            HirPlace::RecordField { local, offset, .. } => self.local_record_place(*local, *offset),
            HirPlace::ElementRange {
                array,
                indices,
                offset,
                ..
            } => {
                let base = self.element(*array, indices);
                match self.element_record(*array) {
                    Some(record) => format!("{base}{}", self.record_path(record, *offset)),
                    None => base,
                }
            }
            HirPlace::FieldRange {
                receiver,
                field,
                offset,
                ..
            } => {
                let base = self.object_field(*receiver, *field);
                match self
                    .field(*field)
                    .map(|entry| self.view.representation(entry.type_id))
                {
                    Some(Type::Record(record)) => {
                        format!("{base}{}", self.record_path(record, *offset))
                    }
                    _ => base,
                }
            }
            _ => String::new(),
        }
    }

    pub(crate) fn place_type(&self, place: &HirPlace) -> Option<TypeId> {
        match place {
            HirPlace::Local(local) | HirPlace::WholeArray(local) => {
                self.view.local(*local).map(|entry| entry.type_id)
            }
            HirPlace::Field { field, .. } => self.field(*field).map(|entry| entry.type_id),
            HirPlace::Element { array, .. } => match self.view.expression_type(*array) {
                Type::Array { element, .. } => Some(element),
                Type::Object(class) => self
                    .view
                    .module
                    .collections
                    .get(&class)
                    .map(|entry| entry.value),
                _ => None,
            },
            HirPlace::RecordField { type_id, .. }
            | HirPlace::ElementRange { type_id, .. }
            | HirPlace::FieldRange { type_id, .. } => Some(*type_id),
        }
    }

    pub(crate) fn collection_operation(&mut self, collection: &CollectionExpression) -> String {
        let keyed = self
            .view
            .module
            .collections
            .get(&collection.class)
            .is_some_and(|entry| entry.key.is_some());
        let receiver = collection
            .receiver
            .map(|receiver| self.operand(receiver, 10))
            .unwrap_or_default();
        let arguments = collection
            .arguments
            .iter()
            .map(|argument| self.value(*argument))
            .collect::<Vec<_>>();
        self.collection_call((&collection.action, keyed), (&receiver, &arguments))
    }

    pub(crate) fn collection_call(
        &mut self,
        (action, keyed): (&CollectionAction, bool),
        (receiver, arguments): (&str, &[String]),
    ) -> String {
        let first = arguments.first().cloned().unwrap_or_default();
        let second = arguments.get(1).cloned().unwrap_or_default();
        match (action, keyed) {
            (CollectionAction::New, false) => "[]".to_owned(),
            (CollectionAction::New, true) => "{}".to_owned(),
            (CollectionAction::Length, _) => format!("len({receiver})"),
            (CollectionAction::Append, _) => format!("{receiver}.append({first})"),
            (CollectionAction::Insert, false) => format!(
                "{receiver}.insert({}, {second})",
                self.checked_insert(&first)
            ),
            (CollectionAction::Insert, true) => format!("{receiver}[{first}] = {second}"),
            (CollectionAction::Remove, false) => format!("{receiver}.pop(index({first}))"),
            _ => self.collection_call_rest((action, keyed), (receiver, arguments)),
        }
    }

    fn collection_call_rest(
        &mut self,
        (action, keyed): (&CollectionAction, bool),
        (receiver, arguments): (&str, &[String]),
    ) -> String {
        let first = arguments.first().cloned().unwrap_or_default();
        match (action, keyed) {
            (CollectionAction::Remove, true) => format!(
                "{}({receiver}, {first})",
                self.require_named("dictionary_remove")
            ),
            (CollectionAction::Find, _) => format!(
                "{}({receiver}, {first})",
                self.require_named("dictionary_find")
            ),
            (CollectionAction::Sort, _) if arguments.is_empty() => format!("{receiver}.sort()"),
            (CollectionAction::Sort, _) => {
                format!("{receiver}.sort(key=functools.cmp_to_key({first}))")
            }
            (CollectionAction::Reverse, _) => format!("{receiver}.reverse()"),
            (CollectionAction::IndexOf, _) => format!(
                "{}({receiver}, {first})",
                self.require_named("vector_index_of")
            ),
            (CollectionAction::Contains, _) => format!("{first} in {receiver}"),
            (CollectionAction::Keys, _) => format!("list({receiver}.keys())"),
            _ => String::new(),
        }
    }

    pub(crate) fn checked_insert(&mut self, position: &str) -> String {
        self.require("index");
        position.to_owned()
    }

    pub(crate) fn require_named(&mut self, name: &'static str) -> &'static str {
        if name == "dictionary_remove" || name == "dictionary_find" || name == "vector_index_of" {
            self.require("variants");
        }
        self.require(name)
    }

    pub(crate) fn uses_module(&self, expression: &HirExpression) -> bool {
        matches!(expression, HirExpression::Collection(CollectionExpression { action: CollectionAction::Sort, arguments, .. }) if !arguments.is_empty())
    }
}
