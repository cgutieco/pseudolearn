#![forbid(unsafe_code)]

pub mod builder;
pub mod classes;
pub mod environment;
pub mod expressions;
pub mod expressions_binary;
pub mod expressions_builtins;
pub mod expressions_complex;
pub mod expressions_logical;
pub mod functions;
pub mod spans;
pub mod statement_context;
pub mod statements;
pub mod statements_assignment;
pub mod statements_conditional;
pub mod statements_declare;
pub mod statements_for;
pub mod statements_for_condition;
pub mod statements_repeat;
pub mod statements_switch;
pub mod statements_while;
pub mod types;

pub use builder::FunctionBuilder;
pub use classes::lower_classes;
pub use environment::VariableEnvironment;
pub use functions::lower_function;

use pseudolearn_ir::{Module, OriginTable};
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_source::SourceText;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LoweringError {
    pub description: String,
}

pub fn lower_module(
    semantic_module: &HirModule,
    source_text: &SourceText,
) -> Result<Module, LoweringError> {
    let classes = lower_classes(semantic_module);
    let mut origins = Vec::new();
    let mut functions = Vec::new();

    for function in &semantic_module.functions {
        functions.push(lower_function(
            function,
            semantic_module,
            source_text,
            &mut origins,
        ));
    }

    Ok(Module {
        name: "P".to_owned(),
        vocabulary: "es".to_owned(),
        classes,
        functions,
        origins: OriginTable { entries: origins },
    })
}
