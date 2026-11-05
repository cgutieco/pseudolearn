use crate::expression_model::{HirExpression, HirPlace};
use crate::identities::{ExpressionId, RecordId, StatementId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) struct UserPattern {
    pub alternative: usize,
    pub payload: Option<RecordId>,
    pub bindings: Vec<usize>,
}

pub(crate) fn record_of(session: &AnalysisSession<'_>, value: ExpressionId) -> Option<RecordId> {
    match crate::snapshot_types::underlying(session, &session.expression_type(value)) {
        Type::Record(record) => Some(record),
        _ => None,
    }
}

pub(crate) fn alternative(
    session: &mut AnalysisSession<'_>,
    pattern: usize,
    value: ExpressionId,
) -> Option<UserPattern> {
    let record = record_of(session, value)?;
    let Some(shape) = crate::user_variant_values::shape(session, pattern) else {
        session.report(DiagnosticCode::IncompatibleSwitchCaseType, pattern);
        return None;
    };
    let qualifier = session.name(shape.qualifier);
    if !crate::generic_variants::belongs(session, &qualifier, record) {
        session.report(DiagnosticCode::IncompatibleSwitchCaseType, pattern);
        return None;
    }
    let (alternative, payload) =
        crate::user_variant_values::alternative_index(session, record, shape.member)?;
    let arguments = shape
        .arguments
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    let mut bindings = Vec::new();
    for argument in arguments {
        let Some(name) = crate::user_variant_values::plain_identifier(session, argument) else {
            session.report(DiagnosticCode::IncompatibleSwitchCaseType, argument);
            return None;
        };
        bindings.push(name);
    }
    let fields = crate::user_variant_values::field_types(session, payload).len();
    if fields != bindings.len() {
        crate::argument_checker::arity(session, (fields, bindings.len()), pattern);
        return None;
    }
    Some(UserPattern {
        alternative,
        payload,
        bindings,
    })
}

pub(crate) fn bind(
    session: &mut AnalysisSession<'_>,
    (pattern, value): (usize, ExpressionId),
    matched: &UserPattern,
) -> Vec<StatementId> {
    let Some(payload) = matched.payload else {
        return Vec::new();
    };
    let fields = usize::try_from(payload.0)
        .ok()
        .and_then(|slot| session.module.records.get(slot))
        .map(|model| model.fields.clone())
        .unwrap_or_default();
    let source = PayloadSource {
        pattern,
        value,
        payload,
        alternative: u32::try_from(matched.alternative).unwrap_or(0),
    };
    fields
        .iter()
        .zip(matched.bindings.iter().copied())
        .map(|(field, name)| bind_field(session, &source, (field, name)))
        .collect()
}

struct PayloadSource {
    pattern: usize,
    value: ExpressionId,
    payload: RecordId,
    alternative: u32,
}

fn bind_field(
    session: &mut AnalysisSession<'_>,
    source: &PayloadSource,
    (field, name): (&crate::hir::HirRecordField, usize),
) -> StatementId {
    let span = session.span(name);
    let record_kind = session.module.types.intern(Type::Record(source.payload));
    let payload = session.emit(
        HirExpression::VariantPayload {
            value: source.value,
            alternative: source.alternative,
        },
        record_kind,
        session.span(source.pattern),
    );
    let kind = crate::snapshot_types::read_type(session, source.value, field.type_id);
    let read = session.emit(
        HirExpression::RecordField {
            record: payload,
            offset: field.offset,
        },
        kind,
        span,
    );
    let local = crate::variant_bindings::pattern(session, kind, name);
    crate::result_obligations::assign(session, local, read, name);
    session.statement(
        HirStatement::Assign {
            destination: HirPlace::Local(local),
            value: read,
        },
        span,
    )
}

pub(crate) fn missing(
    session: &AnalysisSession<'_>,
    value: ExpressionId,
    seen: &std::collections::BTreeSet<usize>,
) -> Vec<String> {
    record_of(session, value)
        .and_then(|record| session.module.user_variants.get(&record))
        .map(|model| {
            model
                .alternatives
                .iter()
                .enumerate()
                .filter(|(index, _)| !seen.contains(index))
                .map(|(_, alternative)| alternative.spelling.clone())
                .collect()
        })
        .unwrap_or_default()
}
