#![forbid(unsafe_code)]

pub mod code;
pub mod diagnostic;
pub mod render;

pub use code::DiagnosticCode;
pub use diagnostic::{Diagnostic, DiagnosticClass, DiagnosticSeverity};
pub use render::{render, sort_diagnostics};
