#![forbid(unsafe_code)]

mod code_lines;
mod identifier_spelling;
mod module_view;
mod outcome;
mod python_target;
mod rust_target;
mod support_requests;
mod target;

pub use outcome::{Blocker, Transpilation, TranspileOutcome};
pub use target::{TargetLanguage, TranspileRequest};

use pseudolearn_semantic::HirModule;

pub fn transpile(module: &HirModule, request: &TranspileRequest) -> TranspileOutcome {
    let view = module_view::ModuleView::new(module);
    match request.target {
        TargetLanguage::Rust => rust_target::emit_program(&view, request),
        TargetLanguage::Python => python_target::emit_program(&view, request),
    }
}
