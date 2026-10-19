use pseudolearn_syntax::NodeKind;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum ViewKind {
    Declaration,
    Statement,
    Expression,
}

impl ViewKind {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Self::Declaration => "declaration",
            Self::Statement => "statement",
            Self::Expression => "expression",
        }
    }
}

pub(crate) fn classify(kind: NodeKind, parent: Option<NodeKind>) -> Option<ViewKind> {
    match kind {
        NodeKind::ClassUnit
        | NodeKind::AlgorithmUnit
        | NodeKind::Subroutine
        | NodeKind::MethodMember
        | NodeKind::ConstructorMember
        | NodeKind::FieldDeclaration
        | NodeKind::Declaration
        | NodeKind::DimensionDeclaration
        | NodeKind::Parameter => Some(ViewKind::Declaration),
        NodeKind::Statement
        | NodeKind::Conditional
        | NodeKind::ForLoop
        | NodeKind::WhileLoop
        | NodeKind::RepeatLoop
        | NodeKind::Switch => Some(ViewKind::Statement),
        NodeKind::Identifier => parent
            .filter(|owner| !names_declaration(*owner))
            .map(|_| ViewKind::Expression),
        other if is_expression(other) => Some(ViewKind::Expression),
        _ => None,
    }
}

fn names_declaration(owner: NodeKind) -> bool {
    matches!(
        owner,
        NodeKind::ClassUnit
            | NodeKind::AlgorithmUnit
            | NodeKind::Subroutine
            | NodeKind::MethodMember
            | NodeKind::ConstructorMember
            | NodeKind::FieldDeclaration
            | NodeKind::Declaration
            | NodeKind::DimensionDeclaration
            | NodeKind::Parameter
            | NodeKind::SuperClass
            | NodeKind::InheritsFrom
    )
}

fn is_expression(kind: NodeKind) -> bool {
    matches!(
        kind,
        NodeKind::Addition
            | NodeKind::And
            | NodeKind::Conjunction
            | NodeKind::Designator
            | NodeKind::Disjunction
            | NodeKind::Divide
            | NodeKind::Equality
            | NodeKind::Expression
            | NodeKind::Instantiation
            | NodeKind::IntegerDivide
            | NodeKind::Literal
            | NodeKind::Minus
            | NodeKind::Modulo
            | NodeKind::Multiplication
            | NodeKind::NewInstance
            | NodeKind::Not
            | NodeKind::Or
            | NodeKind::Ordering
            | NodeKind::Postfix
            | NodeKind::Power
            | NodeKind::PowerExpression
            | NodeKind::Primary
            | NodeKind::ThisObject
            | NodeKind::Unary
    )
}
