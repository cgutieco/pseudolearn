use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use pseudolearn_ir::Operation;
use pseudolearn_semantic::identities::ExpressionId;
use pseudolearn_semantic::identities::StatementId;
use pseudolearn_semantic::statement_model::HirStatement;
use pseudolearn_source::Span;

pub(crate) fn lower_scope(body: &[StatementId], context: &mut StatementContext<'_, '_>) {
    crate::statements::lower_statement_list(body, context);
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

pub(crate) fn dispatch(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) -> bool {
    let HirStatement::Spawn(expression) = statement else {
        return false;
    };
    lower_spawn(*expression, span, context);
    true
}
