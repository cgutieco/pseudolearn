use crate::builder::FunctionBuilder;
use crate::collection_builder::*;
use crate::collection_sort::{Pass, SortPlan};
use pseudolearn_ir::{IrType, Operand, Operation, PredicateKind, ValueId};

pub(crate) fn pass(builder: &mut FunctionBuilder, plan: &SortPlan, pass: &Pass) {
    let zero = integer(builder, 0);
    let start = local(builder, zero);
    let header = builder.create_block();
    let body = builder.create_block();
    let done = builder.create_block();
    jump(builder, header);
    builder.set_current_block(header);
    let current = read(builder, start);
    let more = compare(builder, PredicateKind::LessThan, (current, pass.length));
    branch(builder, more, (body, done));
    builder.set_current_block(body);
    let middle = binary(builder, Operation::IntAdd, (current, pass.width));
    let middle = binary(builder, Operation::IntMin, (middle, pass.length));
    let end = binary(builder, Operation::IntAdd, (middle, pass.width));
    let end = binary(builder, Operation::IntMin, (end, pass.length));
    merge(builder, plan, pass, (current, middle, end));
    store(builder, start, end);
    jump(builder, header);
    builder.set_current_block(done);
}

fn merge(
    builder: &mut FunctionBuilder,
    plan: &SortPlan,
    pass: &Pass,
    range: (ValueId, ValueId, ValueId),
) {
    let (start, middle, end) = range;
    let left = local(builder, start);
    let right = local(builder, middle);
    let destination = local(builder, start);
    let header = builder.create_block();
    let body = builder.create_block();
    let done = builder.create_block();
    jump(builder, header);
    builder.set_current_block(header);
    let output = read(builder, destination);
    let more = compare(builder, PredicateKind::LessThan, (output, end));
    branch(builder, more, (body, done));
    builder.set_current_block(body);
    choose(
        builder,
        plan,
        pass,
        Choice {
            left,
            right,
            output,
            middle,
            end,
        },
    );
    let one = integer(builder, 1);
    increment(builder, destination, one);
    jump(builder, header);
    builder.set_current_block(done);
}

struct Choice {
    left: ValueId,
    right: ValueId,
    output: ValueId,
    middle: ValueId,
    end: ValueId,
}

fn choose(builder: &mut FunctionBuilder, plan: &SortPlan, pass: &Pass, choice: Choice) {
    let left = read(builder, choice.left);
    let right = read(builder, choice.right);
    let take_left = builder.create_block();
    let take_right = builder.create_block();
    let check_right = builder.create_block();
    let compare_values = builder.create_block();
    let merged = builder.create_block();
    let exhausted = compare(builder, PredicateKind::GreaterEqual, (left, choice.middle));
    branch(builder, exhausted, (take_right, check_right));
    builder.set_current_block(check_right);
    let exhausted = compare(builder, PredicateKind::GreaterEqual, (right, choice.end));
    branch(builder, exhausted, (take_left, compare_values));
    builder.set_current_block(compare_values);
    let condition = order(builder, plan, pass, (left, right));
    branch(builder, condition, (take_left, take_right));
    for (block, index, cell) in [
        (take_left, left, choice.left),
        (take_right, right, choice.right),
    ] {
        builder.set_current_block(block);
        copy(builder, plan, pass, (index, choice.output));
        let one = integer(builder, 1);
        increment(builder, cell, one);
        jump(builder, merged);
    }
    builder.set_current_block(merged);
}

fn copy(builder: &mut FunctionBuilder, plan: &SortPlan, pass: &Pass, indices: (ValueId, ValueId)) {
    let mut operands = vec![Operand::Value(pass.scratch), Operand::Value(indices.1)];
    for (index, kind) in plan.leaves.iter().enumerate() {
        operands.push(Operand::Value(load(
            builder,
            (pass.source, indices.0),
            (index, kind.clone()),
        )));
    }
    builder.emit_void(Operation::CollectionStore, operands, None);
}

fn order(
    builder: &mut FunctionBuilder,
    plan: &SortPlan,
    pass: &Pass,
    indices: (ValueId, ValueId),
) -> ValueId {
    if let Some((code, environment)) = pass.comparator {
        let arguments = comparator_arguments(builder, plan, pass, (indices, environment));
        let result = emit(
            builder,
            Operation::CallIndirect,
            vec![
                Operand::Value(code),
                Operand::FunctionTarget {
                    function_name: crate::function_prototypes::name(
                        plan.signature.unwrap_or(u32::MAX),
                    ),
                    arguments,
                },
            ],
        );
        builder.emit_void(
            Operation::CollectionCheck,
            vec![Operand::Value(pass.original), Operand::Value(pass.version)],
            None,
        );
        let zero = integer(builder, 0);
        return compare(builder, PredicateKind::LessEqual, (result, zero));
    }
    let kind = plan.leaves.first().cloned().unwrap_or(IrType::I64);
    let left = load(builder, (pass.source, indices.0), (0, kind.clone()));
    let right = load(builder, (pass.source, indices.1), (0, kind.clone()));
    crate::collection_queries::comparison(builder, kind, (left, right), PredicateKind::LessEqual)
}

fn comparator_arguments(
    builder: &mut FunctionBuilder,
    plan: &SortPlan,
    pass: &Pass,
    context: ((ValueId, ValueId), ValueId),
) -> Vec<ValueId> {
    let mut arguments = vec![context.1];
    for index in [context.0.0, context.0.1] {
        let mut values = vec![None; plan.leaves.len()];
        for (canonical, source) in plan.canonical.iter().enumerate() {
            if let (Some(slot), Some(kind)) = (values.get_mut(*source), plan.leaves.get(canonical))
            {
                *slot = Some(load(
                    builder,
                    (pass.source, index),
                    (canonical, kind.clone()),
                ));
            }
        }
        arguments.extend(values.into_iter().flatten());
    }
    arguments
}
