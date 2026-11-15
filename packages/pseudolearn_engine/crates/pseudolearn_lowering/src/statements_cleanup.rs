use crate::statement_context::StatementContext;
use pseudolearn_semantic::HirStatement;
use pseudolearn_source::Span;

pub(crate) fn dispatch(
    statement: &HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) -> bool {
    match statement {
        HirStatement::ForEach {
            collection,
            bindings,
            body,
        } => {
            crate::statements_for_each::lower((*collection, span), bindings, body, context);
            true
        }
        HirStatement::Break => {
            crate::loop_exits::lower(span, context);
            true
        }
        HirStatement::Defer(body) => {
            if let Some(scope) = context.builder.cleanup.scopes.last_mut() {
                scope.push(body.clone());
            }
            true
        }
        _ => false,
    }
}
