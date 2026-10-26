use crate::expression_checker::{ExpressionPurpose, check_expected_for};
use crate::expression_model::HirExpression;
use crate::hir::Passing;
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn call(
    session: &mut AnalysisSession<'_>,
    node: usize,
    (callee, purpose): (ExpressionId, ExpressionPurpose),
) -> ExpressionId {
    let Some(signature) = crate::function_types::get(session, &session.expression_type(callee))
    else {
        session.report(DiagnosticCode::IncompatibleOperandTypes, node);
        return crate::expression_checker::invalid(session, node);
    };
    let arguments = session
        .child(node, NodeKind::Arguments)
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    if arguments.len() != signature.parameters.len() {
        crate::argument_checker::arity(
            session,
            (signature.parameters.len(), arguments.len()),
            node,
        );
    }
    let mut values = Vec::new();
    for (syntax, (kind, passing)) in arguments.into_iter().zip(signature.parameters) {
        values.push(argument(session, syntax, (kind, passing)));
    }
    crate::call_checker::check_result(session, signature.result, (node, purpose));
    session.emit(
        HirExpression::IndirectCall {
            callee,
            arguments: values,
        },
        signature.result,
        session.span(node),
    )
}

pub(crate) fn argument(
    session: &mut AnalysisSession<'_>,
    node: usize,
    (kind, passing): (crate::identities::TypeId, Passing),
) -> ExpressionId {
    let value = check_expected_for(session, node, kind, ExpressionPurpose::Argument);
    let expected = session.module.types.get(kind);
    let actual = session.expression_type(value);
    if passing == Passing::Reference {
        if expected != actual && actual != crate::types::Type::Error {
            session.report(DiagnosticCode::ByReferenceArgumentTypeMismatch, node);
        }
        if let Some(place) = crate::expression_checker::place(session, value) {
            crate::binding_checker::check_destination(session, &place, node);
        } else {
            session.report(DiagnosticCode::ByReferenceArgumentRequiresDesignator, node);
        }
        return value;
    }
    if !crate::type_resolution::assignable(session, &expected, &actual) {
        session.named_report(DiagnosticCode::IncompatibleArgumentType, node, "callback");
    }
    crate::expression_checker::widen(session, value, &expected)
}
