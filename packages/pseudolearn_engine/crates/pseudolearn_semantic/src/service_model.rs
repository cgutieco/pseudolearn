#![forbid(unsafe_code)]

use crate::hir::HirModule;
use crate::identities::{ClassId, FieldId, FunctionId, LocalId, TypeId};
use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_lexicon::BuiltinKind;
use pseudolearn_source::Span;

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum ServiceSymbolTarget {
    Local(LocalId),
    Function(FunctionId),
    Class(ClassId),
    Field(FieldId),
    Builtin(BuiltinKind),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ServiceSymbolCategory {
    Variable,
    Parameter,
    Function,
    Procedure,
    Class,
    Field,
    Method,
}

#[derive(Clone, Debug, PartialEq)]
pub struct ServiceSymbol {
    pub identifier: usize,
    pub name: String,
    pub category: ServiceSymbolCategory,
    pub type_id: TypeId,
    pub span: Span,
    pub is_inferred: bool,
    pub owner_class: Option<ClassId>,
    pub parameter_types: Vec<(String, TypeId, crate::hir::Passing)>,
    pub return_type: Option<TypeId>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct ServiceReference {
    pub span: Span,
    pub target: ServiceSymbolTarget,
    pub is_write: bool,
    pub is_declaration: bool,
}

#[derive(Clone, Debug, PartialEq)]
pub struct ServiceAnalysis {
    pub module: HirModule,
    pub diagnostics: Vec<Diagnostic>,
    pub symbols: Vec<ServiceSymbol>,
    pub occurrences: Vec<ServiceReference>,
    pub expression_types: Vec<(Span, TypeId)>,
}
