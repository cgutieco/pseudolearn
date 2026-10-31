#![forbid(unsafe_code)]

mod address_taken;
pub mod builder;
mod class_density;
pub mod classes;
pub mod cleanup_edges;
mod collection_optional;
mod collection_output;
mod collections;
mod constructor_flow;
mod dispatch_targets;
pub mod effect_calls;
mod enum_output;
pub mod environment;
mod expression_values;
pub mod expressions;
pub mod expressions_binary;
pub mod expressions_builtins;
pub mod expressions_complex;
pub mod expressions_logical;
mod expressions_objects;
pub mod functions;
pub mod inspection_lowering;
mod iteration_values;
pub mod loop_exits;
mod parameter_passing;
mod places;
mod record_values;
mod records;
pub mod spans;
pub mod statement_context;
pub mod statements;
pub mod statements_assignment;
mod statements_cleanup;
pub mod statements_conditional;
pub mod statements_declare;
pub mod statements_for;
pub mod statements_for_condition;
mod statements_for_each;
pub mod statements_read;
pub mod statements_repeat;
pub mod statements_switch;
pub mod statements_while;
mod task_scopes;
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
        let start = origins.len();
        functions.push(lower_function(
            function,
            semantic_module,
            source_text,
            &mut origins,
        ));
        crate::lexical_origins::annotate(&mut origins, start, semantic_module, source_text);
    }

    crate::task_wrappers::append(semantic_module, &mut functions);
    crate::function_prototypes::append(semantic_module, &mut functions);
    Ok(Module {
        name: "P".to_owned(),
        vocabulary: "es".to_owned(),
        profiles: Vec::new(),
        classes,
        functions,
        origins: OriginTable { entries: origins },
    })
}

mod statements_variant_match;
mod variant_propagation;
mod variant_values;

mod lexical_origins;
mod switch_dispatch;
mod switch_join;

mod closure_values;
mod function_prototypes;
mod indirect_calls;

mod effect_values;

mod channel_operations;
mod select_dispatch;

mod task_wrappers;

mod suspension_points;
mod task_scope_result;

mod task_values;

mod yield_points;

mod snapshot_values;

mod continuation_blocks;
