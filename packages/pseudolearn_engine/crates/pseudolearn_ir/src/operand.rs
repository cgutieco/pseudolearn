#![forbid(unsafe_code)]

use crate::identities::{BlockId, ValueId};
use crate::types::IrType;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum PredicateKind {
    Equal,
    NotEqual,
    LessThan,
    LessEqual,
    GreaterThan,
    GreaterEqual,
}

impl PredicateKind {
    pub const fn as_str(&self) -> &'static str {
        match self {
            Self::Equal => "eq",
            Self::NotEqual => "ne",
            Self::LessThan => "lt",
            Self::LessEqual => "le",
            Self::GreaterThan => "gt",
            Self::GreaterEqual => "ge",
        }
    }

    pub fn from_name(name: &str) -> Option<Self> {
        match name {
            "eq" => Some(Self::Equal),
            "ne" => Some(Self::NotEqual),
            "lt" => Some(Self::LessThan),
            "le" => Some(Self::LessEqual),
            "gt" => Some(Self::GreaterThan),
            "ge" => Some(Self::GreaterEqual),
            _ => None,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub enum Operand {
    Value(ValueId),
    BlockTarget {
        target_block: BlockId,
        arguments: Vec<ValueId>,
    },
    FunctionTarget {
        function_name: String,
        arguments: Vec<ValueId>,
    },
    LiteralI64(i64),
    LiteralF64(f64),
    LiteralBool(bool),
    LiteralChar(char),
    LiteralStr(String),
    Type(IrType),
    Predicate(PredicateKind),
    Identifier(String),
    Newline,
}
