#![forbid(unsafe_code)]

pub mod arguments;
pub mod code;
pub mod diagnostic;
pub mod render;

pub use code::DiagnosticCode;
pub use diagnostic::{Diagnostic, DiagnosticClass, DiagnosticSeverity};
pub use render::{render, sort_diagnostics, sort_diagnostics_with};

pub use arguments::{
    ArgumentKind, DiagnosticArgument, DiagnosticType, TypeName, validate_arguments,
};
