use crate::identities::{ClassId, ExpressionId, FieldId, FunctionId, LocalId, RecordId, TypeId};
use crate::types::ValueClass;
pub use pseudolearn_lexicon::BuiltinKind;
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
    Channel(crate::channel_model::ChannelExpression),
    Effect {
        awaited: bool,
        operation: u32,
        receiver: Option<ExpressionId>,
        arguments: Vec<ExpressionId>,
        source_node_id: u32,
    },
    Collection(crate::collection_model::CollectionExpression),
    FunctionValue(FunctionId),
    Captured {
        function: FunctionId,
        capture: u32,
    },
    IndirectCall {
        callee: ExpressionId,
        arguments: Vec<ExpressionId>,
    },
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
    TaskSpawn {
        function: FunctionId,
        arguments: Vec<ExpressionId>,
    },
    AwaitTask(ExpressionId),
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
    RecordNew {
        record: RecordId,
        fields: Vec<ExpressionId>,
    },
    RecordField {
        record: ExpressionId,
        offset: u32,
    },
    This(ClassId),
    SuperCall {
        receiver: ClassId,
        function: Option<FunctionId>,
        arguments: Vec<ExpressionId>,
    },
    VariantNew {
        record: RecordId,
        alternative: u32,
        payload: Option<ExpressionId>,
    },
    VariantPayload {
        value: ExpressionId,
        alternative: u32,
    },
    VariantTag(ExpressionId),
    Propagate {
        value: ExpressionId,
        target: RecordId,
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
    RecordField {
        local: LocalId,
        offset: u32,
        type_id: TypeId,
    },
}
