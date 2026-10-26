use crate::function_model::FunctionSignature;
use pseudolearn_source::Span;

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct InterfaceId(pub u32);

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct InterfaceMethod {
    pub name: String,
    pub signature: FunctionSignature,
    pub span: Span,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirInterface {
    pub name: String,
    pub unit: usize,
    pub syntax: usize,
    pub span: Span,
    pub methods: Vec<InterfaceMethod>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirConstraint {
    pub unit: usize,
    pub template: usize,
    pub parameter: String,
    pub interface: InterfaceId,
    pub span: Span,
}
