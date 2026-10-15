use crate::expression_model::ExpressionColumns;
use crate::identities::{ClassId, FieldId, FunctionId, LocalId, StatementId, TypeId};
use crate::statement_model::StatementColumns;
use crate::types::TypeInterner;
use pseudolearn_source::Span;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum FunctionKind {
    Main,
    Procedure,
    Function,
    Method,
    Constructor,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HirLocal {
    pub name: String,
    pub type_id: TypeId,
    pub passing: Passing,
    pub span: Span,
    pub scope: FunctionId,
    pub parameter: bool,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Passing {
    Value,
    Reference,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HirFunction {
    pub kind: FunctionKind,
    pub name: String,
    pub owner: Option<ClassId>,
    pub parameters: Vec<LocalId>,
    pub result: TypeId,
    pub body: Vec<StatementId>,
    pub span: Span,
    pub closing_span: Span,
    pub syntax: usize,
    pub private: bool,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HirField {
    pub id: FieldId,
    pub name: String,
    pub type_id: TypeId,
    pub owner: ClassId,
    pub private: bool,
    pub span: Span,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HirClass {
    pub name: String,
    pub superclass: Option<ClassId>,
    pub fields: Vec<HirField>,
    pub methods: Vec<FunctionId>,
    pub virtual_slots: Vec<FunctionId>,
    pub constructor: Option<FunctionId>,
    pub span: Span,
    pub syntax: usize,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct HirModule {
    pub functions: Vec<HirFunction>,
    pub classes: Vec<HirClass>,
    pub locals: Vec<HirLocal>,
    pub expressions: ExpressionColumns,
    pub statements: StatementColumns,
    pub types: TypeInterner,
}

pub type SemanticModel = HirModule;
