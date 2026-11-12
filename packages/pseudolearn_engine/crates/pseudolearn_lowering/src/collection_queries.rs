use crate::builder::FunctionBuilder;
use crate::collection_builder::*;
use pseudolearn_ir::{Function, IrSpan, IrType, Operand, Operation, PredicateKind, ValueId};

pub(crate) fn comparison(
    builder: &mut FunctionBuilder,
    kind: IrType,
    values: (ValueId, ValueId),
    predicate: PredicateKind,
) -> ValueId {
    if kind == IrType::Bool && !matches!(predicate, PredicateKind::Equal | PredicateKind::NotEqual)
    {
        let left = emit(
            builder,
            Operation::ValueReinterpret,
            vec![Operand::Type(IrType::I64), Operand::Value(values.0)],
        );
        let right = emit(
            builder,
            Operation::ValueReinterpret,
            vec![Operand::Type(IrType::I64), Operand::Value(values.1)],
        );
        return comparison(builder, IrType::I64, (left, right), predicate);
    }
    let operation = match kind {
        IrType::F64 => Operation::RealCmp,
        IrType::Str => Operation::TextCmp,
        IrType::Char => Operation::CharCmp,
        IrType::Bool => Operation::BoolCmp,
        _ => Operation::IntCmp,
    };
    emit(
        builder,
        operation,
        vec![
            Operand::Predicate(predicate),
            Operand::Value(values.0),
            Operand::Value(values.1),
        ],
    )
}

pub(crate) fn index(name: String, kinds: (IrType, IrType), span: Option<IrSpan>) -> Function {
    let mut builder = FunctionBuilder::new(name, IrType::I64);
    builder.generated_span = span;
    let source = parameter(&mut builder, kinds.0);
    let needle = parameter(&mut builder, kinds.1.clone());
    let entry = builder.create_block();
    builder.set_current_block(entry);
    let zero = integer(&mut builder, 0);
    let position = local(&mut builder, zero);
    let length = emit(
        &mut builder,
        Operation::CollectionLength,
        vec![Operand::Value(source)],
    );
    search(&mut builder, (source, needle, position), (length, kinds.1));
    finish(builder, span)
}

fn search(
    builder: &mut FunctionBuilder,
    values: (ValueId, ValueId, ValueId),
    model: (ValueId, IrType),
) {
    let (source, needle, cell) = values;
    let header = builder.create_block();
    let body = builder.create_block();
    let next = builder.create_block();
    let found = builder.create_block();
    let absent = builder.create_block();
    jump(builder, header);
    builder.set_current_block(header);
    let position = read(builder, cell);
    let more = compare(builder, PredicateKind::LessThan, (position, model.0));
    branch(builder, more, (body, absent));
    builder.set_current_block(body);
    let value = load(builder, (source, position), (0, model.1.clone()));
    let equal = comparison(builder, model.1, (value, needle), PredicateKind::Equal);
    branch(builder, equal, (found, next));
    builder.set_current_block(found);
    builder.emit_void(Operation::Return, vec![Operand::Value(position)], None);
    builder.set_current_block(next);
    let one = integer(builder, 1);
    increment(builder, cell, one);
    jump(builder, header);
    builder.set_current_block(absent);
    let missing = integer(builder, -1);
    builder.emit_void(Operation::Return, vec![Operand::Value(missing)], None);
}

pub(crate) fn keys(name: String, kinds: (IrType, IrType), span: Option<IrSpan>) -> Function {
    let mut builder = FunctionBuilder::new(name, kinds.1.clone());
    builder.generated_span = span;
    let source = parameter(&mut builder, kinds.0);
    let entry = builder.create_block();
    builder.set_current_block(entry);
    let result = emit(
        &mut builder,
        Operation::CollectionNew,
        vec![Operand::Type(kinds.1)],
    );
    copy_keys(&mut builder, source, result);
    finish(builder, span)
}

fn copy_keys(builder: &mut FunctionBuilder, source: ValueId, result: ValueId) {
    let zero = integer(builder, 0);
    let cursor = local(builder, zero);
    let header = builder.create_block();
    let body = builder.create_block();
    let done = builder.create_block();
    jump(builder, header);
    builder.set_current_block(header);
    let current = read(builder, cursor);
    let position = binary(builder, Operation::CollectionNext, (source, current));
    let present = compare(builder, PredicateKind::GreaterEqual, (position, zero));
    branch(builder, present, (body, done));
    builder.set_current_block(body);
    let key = binary(builder, Operation::CollectionKey, (source, position));
    let length = emit(
        builder,
        Operation::CollectionLength,
        vec![Operand::Value(result)],
    );
    builder.emit_void(
        Operation::CollectionInsert,
        vec![
            Operand::Value(result),
            Operand::Value(length),
            Operand::Value(key),
        ],
        None,
    );
    let one = integer(builder, 1);
    let next = binary(builder, Operation::IntAdd, (position, one));
    store(builder, cursor, next);
    jump(builder, header);
    builder.set_current_block(done);
    builder.emit_void(Operation::Return, vec![Operand::Value(result)], None);
}
