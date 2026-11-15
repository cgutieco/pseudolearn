use crate::expressions::ExpressionState;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{IrType, Operation};
use pseudolearn_semantic::channel_model::HirSelect;
use pseudolearn_source::Span;

pub(crate) fn lower(selection: &HirSelect, span: Span, context: &mut StatementContext<'_, '_>) {
    let location = crate::spans::resolve_span(span, context.expression_context.source);
    context
        .builder
        .emit_void(Operation::StmtEnter, Vec::new(), location);
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: context.environment,
        builder: context.builder,
    };
    let channels = selection
        .channels
        .iter()
        .filter_map(|channel| {
            crate::variant_values::values(*channel, &mut state)
                .first()
                .copied()
        })
        .collect::<Vec<_>>();
    crate::suspension_points::prepare(&mut state, location);
    let selected =
        crate::channel_operations::emit(("select", IrType::I64), &channels, location, &mut state);
    state.environment.bind_value(selection.storage, selected);
    state.environment.mark_assigned(selection.storage);
    let descriptor = crate::statements_switch::SwitchStatementDescriptor {
        selector: selection.selector,
        cases: &selection.cases,
        default_body: &[],
        statement_span: span,
    };
    crate::statements_switch::lower_after_entry(&descriptor, context);
}

pub(crate) fn bind(
    statement: &pseudolearn_semantic::statement_model::HirStatement,
    span: Span,
    context: &mut StatementContext<'_, '_>,
) -> bool {
    let pseudolearn_semantic::statement_model::HirStatement::Assign { destination, value } =
        statement
    else {
        return false;
    };
    let expression = usize::try_from(value.0).ok().and_then(|index| {
        context
            .expression_context
            .module
            .expressions
            .kinds
            .get(index)
    });
    if !matches!(expression, Some(pseudolearn_semantic::HirExpression::Channel(call)) if call.action == pseudolearn_semantic::channel_model::ChannelAction::Selected)
    {
        return false;
    }
    let span = crate::spans::resolve_span(span, context.expression_context.source);
    crate::records::lower_record_assignment(destination, *value, span, context);
    true
}
