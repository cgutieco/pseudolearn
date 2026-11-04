use crate::builder::FunctionBuilder;
use crate::collection_builder::*;
use pseudolearn_ir::{Function, IrSpan, IrType, Operand, Operation, PredicateKind, ValueId};

pub(crate) struct SortPlan {
    pub kind: IrType,
    pub leaves: Vec<IrType>,
    pub canonical: Vec<usize>,
    pub signature: Option<u32>,
}

pub(crate) fn build(name: String, plan: &SortPlan, span: Option<IrSpan>) -> Function {
    let mut builder = FunctionBuilder::new(name, IrType::Unit);
    builder.generated_span = span;
    let original = parameter(&mut builder, plan.kind.clone());
    let comparator = plan.signature.map(|_| {
        (
            parameter(&mut builder, IrType::I64),
            parameter(&mut builder, IrType::Str),
        )
    });
    let entry = builder.create_block();
    builder.set_current_block(entry);
    let pass = initialize(&mut builder, original, comparator);
    sort(&mut builder, plan, pass);
    finish(builder, span)
}

#[derive(Clone, Copy)]
pub(crate) struct Pass {
    pub original: ValueId,
    pub version: ValueId,
    pub source: ValueId,
    pub scratch: ValueId,
    pub length: ValueId,
    pub width: ValueId,
    pub comparator: Option<(ValueId, ValueId)>,
}

fn sort(builder: &mut FunctionBuilder, plan: &SortPlan, initial: Pass) {
    let one = integer(builder, 1);
    let width = local(builder, one);
    let header = builder.create_block();
    let body = builder.create_block();
    let done = builder.create_block();
    jump(builder, header);
    builder.set_current_block(header);
    let current = read(builder, width);
    let more = compare(builder, PredicateKind::LessThan, (current, initial.length));
    branch(builder, more, (body, done));
    builder.set_current_block(body);
    let pass = Pass {
        width: current,
        ..initial
    };
    crate::collection_merge::pass(builder, plan, &pass);
    builder.emit_void(
        Operation::CollectionCommit,
        vec![
            Operand::Value(initial.source),
            Operand::Value(initial.scratch),
        ],
        None,
    );
    let doubled = binary(builder, Operation::IntAdd, (current, current));
    store(builder, width, doubled);
    jump(builder, header);
    builder.set_current_block(done);
    commit(builder, &initial);
}

fn initialize(
    builder: &mut FunctionBuilder,
    original: ValueId,
    comparator: Option<(ValueId, ValueId)>,
) -> Pass {
    builder.emit_void(
        Operation::CollectionBeginSort,
        vec![Operand::Value(original)],
        None,
    );
    let version = emit(
        builder,
        Operation::CollectionVersion,
        vec![Operand::Value(original)],
    );
    let source = emit(
        builder,
        Operation::CollectionClone,
        vec![Operand::Value(original)],
    );
    let scratch = emit(
        builder,
        Operation::CollectionClone,
        vec![Operand::Value(original)],
    );
    let length = emit(
        builder,
        Operation::CollectionLength,
        vec![Operand::Value(original)],
    );
    Pass {
        original,
        version,
        source,
        scratch,
        length,
        width: length,
        comparator,
    }
}

fn commit(builder: &mut FunctionBuilder, pass: &Pass) {
    builder.emit_void(
        Operation::CollectionCheck,
        vec![Operand::Value(pass.original), Operand::Value(pass.version)],
        None,
    );
    builder.emit_void(
        Operation::CollectionCommit,
        vec![Operand::Value(pass.original), Operand::Value(pass.source)],
        None,
    );
    builder.emit_void(Operation::Return, Vec::new(), None);
}
