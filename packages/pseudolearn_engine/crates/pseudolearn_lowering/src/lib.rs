#![forbid(unsafe_code)]

mod address_taken;
pub mod builder;
mod class_density;
pub mod classes;
mod constructor_flow;
mod dispatch_targets;
pub mod environment;
mod expression_values;
pub mod expressions;
pub mod expressions_binary;
pub mod expressions_builtins;
pub mod expressions_complex;
pub mod expressions_logical;
mod expressions_objects;
pub mod functions;
mod parameter_passing;
mod places;
pub mod spans;
pub mod statement_context;
pub mod statements;
pub mod statements_assignment;
pub mod statements_conditional;
pub mod statements_declare;
pub mod statements_for;
pub mod statements_for_condition;
pub mod statements_read;
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
    lower_with(semantic_module, |_| Some(source_text))
}

pub fn lower_project(
    semantic_module: &HirModule,
    sources: &[&SourceText],
) -> Result<Module, LoweringError> {
    lower_with(semantic_module, |index| {
        let unit =
            semantic_module
                .units
                .function_unit(pseudolearn_semantic::identities::FunctionId(
                    u32::try_from(index).unwrap_or(u32::MAX),
                ));
        sources.get(unit).copied()
    })
}

fn lower_with<'sources>(
    semantic_module: &HirModule,
    source_for: impl Fn(usize) -> Option<&'sources SourceText>,
) -> Result<Module, LoweringError> {
    let classes = lower_classes(semantic_module);
    let mut origins = Vec::new();
    let mut functions = Vec::new();

    for (index, function) in semantic_module.functions.iter().enumerate() {
        let source_text = source_for(index).ok_or_else(|| LoweringError {
            description: "function has no source".to_owned(),
        })?;
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
