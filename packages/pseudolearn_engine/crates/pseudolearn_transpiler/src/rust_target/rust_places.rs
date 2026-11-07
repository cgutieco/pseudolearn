use super::RustEmitter;
use crate::identifier_spelling::rust_value_name;
use pseudolearn_semantic::hir::HirField;
use pseudolearn_semantic::{
    ClassId, ExpressionId, FieldId, HirExpression, HirPlace, LocalId, RecordId, Type, TypeId,
};

impl RustEmitter<'_, '_> {
    pub(crate) fn local_read(&mut self, local: LocalId) -> String {
        let name = self.local_name(local);
        let scalar = self
            .view
            .local(local)
            .is_some_and(|entry| self.is_copy(entry.type_id));
        if scalar && self.is_reference_parameter(local) {
            format!("*{name}")
        } else {
            name
        }
    }

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

    pub(crate) fn is_leaf_field(&self, field: FieldId) -> bool {
        self.view
            .module
            .class_record_fields
            .iter()
            .any(|entry| entry.leaves.contains(&field))
    }

    pub(crate) fn receiver_text(&mut self, receiver: ExpressionId) -> Option<String> {
        if let HirExpression::This(_) = self.view.expression(receiver)
            && self.scope.owner.is_some()
        {
            return None;
        }
        Some(self.expression(receiver))
    }

    pub(crate) fn field_accessor(
        &self,
        receiver: ExpressionId,
        owner: ClassId,
        writing: bool,
    ) -> String {
        let polymorphic = match self.view.expression_type(receiver) {
            Type::Object(class) => self.is_polymorphic(class),
            _ => false,
        };
        if !polymorphic {
            return String::new();
        }
        let base = rust_value_name(&self.class_name(owner));
        if writing {
            format!(".{base}_mut()")
        } else {
            format!(".{base}()")
        }
    }

    pub(crate) fn object_field(
        &mut self,
        receiver: ExpressionId,
        field: FieldId,
        writing: bool,
    ) -> String {
        let Some(entry) = self.field(field) else {
            return self.block("field", self.view.expression_span(receiver));
        };
        let field_name = entry
            .name
            .split('.')
            .map(rust_value_name)
            .collect::<Vec<_>>()
            .join(".");
        let optional = !writing && self.field_is_optional(entry);
        let accessor = self.field_accessor(receiver, entry.owner, writing);
        let access = match self.receiver_text(receiver) {
            None if self.scope.generic_receiver => format!("this{accessor}.{field_name}"),
            None => format!("self.{field_name}"),
            Some(text) => {
                let borrow = if writing { "borrow_mut" } else { "borrow" };
                format!("{text}.{borrow}(){accessor}.{field_name}")
            }
        };
        if optional {
            format!("{access}.clone().expect(\"uninitializedField\")")
        } else {
            access
        }
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

    pub(crate) fn element(
        &mut self,
        array: ExpressionId,
        indices: &[ExpressionId],
        writing: bool,
    ) -> String {
        if self.is_keyed(array) {
            let receiver = self.operand(array, super::rust_expressions::ATOM);
            let key = indices
                .first()
                .map(|key| self.value(*key))
                .unwrap_or_default();
            return format!("{receiver}.borrow().get(&{key})");
        }
        let mut text = self.operand(array, super::rust_expressions::ATOM);
        if matches!(self.view.expression_type(array), Type::Object(_)) {
            let borrow = if writing { "borrow_mut" } else { "borrow" };
            text = format!("{text}.{borrow}()");
        }
        for index in indices {
            let index_text = match self.view.expression(*index) {
                HirExpression::Literal(pseudolearn_semantic::Literal::Integer(value))
                    if *value >= 0 =>
                {
                    value.to_string()
                }
                _ => format!("{} as usize", self.operand(*index, 9)),
            };
            text = format!("{text}[{index_text}]");
        }
        text
    }

    pub(crate) fn record_path(&self, record: RecordId, offset: u32) -> String {
        let Some(entry) = self.view.record(record) else {
            return format!(".field{offset}");
        };
        for field in &entry.fields {
            let name = rust_value_name(&field.name);
            if field.offset == offset && !self.is_nested_record(field.type_id) {
                return format!(".{name}");
            }
            let ending = field.offset.saturating_add(field.width);
            if offset >= field.offset && offset < ending {
                if let Type::Record(nested) = self.view.representation(field.type_id) {
                    let rest = self.record_path(nested, offset.saturating_sub(field.offset));
                    return format!(".{name}{rest}");
                }
                return format!(".{name}");
            }
        }
        format!(".field{offset}")
    }

    pub(crate) fn is_nested_record(&self, type_id: TypeId) -> bool {
        matches!(self.view.representation(type_id), Type::Record(_))
    }

    pub(crate) fn record_field(&mut self, record: ExpressionId, offset: u32) -> String {
        let Type::Record(identifier) = self.view.expression_type(record) else {
            return self.block("record_field", self.view.expression_span(record));
        };
        let base = self.operand(record, super::rust_expressions::ATOM);
        format!("{base}{}", self.record_path(identifier, offset))
    }

    pub(crate) fn place(&mut self, place: &HirPlace) -> String {
        match place {
            HirPlace::Local(local) | HirPlace::WholeArray(local) => {
                let name = self.local_name(*local);
                if self.is_reference_parameter(*local) {
                    format!("*{name}")
                } else {
                    name
                }
            }
            HirPlace::Field { receiver, field } => self.object_field(*receiver, *field, true),
            _ => self.place_rest(place),
        }
    }

    pub(crate) fn place_rest(&mut self, place: &HirPlace) -> String {
        match place {
            HirPlace::Element { array, indices } => self.element(*array, indices, true),
            HirPlace::RecordField { local, offset, .. } => {
                let name = self.local_name(*local);
                let record = self
                    .view
                    .local(*local)
                    .map(|entry| self.view.representation(entry.type_id));
                match record {
                    Some(Type::Record(identifier)) => {
                        format!("{name}{}", self.record_path(identifier, *offset))
                    }
                    _ => name,
                }
            }
            HirPlace::ElementRange {
                array,
                indices,
                offset,
                ..
            } => {
                let base = self.element(*array, indices, true);
                self.nested_path(base, self.element_record(*array), *offset)
            }
            HirPlace::FieldRange {
                receiver,
                field,
                offset,
                ..
            } => {
                let base = self.object_field(*receiver, *field, true);
                let record = self
                    .field(*field)
                    .map(|entry| self.view.representation(entry.type_id));
                self.nested_path(base, record, *offset)
            }
            _ => String::new(),
        }
    }

    pub(crate) fn element_record(&self, array: ExpressionId) -> Option<Type> {
        match self.view.expression_type(array) {
            Type::Array { element, .. } => Some(self.view.representation(element)),
            Type::Object(class) => self
                .view
                .module
                .collections
                .get(&class)
                .map(|collection| self.view.representation(collection.value)),
            _ => None,
        }
    }

    pub(crate) fn nested_path(&self, base: String, record: Option<Type>, offset: u32) -> String {
        match record {
            Some(Type::Record(identifier)) => {
                format!("{base}{}", self.record_path(identifier, offset))
            }
            _ => base,
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
                _ => None,
            },
            HirPlace::RecordField { type_id, .. }
            | HirPlace::ElementRange { type_id, .. }
            | HirPlace::FieldRange { type_id, .. } => Some(*type_id),
        }
    }
}
