use crate::expression_model::ExpressionColumns;
use crate::identities::{ClassId, FieldId, FunctionId, LocalId, StatementId, TypeId};
use crate::statement_model::StatementColumns;
use crate::types::TypeInterner;
use pseudolearn_source::Span;
use std::collections::{BTreeMap, BTreeSet};

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
    pub mutable: bool,
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
    pub suspendible: bool,
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

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct UnitTable {
    pub qualifiers: Vec<String>,
    pub functions: Vec<u32>,
    pub classes: Vec<u32>,
    pub exported: Vec<FunctionId>,
    pub entry: Option<FunctionId>,
}

impl UnitTable {
    pub fn is_project(&self) -> bool {
        !self.qualifiers.is_empty()
    }

    pub fn function_unit(&self, function: FunctionId) -> usize {
        usize::try_from(function.0)
            .ok()
            .and_then(|index| self.functions.get(index))
            .and_then(|unit| usize::try_from(*unit).ok())
            .unwrap_or(0)
    }

    pub fn class_unit(&self, class: ClassId) -> usize {
        usize::try_from(class.0)
            .ok()
            .and_then(|index| self.classes.get(index))
            .and_then(|unit| usize::try_from(*unit).ok())
            .unwrap_or(0)
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HirEnum {
    pub name: String,
    pub members: Vec<String>,
    pub span: Span,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HirRecordField {
    pub name: String,
    pub type_id: TypeId,
    pub offset: u32,
    pub width: u32,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HirRecord {
    pub name: String,
    pub fields: Vec<HirRecordField>,
    pub leaf_types: Vec<TypeId>,
    pub leaf_names: Vec<String>,
    pub span: Span,
    pub syntax: usize,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct HirModule {
    pub channels: BTreeMap<crate::identities::RecordId, TypeId>,
    pub task_failures: BTreeMap<crate::identities::RecordId, TypeId>,
    pub opaque_types: BTreeMap<ClassId, pseudolearn_abi::EffectValueKind>,
    pub collections: BTreeMap<ClassId, crate::collection_model::HirCollection>,
    pub interfaces: Vec<crate::interface_model::HirInterface>,
    pub realizations: BTreeMap<ClassId, Vec<crate::interface_model::InterfaceId>>,
    pub constraints: Vec<crate::interface_model::HirConstraint>,
    pub source_profiles: BTreeMap<pseudolearn_source::SourceId, pseudolearn_lexicon::Profile>,
    pub function_types:
        BTreeMap<crate::identities::RecordId, crate::function_model::FunctionSignature>,
    pub closures: BTreeMap<FunctionId, crate::function_model::HirClosure>,
    pub function_values: BTreeMap<FunctionId, FunctionId>,
    pub units: UnitTable,
    pub functions: Vec<HirFunction>,
    pub classes: Vec<HirClass>,
    pub enums: Vec<HirEnum>,
    pub records: Vec<HirRecord>,
    pub variants: BTreeMap<crate::identities::RecordId, crate::variant_model::HirVariant>,
    pub record_locals: BTreeMap<LocalId, Vec<LocalId>>,
    pub pure_locals: BTreeSet<LocalId>,
    pub local_visibility: BTreeMap<LocalId, Span>,
    pub locals: Vec<HirLocal>,
    pub expressions: ExpressionColumns,
    pub statements: StatementColumns,
    pub types: TypeInterner,
}

pub type SemanticModel = HirModule;
