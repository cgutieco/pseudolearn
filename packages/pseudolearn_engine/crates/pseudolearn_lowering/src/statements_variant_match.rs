use crate::expressions::ExpressionState;
use crate::statement_context::StatementContext;
use crate::statements_switch::SwitchStatementDescriptor;
use pseudolearn_ir::Operation;
use pseudolearn_semantic::variant_model::HirVariantMatch;
use pseudolearn_source::Span;

pub(crate) fn lower(
    matching: &HirVariantMatch,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) {
    let location = crate::spans::resolve_span(span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, Vec::new(), location);
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: context.environment,
        builder: context.builder,
    };
    let values = crate::variant_values::values(matching.value, &mut state);
    let targets = crate::records::targets(matching.storage, state.context.module);
    for (local, value) in targets.into_iter().zip(values) {
        state.environment.bind_value(local, value);
        state.environment.mark_assigned(local);
    }
    let descriptor = SwitchStatementDescriptor {
        selector: matching.selector,
        cases: &matching.cases,
        default_body: &matching.default,
        statement_span: span,
    };
    crate::statements_switch::lower_after_entry(&descriptor, context);
}
