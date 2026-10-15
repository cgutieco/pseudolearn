#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub enum Type {
    Integer,
    Real,
    String,
    Character,
    Boolean,
    Void,
    Array {
        element_type: Box<Type>,
        dimension_count: usize,
    },
    Class {
        class_name: String,
    },
    Unknown,
    Error,
}

impl Type {
    pub fn is_assignable_from(&self, source_type: &Type, is_strict: bool) -> bool {
        if *self == Type::Error || *source_type == Type::Error {
            return true;
        }
        if self == source_type {
            return true;
        }
        if !is_strict && *self == Type::Real && *source_type == Type::Integer {
            return true;
        }
        false
    }

    pub fn is_numeric(&self) -> bool {
        matches!(self, Type::Integer | Type::Real)
    }

    pub fn is_boolean(&self) -> bool {
        matches!(self, Type::Boolean)
    }

    pub fn is_error(&self) -> bool {
        matches!(self, Type::Error)
    }

    pub fn from_name(type_name: &str) -> Self {
        let normalized = type_name.trim().to_lowercase();
        match normalized.as_str() {
            "entero" | "integer" => Type::Integer,
            "real" | "numero" | "float" => Type::Real,
            "cadena" | "texto" | "string" => Type::String,
            "caracter" | "character" | "char" => Type::Character,
            "logico" | "booleano" | "boolean" | "bool" => Type::Boolean,
            "void" | "vacio" => Type::Void,
            _ => Type::Class {
                class_name: type_name.to_owned(),
            },
        }
    }
}
