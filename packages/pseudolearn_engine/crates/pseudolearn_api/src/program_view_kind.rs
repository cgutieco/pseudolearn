use pseudolearn_syntax::NodeKind;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum ViewKind {
    Declaration,
    Statement,
    Expression,
    Symbol,
    Type,
}

impl ViewKind {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Self::Declaration => "declaration",
            Self::Statement => "statement",
            Self::Expression => "expression",
            Self::Symbol => "symbol",
            Self::Type => "type",
        }
    }
}

pub(crate) fn classify(kind: NodeKind, parent: Option<NodeKind>) -> Option<ViewKind> {
    match kind {
        NodeKind::ClassUnit
        | NodeKind::AlgorithmUnit
        | NodeKind::Subprogram
        | NodeKind::Subroutine
        | NodeKind::MethodMember
        | NodeKind::ConstructorMember
        | NodeKind::FieldDeclaration
        | NodeKind::Declaration
        | NodeKind::DimensionDeclaration
        | NodeKind::Parameters
        | NodeKind::Parameter => Some(ViewKind::Declaration),
        NodeKind::Body
        | NodeKind::DefaultCase
        | NodeKind::Statement
        | NodeKind::AssignmentStatement
        | NodeKind::CallStatement
        | NodeKind::Conditional
        | NodeKind::ForLoop
        | NodeKind::Input
        | NodeKind::Output
        | NodeKind::ReturnStatement
        | NodeKind::WhileLoop
        | NodeKind::RepeatLoop
        | NodeKind::Switch => Some(ViewKind::Statement),
        NodeKind::Identifier => Some(if parent.is_some_and(names_declaration) {
            ViewKind::Symbol
        } else {
            ViewKind::Expression
        }),
        NodeKind::Type => Some(ViewKind::Type),
        NodeKind::Arguments | NodeKind::Expressions | NodeKind::Labels => {
            Some(ViewKind::Expression)
        }
        other if is_expression(other) => Some(ViewKind::Expression),
        _ => None,
    }
}

pub(crate) fn syntax_name(kind: NodeKind) -> Option<&'static str> {
    declaration_or_statement_name(kind).or_else(|| expression_name(kind))
}

fn declaration_or_statement_name(kind: NodeKind) -> Option<&'static str> {
    Some(match kind {
        NodeKind::ClassUnit => "class_unit",
        NodeKind::AlgorithmUnit => "algorithm_unit",
        NodeKind::Subprogram => "subroutine",
        NodeKind::Subroutine => "subroutine",
        NodeKind::MethodMember => "method_member",
        NodeKind::ConstructorMember => "constructor_member",
        NodeKind::FieldDeclaration => "field_declaration",
        NodeKind::Declaration => "declaration",
        NodeKind::DimensionDeclaration => "dimension_declaration",
        NodeKind::Parameters => "parameters",
        NodeKind::Parameter => "parameter",
        NodeKind::Body => "body",
        NodeKind::Statement => "statement",
        NodeKind::AssignmentStatement => "assignment_statement",
        NodeKind::CallStatement => "call_statement",
        NodeKind::Conditional => "conditional",
        NodeKind::ForLoop => "for_loop",
        NodeKind::Input => "input",
        NodeKind::Output => "output",
        NodeKind::ReturnStatement => "return_statement",
        NodeKind::WhileLoop => "while_loop",
        NodeKind::RepeatLoop => "repeat_loop",
        NodeKind::Switch => "switch",
        NodeKind::DefaultCase => "default_case",
        NodeKind::Labels => "labels",
        NodeKind::Expressions => "expressions",
        NodeKind::Arguments => "arguments",
        NodeKind::Identifier => "identifier",
        NodeKind::Type => "type",
        _ => return None,
    })
}

fn expression_name(kind: NodeKind) -> Option<&'static str> {
    Some(match kind {
        NodeKind::Addition => "addition",
        NodeKind::And => "and",
        NodeKind::Conjunction => "conjunction",
        NodeKind::Designator => "designator",
        NodeKind::Disjunction => "disjunction",
        NodeKind::Divide => "divide",
        NodeKind::Equality => "equality",
        NodeKind::Expression => "expression",
        NodeKind::Instantiation => "instantiation",
        NodeKind::IntegerDivide => "integer_divide",
        NodeKind::Literal => "literal",
        NodeKind::Minus => "minus",
        NodeKind::Modulo => "modulo",
        NodeKind::Multiplication => "multiplication",
        NodeKind::NewInstance => "new_instance",
        NodeKind::Not => "not",
        NodeKind::Or => "or",
        NodeKind::Ordering => "ordering",
        NodeKind::Postfix => "postfix",
        NodeKind::Power => "power",
        NodeKind::PowerExpression => "power_expression",
        NodeKind::Primary => "primary",
        NodeKind::ThisObject => "this_object",
        NodeKind::Unary => "unary",
        _ => return None,
    })
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
