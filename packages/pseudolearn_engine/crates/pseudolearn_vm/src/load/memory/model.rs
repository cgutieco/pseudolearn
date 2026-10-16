use crate::load::Source;
use pseudolearn_bytecode::{Opcode, Register};
use pseudolearn_runtime::ValueKind;

#[derive(Clone, Copy, Debug, PartialEq)]
pub(crate) enum ValueSource {
    Scalar(Source),
    Reference(u16),
    LiteralText(u32),
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub(crate) struct TypedSource {
    pub source: ValueSource,
    pub kind: ValueKind,
}

#[derive(Clone, Debug, PartialEq)]
pub(crate) enum MemoryOp {
    ArrayNew {
        destination: u16,
        element: ValueKind,
        dimensions: Vec<Source>,
    },
    ArrayRead {
        destination: Register,
        array: u16,
        indices: Vec<Source>,
    },
    ArrayWrite {
        array: u16,
        indices: Vec<Source>,
        source: TypedSource,
    },
    Text {
        opcode: Opcode,
        destination: Register,
        sources: Vec<TypedSource>,
        predicate: Option<String>,
    },
    Output {
        sources: Vec<TypedSource>,
        newline: bool,
    },
    ObjectNew {
        destination: u16,
        class: usize,
    },
    ObjectCopy {
        destination: u16,
        source: u16,
    },
    ReferenceCompare {
        destination: u16,
        left: u16,
        right: u16,
        equal: bool,
    },
    CellLocal {
        destination: u16,
        kind: ValueKind,
        slot: Register,
    },
    CellElement {
        destination: u16,
        array: u16,
        indices: Vec<Source>,
    },
    CellField {
        destination: u16,
        receiver: u16,
        offset: usize,
    },
    CellLoad {
        destination: Register,
        cell: u16,
    },
    CellStore {
        cell: u16,
        source: TypedSource,
    },
    Random {
        destination: u16,
    },
}
