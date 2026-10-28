use crate::environment::VariableEnvironment;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{BlockId, Operand, Operation};
use pseudolearn_semantic::{HirStatement, LocalId, StatementId};

#[derive(Clone, Debug, PartialEq)]
pub struct LoopExit {
    pub target: BlockId,
    pub normal: BlockId,
    pub depth: usize,
    pub task_scope_depth: usize,
    pub locals: Vec<LocalId>,
    pub joined: bool,
}

pub(crate) fn enter(body: &[StatementId], normal: BlockId, context: &mut StatementContext<'_, '_>) {
    let joined = has_break(body, context.expression_context.module);
    let target = if joined {
        context.builder.create_block()
    } else {
        normal
    };
    let locals = crate::statements_while::carried_locals(body, context);
    context.builder.loop_exits.push(LoopExit {
        target,
        normal,
        depth: context.builder.cleanup.scopes.len(),
        task_scope_depth: context.builder.task_scopes.len(),
        locals,
        joined,
    });
}

pub(crate) fn finish(
    normal: VariableEnvironment,
    reachable: bool,
    context: &mut StatementContext<'_, '_>,
) -> VariableEnvironment {
    let Some(exit) = context.builder.loop_exits.pop() else {
        return normal;
    };
    if !reachable {
        context
            .builder
            .blocks
            .retain(|block| block.identifier != exit.normal);
    }
    if !exit.joined {
        if reachable {
            context.builder.set_current_block(exit.normal);
        }
        return normal;
    }
    connect_normal_exit(&exit, &normal, reachable, context);
    context.builder.set_current_block(exit.target);
    let mut environment = normal;
    crate::statements_while::bind_loop_parameters(
        exit.target,
        &exit.locals,
        &mut environment,
        context,
    );
    environment
}

pub(crate) fn lower(span: pseudolearn_source::Span, context: &mut StatementContext<'_, '_>) {
    let Some(exit) = context.builder.loop_exits.last().cloned() else {
        return;
    };
    let span = crate::spans::resolve_span(span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    crate::task_scopes::emit_active_scope_joins(exit.task_scope_depth, span, context.builder);
    crate::cleanup_edges::emit(
        context.expression_context,
        context.environment,
        context.builder,
        exit.depth,
    );
    let arguments = if exit.joined {
        exit.locals
            .iter()
            .filter_map(|local| context.environment.get_value(*local))
            .collect()
    } else {
        Vec::new()
    };
    context.builder.emit_void(Operation::StmtExit, vec![], span);
    context.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: exit.target,
            arguments,
        }],
        span,
    );
}

fn has_break(body: &[StatementId], module: &pseudolearn_semantic::HirModule) -> bool {
    body.iter()
        .filter_map(|statement| {
            usize::try_from(statement.0)
                .ok()
                .and_then(|index| module.statements.kinds.get(index))
        })
        .any(|statement| match statement {
            HirStatement::Break => true,
            HirStatement::Conditional {
                affirmative,
                negative,
                ..
            } => has_break(affirmative, module) || has_break(negative, module),
            HirStatement::Switch { cases, default, .. } => {
                cases.iter().any(|case| has_break(&case.body, module)) || has_break(default, module)
            }
            HirStatement::VariantMatch(matching) => {
                matching
                    .cases
                    .iter()
                    .any(|case| has_break(&case.body, module))
                    || has_break(&matching.default, module)
            }
            _ => false,
        })
}

fn connect_normal_exit(
    exit: &LoopExit,
    normal: &VariableEnvironment,
    reachable: bool,
    context: &mut StatementContext<'_, '_>,
) {
    if reachable {
        context.builder.set_current_block(exit.normal);
        let arguments = exit
            .locals
            .iter()
            .filter_map(|local| normal.get_value(*local))
            .collect();
        context.builder.emit_void(
            Operation::Jump,
            vec![Operand::BlockTarget {
                target_block: exit.target,
                arguments,
            }],
            None,
        );
    }
}
