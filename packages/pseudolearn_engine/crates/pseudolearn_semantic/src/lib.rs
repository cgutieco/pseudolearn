#![forbid(unsafe_code)]

mod argument_checker;
mod assignment_checker;
mod builtin_checker;
mod call_checker;
mod checker;
mod class_registry;
pub mod constructor_rules;
mod control_checker;
mod diagnostic_arguments;
mod dimension_checker;
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
pub mod service_analysis;
pub mod service_collection;
pub mod service_model;
mod session;
mod session_units;
mod statement_checker;
pub mod statement_model;
mod switch_checker;
mod type_resolution;
pub mod types;
mod unit_resolver;
mod usage;

pub use checker::analyze as analyze_with_options;
pub use expression_model::{
    BinaryOperator, BuiltinKind, ExpressionColumns, HirExpression, HirPlace, Literal, UnaryOperator,
};
pub use hir::{
    FunctionKind, HirClass, HirField, HirFunction, HirLocal, HirModule, Passing, SemanticModel,
    UnitTable,
};
pub use identities::{ClassId, ExpressionId, FieldId, FunctionId, LocalId, StatementId, TypeId};
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
