use crate::expression_model::HirExpression;
use crate::identities::{ExpressionId, RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use crate::variant_model::VariantFamily;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: Option<TypeId>,
) -> ExpressionId {
    let token = session.token_kind(node);
    let Some(kind) = expected else {
        if token == Some(TokenKind::Keyword(KeywordKind::SomeVariant)) {
            return infer_some(session, node);
        }
        session.report(DiagnosticCode::AmbiguousVariantType, node);
        return crate::expression_checker::invalid(session, node);
    };
    if session.module.types.get(kind) == Type::Error {
        return crate::expression_checker::invalid(session, node);
    }
    let Type::Record(record) = session.module.types.get(kind) else {
        session.report(DiagnosticCode::IncompatibleVariantConstructor, node);
        return crate::expression_checker::invalid(session, node);
    };
    construct(session, (record, kind), (node, token))
}

fn infer_some(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let Some(child) = session.children(node).first().copied() else {
        return crate::expression_checker::invalid(session, node);
    };
    let payload = crate::expression_checker::check(session, child);
    let Some(kind) = usize::try_from(payload.0)
        .ok()
        .and_then(|index| session.module.expressions.types.get(index))
        .copied()
    else {
        return crate::expression_checker::invalid(session, node);
    };
    if session.module.types.get(kind) == Type::Error {
        return crate::expression_checker::invalid(session, node);
    }
    let kind = crate::variant_types::register(
        session,
        VariantFamily::Optional,
        vec![None, Some(kind)],
        node,
    );
    let Type::Record(record) = session.module.types.get(kind) else {
        return crate::expression_checker::invalid(session, node);
    };
    crate::result_obligations::consume(session, payload);
    session.emit(
        HirExpression::VariantNew {
            record,
            alternative: 1,
            payload: Some(payload),
        },
        kind,
        session.span(node),
    )
}

fn construct(
    session: &mut AnalysisSession<'_>,
    expected: (RecordId, TypeId),
    syntax: (usize, Option<TokenKind>),
) -> ExpressionId {
    let (node, token) = syntax;
    let Some(variant) = session.module.variants.get(&expected.0).cloned() else {
        session.report(DiagnosticCode::IncompatibleVariantConstructor, node);
        return crate::expression_checker::invalid(session, node);
    };
    let Some(alternative) = alternative(variant.family, token) else {
        session.report(DiagnosticCode::IncompatibleVariantConstructor, node);
        return crate::expression_checker::invalid(session, node);
    };
    let payload = checked_payload(session, (&variant, alternative), node);
    session.emit(
        HirExpression::VariantNew {
            record: expected.0,
            alternative: u32::try_from(alternative).unwrap_or(0),
            payload,
        },
        expected.1,
        session.span(node),
    )
}

pub(crate) fn alternative(family: VariantFamily, token: Option<TokenKind>) -> Option<usize> {
    match (family, token?) {
        (VariantFamily::Optional, TokenKind::Keyword(KeywordKind::NoneVariant)) => Some(0),
        (VariantFamily::Optional, TokenKind::Keyword(KeywordKind::SomeVariant)) => Some(1),
        (VariantFamily::Result, TokenKind::Keyword(KeywordKind::SuccessVariant)) => Some(0),
        (VariantFamily::Result, TokenKind::Keyword(KeywordKind::ErrorVariant)) => Some(1),
        _ => None,
    }
}

pub(crate) fn propagation(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let Some(child) = session.children(node).first().copied() else {
        return crate::expression_checker::invalid(session, node);
    };
    let value = crate::expression_checker::check(session, child);
    let source = session.expression_type(value);
    let target =
        crate::hierarchy::function(session, session.current).map(|function| function.result);
    let pair = crate::variant_types::get(session, &source).zip(
        target.and_then(|kind| crate::variant_types::get(session, &session.module.types.get(kind))),
    );
    let Some((source_variant, target_variant)) = pair else {
        return incompatible_propagation(session, node);
    };
    let compatible = source_variant.family == target_variant.family
        && (source_variant.family == VariantFamily::Optional
            || source_variant.payloads.get(1) == target_variant.payloads.get(1));
    if !compatible {
        return incompatible_propagation(session, node);
    }
    crate::result_obligations::consume(session, value);
    let success = source_variant.success_alternative();
    let kind = source_variant
        .payloads
        .get(success)
        .copied()
        .flatten()
        .unwrap_or_else(|| session.module.types.intern(Type::Error));
    let Some(Type::Record(target)) = target.map(|kind| session.module.types.get(kind)) else {
        return incompatible_propagation(session, node);
    };
    session.emit(
        HirExpression::Propagate { value, target },
        kind,
        session.span(node),
    )
}

fn incompatible_propagation(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    session.report(DiagnosticCode::IncompatiblePropagationType, node);
    crate::expression_checker::invalid(session, node)
}

pub(crate) fn is_construction(session: &AnalysisSession<'_>, node: usize) -> bool {
    session.kind(node) == NodeKind::VariantConstruction
}

pub(crate) fn reject_operands(
    session: &mut AnalysisSession<'_>,
    operands: (ExpressionId, ExpressionId),
    node: usize,
) -> bool {
    let variant = crate::variant_types::get(session, &session.expression_type(operands.0))
        .is_some()
        || crate::variant_types::get(session, &session.expression_type(operands.1)).is_some();
    if variant {
        session.report(DiagnosticCode::VariantRequiresPattern, node);
    }
    variant
}

fn checked_payload(
    session: &mut AnalysisSession<'_>,
    variant: (&crate::variant_model::HirVariant, usize),
    node: usize,
) -> Option<ExpressionId> {
    let kind = variant.0.payloads.get(variant.1).copied().flatten()?;
    let child = session.children(node).first().copied()?;
    let expression = crate::expression_checker::check_expected(session, child, kind);
    let target = session.module.types.get(kind);
    if !crate::type_resolution::assignable(session, &target, &session.expression_type(expression)) {
        session.named_report(DiagnosticCode::IncompatibleArgumentType, node, "payload");
    }
    crate::result_obligations::consume(session, expression);
    Some(crate::expression_checker::widen(
        session, expression, &target,
    ))
}
