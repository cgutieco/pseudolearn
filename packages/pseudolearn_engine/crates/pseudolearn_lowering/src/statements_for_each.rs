use crate::builder::is_current_block_terminated;
use crate::environment::VariableEnvironment;
use crate::expressions::{ExpressionState, lower_expression};
use crate::statement_context::StatementContext;
use pseudolearn_ir::{BlockId, IrSpan, IrType, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::collection_model::HirCollection;
use pseudolearn_semantic::{ExpressionId, LocalId, StatementId};

pub(crate) struct Iteration {
    pub(crate) collection: ValueId,
    pub(crate) version: Option<ValueId>,
    pub(crate) length: Option<ValueId>,
    pub(crate) descriptor: Option<HirCollection>,
    pub(crate) span: Option<IrSpan>,
}

pub(crate) fn lower(
    source: (ExpressionId, pseudolearn_source::Span),
    bindings: &[LocalId],
    body: &[StatementId],
    context: &mut StatementContext<'_, '_>,
) {
    let (collection, raw_span) = source;
    let span = crate::spans::resolve_span(raw_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    let iteration = prepare(collection, span, context);
    let locals = crate::statements_while::carried_locals(body, context);
    let header = context.builder.create_block();
    let cursor = start(header, &locals, context);
    let mut environment = context.environment.clone();
    crate::statements_while::bind_loop_parameters(header, &locals, &mut environment, context);
    let position = condition(&iteration, cursor, context);
    let body_block = context.builder.create_block();
    let exit = context.builder.create_block();
    let condition = comparison(&iteration, (cursor, position), context);
    context.builder.emit_void(
        Operation::DecideBool,
        vec![Operand::Value(condition)],
        iteration.span,
    );
    crate::enum_output::branch(condition, (body_block, exit), context.builder);
    crate::loop_exits::enter(body, exit, context);
    context.builder.set_current_block(body_block);
    execute(
        &iteration,
        (bindings, body),
        (header, position, &locals),
        (&environment, context),
    );
    *context.environment = crate::loop_exits::finish(environment, true, context);
    context
        .builder
        .emit_void(Operation::StmtExit, vec![], iteration.span);
}

fn prepare(
    expression: ExpressionId,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) -> Iteration {
    let descriptor = crate::collections::model(expression, context.expression_context.module);
    let collection = lower_expression(
        expression,
        context.expression_context,
        context.environment,
        context.builder,
    );
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: context.environment,
        builder: context.builder,
    };
    let version = descriptor.as_ref().map(|_| {
        crate::collections::emit(
            Operation::CollectionVersion,
            vec![Operand::Value(collection)],
            span,
            &mut state,
        )
    });
    let length = sequence_length(&descriptor, collection, span, &mut state);
    Iteration {
        collection,
        version,
        length,
        descriptor,
        span,
    }
}

fn start(header: BlockId, locals: &[LocalId], context: &mut StatementContext<'_, '_>) -> ValueId {
    let zero = constant(0, context.builder);
    let mut arguments = vec![zero];
    arguments.extend(
        locals
            .iter()
            .filter_map(|local| context.environment.get_value(*local)),
    );
    context.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: header,
            arguments,
        }],
        None,
    );
    context.builder.set_current_block(header);
    let cursor = context.builder.next_value();
    context
        .builder
        .add_block_parameter(header, cursor, IrType::I64);
    cursor
}

fn condition(
    iteration: &Iteration,
    cursor: ValueId,
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    if let Some(version) = iteration.version {
        context.builder.emit_void(
            Operation::CollectionCheck,
            vec![
                Operand::Value(iteration.collection),
                Operand::Value(version),
            ],
            iteration.span,
        );
    }
    if iteration.length.is_some() {
        return cursor;
    }
    let result = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::CollectionNext,
        vec![Operand::Value(iteration.collection), Operand::Value(cursor)],
        (Some(result), iteration.span),
    );
    result
}

fn comparison(
    iteration: &Iteration,
    values: (ValueId, ValueId),
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    let (predicate, left, right) = if let Some(length) = iteration.length {
        (PredicateKind::LessThan, values.0, length)
    } else {
        (
            PredicateKind::GreaterEqual,
            values.1,
            constant(0, context.builder),
        )
    };
    let result = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::IntCmp,
        vec![
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ],
        (Some(result), iteration.span),
    );
    result
}

fn execute(
    iteration: &Iteration,
    body: (&[LocalId], &[StatementId]),
    header: (BlockId, ValueId, &[LocalId]),
    context: (&VariableEnvironment, &mut StatementContext<'_, '_>),
) {
    let (environment, context) = context;
    let mut environment = environment.clone();
    let mut body_context = StatementContext {
        expression_context: context.expression_context,
        environment: &mut environment,
        builder: context.builder,
        origins: context.origins,
    };
    bind(iteration, body.0, header.1, &mut body_context);
    crate::statements::lower_statement_list(body.1, &mut body_context);
    if is_current_block_terminated(body_context.builder) {
        return;
    }
    let one = constant(1, body_context.builder);
    let next = body_context.builder.next_value();
    body_context.builder.emit_with_target(
        Operation::IntAdd,
        vec![Operand::Value(header.1), Operand::Value(one)],
        (Some(next), iteration.span),
    );
    let mut arguments = vec![next];
    arguments.extend(
        header
            .2
            .iter()
            .filter_map(|local| body_context.environment.get_value(*local)),
    );
    jump(body_context.builder, header.0, arguments);
}

fn bind(
    iteration: &Iteration,
    bindings: &[LocalId],
    position: ValueId,
    context: &mut StatementContext<'_, '_>,
) {
    let values = crate::iteration_values::binding_values(iteration, position, context);
    for (binding, values) in bindings.iter().zip(values) {
        for (local, value) in crate::records::targets(*binding, context.expression_context.module)
            .into_iter()
            .zip(values)
        {
            crate::statements_assignment::lower_assign_local(local, value, iteration.span, context);
        }
    }
}

fn constant(value: i64, builder: &mut crate::FunctionBuilder) -> ValueId {
    let result = builder.next_value();
    builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(value)],
        (Some(result), None),
    );
    result
}

fn sequence_length(
    descriptor: &Option<HirCollection>,
    collection: ValueId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<ValueId> {
    if descriptor.as_ref().is_some_and(|model| model.key.is_some()) {
        None
    } else {
        Some(crate::collections::emit(
            if descriptor.is_some() {
                Operation::CollectionLength
            } else {
                Operation::ArrayLength
            },
            vec![Operand::Value(collection)],
            span,
            state,
        ))
    }
}

fn jump(builder: &mut crate::FunctionBuilder, target_block: BlockId, arguments: Vec<ValueId>) {
    builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block,
            arguments,
        }],
        None,
    );
}
