#![forbid(unsafe_code)]

use crate::lowering::Lowering;
use cranelift_codegen::ir::{InstBuilder, Value, types};
use pseudolearn_ir::ValueId;

#[derive(Clone, Copy, Debug)]
pub(crate) enum Definition {
    Defined,
    Undefined,
    Flag(Value),
}

pub(crate) fn definition_of(lowering: &Lowering<'_, '_>, value: ValueId) -> Definition {
    lowering
        .definitions
        .get(&value)
        .copied()
        .unwrap_or(Definition::Defined)
}

pub(crate) fn flag_of(lowering: &mut Lowering<'_, '_>, value: ValueId) -> Value {
    match definition_of(lowering, value) {
        Definition::Defined => lowering.builder.ins().iconst(types::I8, 1),
        Definition::Undefined => lowering.builder.ins().iconst(types::I8, 0),
        Definition::Flag(flag) => flag,
    }
}
