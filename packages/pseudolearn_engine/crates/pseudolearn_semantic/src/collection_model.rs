use crate::identities::{ClassId, ExpressionId, TypeId};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirCollection {
    pub class: ClassId,
    pub key: Option<TypeId>,
    pub value: TypeId,
    pub leaves: Vec<TypeId>,
    pub canonical: Vec<usize>,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CollectionAction {
    New,
    Length,
    Append,
    Insert,
    Remove,
    Find,
}

#[derive(Clone, Debug, PartialEq)]
pub struct CollectionExpression {
    pub class: ClassId,
    pub action: CollectionAction,
    pub receiver: Option<ExpressionId>,
    pub arguments: Vec<ExpressionId>,
}
