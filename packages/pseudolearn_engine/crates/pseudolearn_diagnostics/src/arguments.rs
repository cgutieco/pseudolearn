use crate::{Diagnostic, DiagnosticCode};
use serde_json::{Number, Value};
use std::borrow::Cow;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ArgumentKind {
    Lexeme,
    Token,
    Type,
    Term,
    Number,
    TypeOrLexeme,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum TypeName {
    Token(String),
    Named(String),
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DiagnosticType {
    pub name: TypeName,
    pub rank: u32,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum DiagnosticArgument {
    Lexeme(String),
    Token(String),
    Type(DiagnosticType),
    Term(String),
    Number(Number),
}

impl ArgumentKind {
    pub fn accepts(self, actual: Self) -> bool {
        self == actual || self == Self::TypeOrLexeme && matches!(actual, Self::Type | Self::Lexeme)
    }
}

impl DiagnosticArgument {
    pub fn kind(&self) -> ArgumentKind {
        match self {
            Self::Lexeme(_) => ArgumentKind::Lexeme,
            Self::Token(_) => ArgumentKind::Token,
            Self::Type(_) => ArgumentKind::Type,
            Self::Term(_) => ArgumentKind::Term,
            Self::Number(_) => ArgumentKind::Number,
        }
    }

    pub fn text(&self) -> Cow<'_, str> {
        match self {
            Self::Lexeme(text) | Self::Token(text) | Self::Term(text) => Cow::Borrowed(text),
            Self::Number(number) => Cow::Owned(number.to_string()),
            Self::Type(kind) => Cow::Owned(type_text(kind)),
        }
    }

    pub fn wire(&self) -> Value {
        match self {
            Self::Number(number) => Value::Number(number.clone()),
            _ => Value::String(self.text().into_owned()),
        }
    }

    pub fn from_wire(kind: ArgumentKind, value: &Value) -> Option<Self> {
        if kind == ArgumentKind::Number {
            return value.as_number().cloned().map(Self::Number);
        }
        let text = value.as_str()?.to_owned();
        Some(match kind {
            ArgumentKind::Token => Self::Token(text),
            ArgumentKind::Type | ArgumentKind::TypeOrLexeme => Self::Type(DiagnosticType {
                name: TypeName::Named(text),
                rank: 0,
            }),
            ArgumentKind::Term => Self::Term(text),
            _ => Self::Lexeme(text),
        })
    }
}

impl DiagnosticCode {
    pub fn argument_kind(self, name: &str) -> Option<ArgumentKind> {
        self.argument_specs()
            .iter()
            .find(|(key, _)| *key == name)
            .map(|(_, kind)| *kind)
    }
}

pub fn validate_arguments(diagnostic: &Diagnostic) -> bool {
    let expected = diagnostic.code.argument_specs();
    expected.len() == diagnostic.arguments.len()
        && expected.iter().all(|(name, kind)| {
            diagnostic
                .arguments
                .get(*name)
                .is_some_and(|value| kind.accepts(value.kind()))
        })
}

fn type_text(kind: &DiagnosticType) -> String {
    let name = match &kind.name {
        TypeName::Token(name) | TypeName::Named(name) => name,
    };
    if kind.rank == 0 {
        return name.clone();
    }
    let commas = usize::try_from(kind.rank.saturating_sub(1)).unwrap_or(0);
    format!("{name}[{}]", ",".repeat(commas))
}
