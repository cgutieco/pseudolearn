use crate::builder::FunctionBuilder;
use pseudolearn_ir::{
    BlockId, Function, IrSpan, IrType, Operand, Operation, PredicateKind, ValueId,
};

pub(crate) fn emit(
    builder: &mut FunctionBuilder,
    operation: Operation,
    operands: Vec<Operand>,
) -> ValueId {
    let result = builder.next_value();
    builder.emit_with_target(operation, operands, (Some(result), None));
    result
}

pub(crate) fn integer(builder: &mut FunctionBuilder, value: i64) -> ValueId {
    emit(
        builder,
        Operation::ConstI64,
        vec![Operand::LiteralI64(value)],
    )
}

pub(crate) fn binary(
    builder: &mut FunctionBuilder,
    operation: Operation,
    values: (ValueId, ValueId),
) -> ValueId {
    emit(
        builder,
        operation,
        vec![Operand::Value(values.0), Operand::Value(values.1)],
    )
}

pub(crate) fn compare(
    builder: &mut FunctionBuilder,
    predicate: PredicateKind,
    values: (ValueId, ValueId),
) -> ValueId {
    emit(
        builder,
        Operation::IntCmp,
        vec![
            Operand::Predicate(predicate),
            Operand::Value(values.0),
            Operand::Value(values.1),
        ],
    )
}

pub(crate) fn jump(builder: &mut FunctionBuilder, block: BlockId) {
    builder.emit_void(Operation::Jump, vec![target(block)], None);
}

pub(crate) fn branch(
    builder: &mut FunctionBuilder,
    condition: ValueId,
    blocks: (BlockId, BlockId),
) {
    builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(condition),
            target(blocks.0),
            target(blocks.1),
        ],
        None,
    );
}

fn target(block: BlockId) -> Operand {
    Operand::BlockTarget {
        target_block: block,
        arguments: Vec::new(),
    }
}

pub(crate) fn local(builder: &mut FunctionBuilder, value: ValueId) -> ValueId {
    let cell = emit(
        builder,
        Operation::CellLocal,
        vec![Operand::Type(IrType::I64)],
    );
    store(builder, cell, value);
    cell
}

pub(crate) fn store(builder: &mut FunctionBuilder, cell: ValueId, value: ValueId) {
    builder.emit_void(
        Operation::CellStore,
        vec![Operand::Value(cell), Operand::Value(value)],
        None,
    );
}

pub(crate) fn read(builder: &mut FunctionBuilder, cell: ValueId) -> ValueId {
    emit(builder, Operation::CellLoad, vec![Operand::Value(cell)])
}

pub(crate) fn increment(builder: &mut FunctionBuilder, cell: ValueId, step: ValueId) {
    let value = read(builder, cell);
    let next = binary(builder, Operation::IntAdd, (value, step));
    store(builder, cell, next);
}

pub(crate) fn parameter(builder: &mut FunctionBuilder, kind: IrType) -> ValueId {
    let value = builder.next_value();
    builder.parameters.push((value, kind));
    value
}

pub(crate) fn finish(builder: FunctionBuilder, span: Option<IrSpan>) -> Function {
    Function {
        suspendible: false,
        name: builder.name,
        parameters: builder.parameters,
        return_type: builder.return_type,
        columns: builder.columns,
        blocks: builder.blocks,
        declaration_span: span,
    }
}

pub(crate) fn load(
    builder: &mut FunctionBuilder,
    source: (ValueId, ValueId),
    leaf: (usize, IrType),
) -> ValueId {
    emit(
        builder,
        Operation::CollectionLoad,
        vec![
            Operand::Type(leaf.1),
            Operand::Value(source.0),
            Operand::Value(source.1),
            Operand::LiteralI64(i64::try_from(leaf.0).unwrap_or(i64::MAX)),
        ],
    )
}
