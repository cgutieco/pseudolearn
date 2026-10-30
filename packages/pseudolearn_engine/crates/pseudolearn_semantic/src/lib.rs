#![forbid(unsafe_code)]

mod argument_checker;
mod assignment_checker;
mod await_checker;
#[cfg(test)]
mod await_checker_tests;
mod builtin_checker;
mod call_checker;
pub mod capability_types;
mod checker;
mod class_registry;
mod cleanup_checker;
mod collection_checker;
pub mod collection_model;
mod collection_types;
mod constant_arithmetic;
mod constant_evaluator;
#[cfg(test)]
mod constant_evaluator_tests;
mod constant_nodes;
mod constant_real;
#[cfg(test)]
mod constant_real_tests;
mod constant_registry;
mod constant_use;
pub mod constructor_rules;
mod control_checker;
mod control_context;
mod diagnostic_arguments;
mod dimension_checker;
pub(crate) mod effect_calls;
pub(crate) mod effect_check;
pub(crate) mod effect_operands;
mod enum_access;
mod enum_registry;
mod expression_checker;
pub mod expression_model;
mod flow;
mod flow_bindings;
mod for_checker;
mod for_each_checker;
mod generic_calls;
mod generic_discard;
mod generic_functions;
mod generic_inference;
mod generic_labels;
mod generic_names;
mod generic_opaque;
mod generic_records;
mod generic_registry;
mod generic_state;
mod hierarchy;
pub mod hir;
mod hir_finalization;
mod http_types;
pub mod identities;
mod interface_constraints;
pub mod interface_model;
mod interface_realizations;
mod interface_registry;
mod interface_signatures;
mod json_types;
mod local_registry;
mod module_calls;
mod module_cycles;
mod module_exports;
mod module_imports;
mod module_structure;
mod module_symbols;
mod name_resolution;
mod operator_diagnostics;
mod operator_tokens;
mod operator_types;
mod operators;
mod postfix_checker;
pub mod project_analysis;
pub mod project_profile;
mod record_access;
mod record_cycles;
mod record_locals;
mod record_registry;
pub mod service_analysis;
pub mod service_collection;
pub mod service_model;
mod session;
mod session_units;
mod statement_checker;
pub mod statement_model;
mod suspension_checker;
#[cfg(test)]
mod suspension_checker_tests;
mod switch_checker;
mod task_handles;
#[cfg(test)]
mod task_handles_tests;
mod task_scope_checker;
#[cfg(test)]
mod task_scope_checker_tests;
mod type_declarations;
mod type_resolution;
mod type_scope;
pub mod types;
mod unit_resolver;
mod usage;

pub use checker::analyze as analyze_with_options;
pub use expression_model::{
    BinaryOperator, BuiltinKind, ExpressionColumns, HirExpression, HirPlace, Literal, UnaryOperator,
};
pub use hir::{
    FunctionKind, HirClass, HirEnum, HirField, HirFunction, HirLocal, HirModule, HirRecord,
    HirRecordField, Passing, SemanticModel, UnitTable,
};
pub use identities::{
    ClassId, EnumId, ExpressionId, FieldId, FunctionId, LocalId, RecordId, StatementId, TypeId,
};
pub use project_analysis::{
    ProjectAnalysis, ProjectUnit, analyze_project, analyze_project_detailed,
};
pub use project_profile::{ResolvedUnitProfile, resolve_project_profiles};
pub use service_analysis::{
    ServiceAnalysis, ServiceReference, ServiceSymbol, ServiceSymbolCategory, ServiceSymbolTarget,
    analyze_for_service,
};
pub use session::SemanticOptions;
pub use statement_model::{HirCase, HirDimension, HirStatement, StatementColumns};
pub use types::{Type, TypeInterner, ValueClass};

pub fn analyze_semantics(
    tree: &pseudolearn_syntax::SyntaxTree,
    source: &pseudolearn_source::SourceText,
    strict: bool,
) -> (Option<HirModule>, Vec<pseudolearn_diagnostics::Diagnostic>) {
    analyze_with_options(
        tree,
        source,
        SemanticOptions {
            profile: pseudolearn_lexicon::Profile::Spanish,
            strict,
        },
    )
}

mod binding_checker;
mod block_scopes;
#[cfg(test)]
mod block_scopes_tests;
mod scope_bindings;
mod service_visibility;

mod switch_coverage;

mod result_obligations;
mod variant_bindings;
mod variant_checker;
pub mod variant_model;
mod variant_types;

mod variant_statements;

mod variant_patterns;

pub mod function_model;
mod function_types;

mod capture_analysis;
mod closure_locals;
mod function_values;

mod capture_environment;
mod closure_checker;
mod function_calls;

pub use pseudolearn_lexicon::Profile;

mod function_containment;

mod effect_checker;
mod effect_types;
mod effect_vectors;
pub use pseudolearn_abi::{EFFECT_OPERATIONS, EffectOperation, EffectValueKind, effect_operation};

mod task_failure_types;

#[cfg(test)]
mod task_failure_types_tests;

mod channel_checker;
pub mod channel_model;
mod channel_types;

mod select_checker;

#[cfg(test)]
mod channel_types_tests;
#[cfg(test)]
mod select_checker_tests;

mod task_bindings;

mod transferability;
#[cfg(test)]
mod transferability_tests;

mod snapshot_types;
#[cfg(test)]
mod snapshot_types_tests;

mod snapshot_support;

#[cfg(test)]
mod snapshot_support_tests;

mod collection_layouts;
