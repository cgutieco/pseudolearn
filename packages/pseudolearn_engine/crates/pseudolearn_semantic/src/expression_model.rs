use crate::identities::{ClassId, ExpressionId, FieldId, FunctionId, LocalId, TypeId};
use crate::types::ValueClass;
use pseudolearn_lexicon::BuiltinKind;
use pseudolearn_source::Span;

#[derive(Clone, Debug, PartialEq)]
pub enum Literal {
    Integer(i64),
    Real(f64),
    Boolean(bool),
    Character(char),
    String(String),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum BinaryOperator {
    Add,
    Subtract,
    Multiply,
    Divide,
    IntegerDivide,
    Modulo,
    Power,
    Equal,
    NotEqual,
    Less,
    LessEqual,
    Greater,
    GreaterEqual,
    LogicalAnd,
    LogicalOr,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum UnaryOperator {
    Positive,
    Negative,
    Not,
}

#[derive(Clone, Debug, PartialEq)]
pub enum HirExpression {
    Literal(Literal),
    Local(LocalId),
    Uninitialized(LocalId),
    Field {
        receiver: ExpressionId,
        field: FieldId,
    },
    Element {
        array: ExpressionId,
        indices: Vec<ExpressionId>,
    },
    Call {
        function: FunctionId,
        arguments: Vec<ExpressionId>,
    },
    VirtualCall {
        receiver: ExpressionId,
        function: FunctionId,
        arguments: Vec<ExpressionId>,
    },
    Builtin {
        function: BuiltinKind,
        arguments: Vec<ExpressionId>,
    },
    New {
        class: ClassId,
        arguments: Vec<ExpressionId>,
    },
    Unary {
        operator: UnaryOperator,
        operand: ExpressionId,
        operator_span: Span,
    },
    Binary {
        operator: BinaryOperator,
        left: ExpressionId,
        right: ExpressionId,
        operator_span: Span,
    },
    Widen(ExpressionId),
    This(ClassId),
    SuperCall {
        receiver: ClassId,
        function: Option<FunctionId>,
        arguments: Vec<ExpressionId>,
    },
    Invalid,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct ExpressionColumns {
    pub kinds: Vec<HirExpression>,
    pub types: Vec<TypeId>,
    pub value_classes: Vec<ValueClass>,
    pub spans: Vec<Span>,
}

#[derive(Clone, Debug, PartialEq)]
pub enum HirPlace {
    Local(LocalId),
    Field {
        receiver: ExpressionId,
        field: FieldId,
    },
    Element {
        array: ExpressionId,
        indices: Vec<ExpressionId>,
    },
    WholeArray(LocalId),
}
