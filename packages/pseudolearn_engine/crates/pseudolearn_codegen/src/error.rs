#![forbid(unsafe_code)]

use std::fmt;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum CodegenError {
    InvalidModule(&'static str),
    Unsupported(&'static str),
    Target(String),
    Backend(String),
}

impl CodegenError {
    pub(crate) fn backend(error: impl fmt::Display) -> Self {
        Self::Backend(error.to_string())
    }
}

impl fmt::Display for CodegenError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidModule(reason) => write!(formatter, "invalid IR module: {reason}"),
            Self::Unsupported(operation) => write!(formatter, "unsupported operation: {operation}"),
            Self::Target(message) => write!(formatter, "target error: {message}"),
            Self::Backend(message) => write!(formatter, "backend error: {message}"),
        }
    }
}

impl std::error::Error for CodegenError {}
