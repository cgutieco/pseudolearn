use crate::identities::{ClassId, EnumId, RecordId, TypeId};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum Type {
    Integer,
    Real,
    Boolean,
    Character,
    String,
    Unit,
    Never,
    Array { element: TypeId, rank: u32 },
    Object(ClassId),
    Enum(EnumId),
    Record(RecordId),
    Task(TypeId),
    Unknown,
    Error,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ValueClass {
    Scalar,
    Reference,
    Unit,
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct TypeInterner {
    pub types: Vec<Type>,
    indices: BTreeMap<Type, TypeId>,
}

impl TypeInterner {
    pub fn intern(&mut self, kind: Type) -> TypeId {
        if let Some(identifier) = self.indices.get(&kind) {
            return *identifier;
        }
        let identifier = TypeId(u32::try_from(self.types.len()).unwrap_or(u32::MAX));
        self.types.push(kind.clone());
        self.indices.insert(kind, identifier);
        identifier
    }

    pub fn get(&self, identifier: TypeId) -> Type {
        usize::try_from(identifier.0)
            .ok()
            .and_then(|index| self.types.get(index))
            .cloned()
            .unwrap_or(Type::Error)
    }

    pub fn value_class(&self, identifier: TypeId) -> ValueClass {
        match self.get(identifier) {
            Type::String | Type::Array { .. } | Type::Object(_) | Type::Task(_) => {
                ValueClass::Reference
            }
            Type::Unit | Type::Never => ValueClass::Unit,
            _ => ValueClass::Scalar,
        }
    }
}
