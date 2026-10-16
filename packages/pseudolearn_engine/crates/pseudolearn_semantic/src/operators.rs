use crate::expression_model::{HirExpression, UnaryOperator};
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::TokenKind;

pub(crate) fn unary(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let child = session
        .tree
        .child_indices(node)
        .first()
        .copied()
        .unwrap_or(node);
    let operand = crate::expression_checker::check(session, child);
    let token = session.token_kind(node);
    let operator = match token {
        Some(TokenKind::Minus) => UnaryOperator::Negative,
        Some(TokenKind::LogicalNot | TokenKind::Keyword(pseudolearn_lexicon::KeywordKind::Not)) => {
            UnaryOperator::Not
        }
        _ => UnaryOperator::Positive,
    };
    let kind = session.expression_type(operand);
    let valid = match operator {
        UnaryOperator::Not => matches!(kind, Type::Boolean | Type::Unknown | Type::Error),
        _ => crate::operator_types::numeric(&kind),
    };
    if !valid {
        session.report(DiagnosticCode::IncompatibleOperandTypes, node);
    }
    let type_id = session
        .module
        .types
        .intern(if valid { kind } else { Type::Error });
    let operator_span = session.operator_span(node);
    session.emit(
        HirExpression::Unary {
            operator,
            operand,
            operator_span,
        },
        type_id,
        session.span(node),
    )
}

pub(crate) fn binary(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let children = session.children(node);
    let left = children
        .first()
        .copied()
        .map(|child| crate::expression_checker::check(session, child))
        .unwrap_or_else(|| crate::expression_checker::invalid(session, node));
    let right = children
        .get(1)
        .copied()
        .map(|child| crate::expression_checker::check(session, child))
        .unwrap_or_else(|| crate::expression_checker::invalid(session, node));
    let operator = crate::operator_tokens::operator(session.operator_kind(node));
    let result = crate::operator_types::result_type(
        operator,
        &session.expression_type(left),
        &session.expression_type(right),
    );
    crate::operator_diagnostics::diagnose(session, (operator, left, right), node, &result);
    let (left, right) = if operator == crate::expression_model::BinaryOperator::Divide {
        (
            crate::expression_checker::widen(session, left, &Type::Real),
            crate::expression_checker::widen(session, right, &Type::Real),
        )
    } else {
        widen_operands(session, (left, right))
    };
    let type_id = session.module.types.intern(result);
    let operator_span = session.operator_span(node);
    session.emit(
        HirExpression::Binary {
            operator,
            left,
            right,
            operator_span,
        },
        type_id,
        session.span(node),
    )
}

fn widen_operands(
    session: &mut AnalysisSession<'_>,
    operands: (ExpressionId, ExpressionId),
) -> (ExpressionId, ExpressionId) {
    let (left, right) = operands;
    if !matches!(
        (
            session.expression_type(left),
            session.expression_type(right)
        ),
        (Type::Integer, Type::Real) | (Type::Real, Type::Integer)
    ) {
        return operands;
    }
    (
        crate::expression_checker::widen(session, left, &Type::Real),
        crate::expression_checker::widen(session, right, &Type::Real),
    )
}
