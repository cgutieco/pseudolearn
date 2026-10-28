use crate::identities::{ExpressionId, TypeId};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ChannelAction {
    New,
    Send,
    Receive,
    Close,
    Selected,
}

#[derive(Clone, Debug, PartialEq)]
pub struct ChannelExpression {
    pub action: ChannelAction,
    pub element: TypeId,
    pub receiver: Option<ExpressionId>,
    pub arguments: Vec<ExpressionId>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct HirSelect {
    pub channels: Vec<ExpressionId>,
    pub storage: crate::identities::LocalId,
    pub selector: ExpressionId,
    pub cases: Vec<crate::statement_model::HirCase>,
}
