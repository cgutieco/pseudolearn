use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use pseudolearn_ir::Operation;
use pseudolearn_semantic::identities::ExpressionId;
use pseudolearn_semantic::identities::StatementId;
use pseudolearn_semantic::statement_model::HirStatement;
use pseudolearn_source::Span;

pub(crate) fn lower_scope(
    body: &[StatementId],
    source_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(source_span, context.expression_context.source);
    let scope = context.builder.next_value();
    context
        .builder
        .emit_with_target(Operation::TaskScopeOpen, Vec::new(), (Some(scope), span));
    context.builder.task_scopes.push(scope);
    crate::statements::open_statement_list(body, context);
    if !crate::builder::is_current_block_terminated(context.builder) {
        emit_scope_join(scope, span, context.builder);
    }
    crate::cleanup_edges::finish(context);
    context.builder.task_scopes.pop();
}

pub(crate) fn lower_spawn(
    expression: ExpressionId,
    statement_span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let span = resolve_span(statement_span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, vec![], span);
    crate::expressions::lower_expression(
        expression,
        context.expression_context,
        context.environment,
        context.builder,
    );
    context.builder.emit_void(Operation::StmtExit, vec![], span);
}

pub(crate) fn emit_scope_join(
    scope: pseudolearn_ir::ValueId,
    span: Option<pseudolearn_ir::IrSpan>,
    builder: &mut crate::builder::FunctionBuilder,
) {
    builder.emit_void(
        Operation::TaskScopeJoin,
        vec![pseudolearn_ir::Operand::Value(scope)],
        span,
    );
}

pub(crate) fn emit_active_scope_joins(
    depth: usize,
    span: Option<pseudolearn_ir::IrSpan>,
    builder: &mut crate::builder::FunctionBuilder,
) {
    let scopes = builder
        .task_scopes
        .iter()
        .skip(depth)
        .rev()
        .copied()
        .collect::<Vec<_>>();
    for scope in scopes {
        emit_scope_join(scope, span, builder);
    }
}

pub(crate) fn dispatch(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) -> bool {
    match statement {
        HirStatement::Spawn(expression) => {
            lower_spawn(*expression, span, context);
            true
        }
        HirStatement::TaskScope { body, .. } => {
            lower_scope(body, span, context);
            true
        }
        _ => false,
    }
}
