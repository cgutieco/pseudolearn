use crate::expression_model::HirPlace;
use crate::identities::{ExpressionId, LocalId, StatementId};
use pseudolearn_source::Span;

#[derive(Clone, Debug, PartialEq)]
pub struct HirCase {
    pub labels: Vec<ExpressionId>,
    pub body: Vec<StatementId>,
}

#[derive(Clone, Debug, PartialEq)]
pub enum HirStatement {
    Defer(Vec<StatementId>),
    Break,
    ForEach {
        collection: ExpressionId,
        bindings: Vec<LocalId>,
        body: Vec<StatementId>,
    },
    Declare(Vec<LocalId>),
    VariantMatch(Box<crate::variant_model::HirVariantMatch>),
    Dimension(Vec<HirDimension>),
    Assign {
        destination: HirPlace,
        value: ExpressionId,
    },
    Conditional {
        condition: ExpressionId,
        affirmative: Vec<StatementId>,
        negative: Vec<StatementId>,
    },
    While {
        condition: ExpressionId,
        body: Vec<StatementId>,
    },
    Repeat {
        body: Vec<StatementId>,
        condition: ExpressionId,
    },
    For {
        control: LocalId,
        initial: ExpressionId,
        ending: ExpressionId,
        step: Option<ExpressionId>,
        body: Vec<StatementId>,
    },
    Switch {
        selector: ExpressionId,
        cases: Vec<HirCase>,
        default: Vec<StatementId>,
    },
    Write {
        values: Vec<ExpressionId>,
        newline: bool,
    },
    Read(Vec<HirPlace>),
    Call(ExpressionId),
    Return(Option<ExpressionId>),
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct StatementColumns {
    pub kinds: Vec<HirStatement>,
    pub spans: Vec<Span>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct HirDimension {
    pub local: LocalId,
    pub dimensions: Vec<ExpressionId>,
}
