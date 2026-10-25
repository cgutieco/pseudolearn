use crate::hir::Passing;
use crate::identities::{ClassId, FunctionId, LocalId, TypeId};
use pseudolearn_abi::ClosureLayout;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FunctionSignature {
    pub parameters: Vec<(TypeId, Passing)>,
    pub result: TypeId,
}

#[derive(Clone, Debug, PartialEq)]
pub struct HirClosure {
    pub environment: LocalId,
    pub class: Option<ClassId>,
    pub captures: Vec<(LocalId, LocalId)>,
    pub offsets: Vec<u32>,
    pub layout: Option<ClosureLayout>,
}

#[derive(Clone, Debug)]
pub(crate) struct ClosureFrame {
    pub function: FunctionId,
}
