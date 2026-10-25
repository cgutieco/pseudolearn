#![forbid(unsafe_code)]

use crate::builder::is_current_block_terminated;
use crate::environment::{VariableEnvironment, get_local_ir_type};
use crate::expressions::lower_expression;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements::lower_statement_list;
use pseudolearn_ir::{BlockId, IrSpan, Operand, Operation, OriginEntry, ValueId, VariableId};
use pseudolearn_semantic::identities::{ExpressionId, LocalId, StatementId};
use pseudolearn_source::Span;
use std::collections::HashSet;

pub fn lower_while(
    condition: ExpressionId,
    body: &[StatementId],
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    let mut loop_locals = collect_modified_locals(body, context.expression_context.module);
    loop_locals.retain(|local_id| context.environment.get_cell(*local_id).is_none());

    let header_block = context.builder.create_block();
    jump_to_loop_header(header_block, &loop_locals, context);

    context.builder.set_current_block(header_block);
    let mut header_environment = context.environment.clone();
    bind_loop_parameters(header_block, &loop_locals, &mut header_environment, context);

    let condition_value =
        evaluate_while_condition(condition, span, &mut header_environment, context);
    let body_block = context.builder.create_block();
    let exit_block = context.builder.create_block();
    emit_loop_branch(condition_value, body_block, exit_block, context);

    execute_while_body(
        body,
        (header_block, body_block),
        (&loop_locals, &header_environment),
        context,
    );

    context.builder.set_current_block(exit_block);
    context.builder.emit_void(Operation::StmtExit, vec![], span);
    *context.environment = header_environment;
}

fn evaluate_while_condition(
    condition: ExpressionId,
    span: Option<IrSpan>,
    environment: &mut VariableEnvironment,
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    let condition_value = lower_expression(
        condition,
        context.expression_context,
        environment,
        context.builder,
    );
    context.builder.emit_void(
        Operation::DecideBool,
        vec![Operand::Value(condition_value)],
        span,
    );
    condition_value
}

pub fn jump_to_loop_header(
    target_block: BlockId,
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
            target_block,
            arguments: initial_arguments,
        }],
        None,
    );
}

pub fn bind_loop_parameters(
    block: BlockId,
    loop_locals: &[LocalId],
    environment: &mut VariableEnvironment,
    context: &mut StatementContext<'_, '_>,
) {
    for &local_id in loop_locals {
        let parameter_value = context.builder.next_value();
        let parameter_type = get_local_ir_type(local_id, context.expression_context.module);
        context
            .builder
            .add_block_parameter(block, parameter_value, parameter_type);
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

fn emit_loop_branch(
    condition_value: ValueId,
    body_block: BlockId,
    exit_block: BlockId,
    context: &mut StatementContext<'_, '_>,
) {
    context.builder.emit_void(
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

fn execute_while_body(
    body: &[StatementId],
    blocks: (BlockId, BlockId),
    loop_state: (&[LocalId], &VariableEnvironment),
    context: &mut StatementContext<'_, '_>,
) {
    let (header_block, body_block) = blocks;
    let (loop_locals, header_environment) = loop_state;
    context.builder.set_current_block(body_block);
    let mut body_environment = header_environment.clone();
    let mut body_context = StatementContext {
        expression_context: context.expression_context,
        environment: &mut body_environment,
        builder: context.builder,
        origins: context.origins,
    };
    lower_statement_list(body, &mut body_context);

    if !is_current_block_terminated(context.builder) {
        let mut loop_back_arguments = Vec::new();
        for &local_id in loop_locals {
            let next_value = body_environment
                .get_value(local_id)
                .unwrap_or_else(|| context.builder.next_value());
            loop_back_arguments.push(next_value);
        }
        context.builder.emit_void(
            Operation::Jump,
            vec![Operand::BlockTarget {
                target_block: header_block,
                arguments: loop_back_arguments,
            }],
            None,
        );
    }
}

pub fn collect_modified_locals(
    body: &[StatementId],
    module: &pseudolearn_semantic::hir::HirModule,
) -> Vec<LocalId> {
    let mut modified = HashSet::new();
    for &statement_id in body {
        collect_from_statement(statement_id, module, &mut modified);
    }
    let mut result: Vec<LocalId> = modified.into_iter().collect();
    result.sort_by_key(|local_id| local_id.0);
    result
}

fn collect_from_statement(
    statement_id: StatementId,
    module: &pseudolearn_semantic::hir::HirModule,
    modified: &mut HashSet<LocalId>,
) {
    let index = usize::try_from(statement_id.0).unwrap_or(0);
    let Some(statement) = module.statements.kinds.get(index) else {
        return;
    };
    collect_statement_locals(statement, module, modified);
}

fn collect_statement_locals(
    statement: &pseudolearn_semantic::statement_model::HirStatement,
    module: &pseudolearn_semantic::hir::HirModule,
    modified: &mut HashSet<LocalId>,
) {
    match statement {
        pseudolearn_semantic::statement_model::HirStatement::Assign { destination, .. } => {
            modified.extend(crate::records::destination_targets(destination, module));
        }
        pseudolearn_semantic::statement_model::HirStatement::Read(places) => {
            collect_from_read_places(places, module, modified);
        }
        pseudolearn_semantic::statement_model::HirStatement::Conditional {
            affirmative,
            negative,
            ..
        } => {
            collect_nested_statements(affirmative, module, modified);
            collect_nested_statements(negative, module, modified);
        }
        pseudolearn_semantic::statement_model::HirStatement::While { body, .. }
        | pseudolearn_semantic::statement_model::HirStatement::Repeat { body, .. } => {
            collect_nested_statements(body, module, modified);
        }
        pseudolearn_semantic::statement_model::HirStatement::For { control, body, .. } => {
            modified.insert(*control);
            collect_nested_statements(body, module, modified);
        }
        pseudolearn_semantic::statement_model::HirStatement::Switch { cases, default, .. } => {
            collect_switch_statements(cases, default, module, modified);
        }
        _ => {}
    }
}

fn collect_switch_statements(
    cases: &[pseudolearn_semantic::statement_model::HirCase],
    default: &[StatementId],
    module: &pseudolearn_semantic::hir::HirModule,
    modified: &mut HashSet<LocalId>,
) {
    for case in cases {
        collect_nested_statements(&case.body, module, modified);
    }
    collect_nested_statements(default, module, modified);
}

fn collect_nested_statements(
    statements: &[StatementId],
    module: &pseudolearn_semantic::hir::HirModule,
    modified: &mut HashSet<LocalId>,
) {
    for statement_id in statements {
        collect_from_statement(*statement_id, module, modified);
    }
}

fn collect_from_read_places(
    places: &[pseudolearn_semantic::expression_model::HirPlace],
    module: &pseudolearn_semantic::hir::HirModule,
    modified: &mut HashSet<LocalId>,
) {
    for place in places {
        match place {
            pseudolearn_semantic::expression_model::HirPlace::Local(local_id) => {
                modified.insert(*local_id);
            }
            pseudolearn_semantic::expression_model::HirPlace::RecordField { .. } => {
                modified.extend(crate::records::destination_targets(place, module));
            }
            _ => {}
        }
    }
}
