#![forbid(unsafe_code)]

use crate::builder::{FunctionBuilder, is_current_block_terminated};
use crate::environment::{VariableEnvironment, get_local_ir_type};
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements::lower_statement_list;
use crate::statements_for_condition::{evaluate_for_bounds, lower_for_condition};
use crate::statements_while::collect_modified_locals;
use pseudolearn_ir::{BlockId, IrSpan, Operand, Operation, OriginEntry, ValueId, VariableId};
use pseudolearn_semantic::identities::{ExpressionId, LocalId, StatementId};
use pseudolearn_source::Span;

pub struct ForLoopDescriptor<'context_lifetime> {
    pub control: LocalId,
    pub initial: ExpressionId,
    pub ending: ExpressionId,
    pub step: Option<ExpressionId>,
    pub body: &'context_lifetime [StatementId],
    pub statement_span: Span,
}

struct ForHeaderState<'context_lifetime> {
    pub header_block: BlockId,
    pub body_block: BlockId,
    pub loop_locals: &'context_lifetime [LocalId],
    pub header_environment: &'context_lifetime VariableEnvironment,
    pub current_control: ValueId,
    pub step_value: ValueId,
    pub control: LocalId,
}

pub fn lower_for(descriptor: &ForLoopDescriptor<'_>, context: &mut StatementContext<'_, '_>) {
    let span = resolve_span(descriptor.statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);

    let (initial_value, ending_value, step_value) = evaluate_for_bounds(descriptor, span, context);
    context
        .environment
        .bind_value(descriptor.control, initial_value);
    context.environment.mark_assigned(descriptor.control);

    let (header_block, loop_locals, header_environment) = setup_for_header(descriptor, context);
    let current_control = header_environment
        .get_value(descriptor.control)
        .unwrap_or_else(|| context.builder.next_value());
    let (body_block, exit_block) = evaluate_and_branch_condition(
        (current_control, ending_value),
        step_value,
        span,
        context.builder,
    );

    let header_state = ForHeaderState {
        header_block,
        body_block,
        loop_locals: &loop_locals,
        header_environment: &header_environment,
        current_control,
        step_value,
        control: descriptor.control,
    };
    execute_for_body(descriptor, &header_state, span, context);

    context.builder.set_current_block(exit_block);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
    *context.environment = header_environment;
}

fn setup_for_header(
    descriptor: &ForLoopDescriptor<'_>,
    context: &mut StatementContext<'_, '_>,
) -> (BlockId, Vec<LocalId>, VariableEnvironment) {
    let loop_locals = prepare_for_locals(descriptor.body, descriptor.control, context);
    let header_block = context.builder.create_block();
    jump_to_for_header(header_block, &loop_locals, context);
    context.builder.set_current_block(header_block);
    let mut header_environment = context.environment.clone();
    bind_for_parameters(header_block, &loop_locals, &mut header_environment, context);
    (header_block, loop_locals, header_environment)
}

fn evaluate_and_branch_condition(
    bounds: (ValueId, ValueId),
    step_value: ValueId,
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> (BlockId, BlockId) {
    let (current_control, ending_value) = bounds;
    let condition_value =
        lower_for_condition((current_control, ending_value), step_value, span, builder);
    builder.emit_void(
        Operation::DecideBool,
        vec![Operand::Value(condition_value)],
        span,
    );
    let body_block = builder.create_block();
    let exit_block = builder.create_block();
    emit_for_branch(condition_value, body_block, exit_block, builder);
    (body_block, exit_block)
}

fn prepare_for_locals(
    body: &[StatementId],
    control: LocalId,
    context: &StatementContext<'_, '_>,
) -> Vec<LocalId> {
    let mut loop_locals = collect_modified_locals(body, context.expression_context.module);
    if !loop_locals.contains(&control) {
        loop_locals.push(control);
    }
    loop_locals.retain(|local_id| context.environment.get_cell(*local_id).is_none());
    loop_locals.sort_by_key(|local_id| local_id.0);
    loop_locals
}

fn jump_to_for_header(
    header_block: BlockId,
    loop_locals: &[LocalId],
    context: &mut StatementContext<'_, '_>,
) {
    let mut initial_arguments = Vec::new();
    for &local_id in loop_locals {
        let current_value = context
            .environment
            .get_value(local_id)
            .unwrap_or_else(|| context.builder.next_value());
        initial_arguments.push(current_value);
    }
    context.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: header_block,
            arguments: initial_arguments,
        }],
        None,
    );
}

fn bind_for_parameters(
    header_block: BlockId,
    loop_locals: &[LocalId],
    environment: &mut VariableEnvironment,
    context: &mut StatementContext<'_, '_>,
) {
    for &local_id in loop_locals {
        let parameter_value = context.builder.next_value();
        let parameter_type = get_local_ir_type(local_id, context.expression_context.module);
        context
            .builder
            .add_block_parameter(header_block, parameter_value, parameter_type);
        let local_name = usize::try_from(local_id.0)
            .ok()
            .and_then(|local_index| context.expression_context.module.locals.get(local_index))
            .map(|local| local.name.clone())
            .unwrap_or_else(|| format!("v{}", local_id.0));
        context.origins.push(OriginEntry {
            function: context.builder.name.clone(),
            value: parameter_value,
            variable: VariableId(local_id.0),
            name: local_name,
        });
        environment.bind_value(local_id, parameter_value);
    }
}

fn emit_for_branch(
    condition_value: ValueId,
    body_block: BlockId,
    exit_block: BlockId,
    builder: &mut FunctionBuilder,
) {
    builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(condition_value),
            Operand::BlockTarget {
                target_block: body_block,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: exit_block,
                arguments: vec![],
            },
        ],
        None,
    );
}

fn execute_for_body(
    descriptor: &ForLoopDescriptor<'_>,
    state: &ForHeaderState<'_>,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    context.builder.set_current_block(state.body_block);
    let mut body_environment = state.header_environment.clone();
    let mut body_context = StatementContext {
        expression_context: context.expression_context,
        environment: &mut body_environment,
        builder: context.builder,
        origins: context.origins,
    };
    lower_statement_list(descriptor.body, &mut body_context);

    if !is_current_block_terminated(context.builder) {
        emit_for_body_step(state, span, &mut body_environment, context);
    }
}

fn emit_for_body_step(
    state: &ForHeaderState<'_>,
    span: Option<IrSpan>,
    body_environment: &mut VariableEnvironment,
    context: &mut StatementContext<'_, '_>,
) {
    let previous_control = body_environment
        .get_value(state.control)
        .unwrap_or(state.current_control);
    let next_control = context.builder.next_value();
    context.builder.emit_with_target(
        Operation::IntAdd,
        vec![
            Operand::Value(previous_control),
            Operand::Value(state.step_value),
        ],
        (Some(next_control), span),
    );
    body_environment.bind_value(state.control, next_control);

    let mut loop_back_arguments = Vec::new();
    for &local_id in state.loop_locals {
        let next_value = body_environment
            .get_value(local_id)
            .unwrap_or_else(|| context.builder.next_value());
        loop_back_arguments.push(next_value);
    }
    context.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: state.header_block,
            arguments: loop_back_arguments,
        }],
        None,
    );
}
