use crate::expression_checker::{invalid, widen};
use crate::expression_model::{HirExpression, HirPlace};
use crate::identities::{ExpressionId, RecordId};
use crate::record_registry::slot;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn construct(
    session: &mut AnalysisSession<'_>,
    node: usize,
    record: RecordId,
) -> ExpressionId {
    let Some(model) = session.module.records.get(slot(record)).cloned() else {
        return invalid(session, node);
    };
    let arguments = constructor_arguments(session, node, &model.fields);
    if arguments.len() != model.fields.len() {
        crate::argument_checker::arity(session, (model.fields.len(), arguments.len()), node);
        return invalid(session, node);
    }
    let mut fields = Vec::new();
    for (field, argument) in model.fields.iter().zip(arguments) {
        let expected = session.module.types.get(field.type_id);
        let actual = session.expression_type(argument);
        if crate::type_resolution::assignable(session, &expected, &actual) {
            crate::result_obligations::consume(session, argument);
            fields.push(widen(session, argument, &expected));
        } else {
            session.named_report(DiagnosticCode::IncompatibleArgumentType, node, &field.name);
            fields.push(argument);
        }
    }
    let kind = session.module.types.intern(Type::Record(record));
    session.emit(
        HirExpression::RecordNew { record, fields },
        kind,
        session.span(node),
    )
}

pub(crate) fn field(
    session: &mut AnalysisSession<'_>,
    node: usize,
    access: (ExpressionId, RecordId, usize),
) -> ExpressionId {
    let (receiver, record, name_node) = access;
    if session.module.variants.contains_key(&record) {
        session.report(DiagnosticCode::VariantRequiresPattern, node);
        return invalid(session, node);
    }
    let name = session.name(name_node);
    let found = session
        .module
        .records
        .get(slot(record))
        .and_then(|model| model.fields.iter().find(|field| field.name == name))
        .cloned();
    let Some(found) = found else {
        let spelling = session.lexeme(name_node).to_owned();
        session.named_report(DiagnosticCode::UndefinedMember, name_node, &spelling);
        return invalid(session, node);
    };
    session.emit(
        HirExpression::RecordField {
            record: receiver,
            offset: found.offset,
        },
        found.type_id,
        session.span(node),
    )
}

pub(crate) fn place(session: &AnalysisSession<'_>, expression: ExpressionId) -> Option<HirPlace> {
    let type_id = usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.types.get(index))
        .copied()?;
    let mut total = 0_u32;
    let mut current = expression;
    loop {
        let kind = usize::try_from(current.0)
            .ok()
            .and_then(|index| session.module.expressions.kinds.get(index))?;
        match kind {
            HirExpression::RecordField { record, offset } => {
                total = total.checked_add(*offset)?;
                current = *record;
            }
            HirExpression::Local(local) => {
                return Some(HirPlace::RecordField {
                    local: *local,
                    offset: total,
                    type_id,
                });
            }
            _ => return None,
        }
    }
}

pub(crate) fn is_field(session: &AnalysisSession<'_>, expression: ExpressionId) -> bool {
    usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.kinds.get(index))
        .is_some_and(|kind| matches!(kind, HirExpression::RecordField { .. }))
}

fn constructor_arguments(
    session: &mut AnalysisSession<'_>,
    node: usize,
    fields: &[crate::hir::HirRecordField],
) -> Vec<ExpressionId> {
    let Some(arguments) = session.child(node, pseudolearn_syntax::NodeKind::Arguments) else {
        return Vec::new();
    };
    session
        .children(arguments)
        .into_iter()
        .enumerate()
        .map(|(index, argument)| match fields.get(index) {
            Some(field) => {
                crate::expression_checker::check_expected(session, argument, field.type_id)
            }
            None => crate::expression_checker::check(session, argument),
        })
        .collect()
}
