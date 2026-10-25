#![forbid(unsafe_code)]

mod argument_checker;
mod assignment_checker;
mod builtin_checker;
mod call_checker;
mod checker;
mod class_registry;
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
mod diagnostic_arguments;
mod dimension_checker;
mod enum_access;
mod enum_registry;
mod expression_checker;
pub mod expression_model;
mod flow;
mod flow_bindings;
mod for_checker;
mod hierarchy;
pub mod hir;
mod hir_finalization;
pub mod identities;
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
mod switch_checker;
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
pub use project_analysis::{ProjectUnit, analyze_project};
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

mod switch_coverage;

mod result_obligations;
mod variant_bindings;
mod variant_checker;
pub mod variant_model;
mod variant_types;

mod variant_statements;

mod variant_patterns;
