use crate::expression_model::BinaryOperator;
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn diagnose(
    session: &mut AnalysisSession<'_>,
    operands: (BinaryOperator, ExpressionId, ExpressionId),
    node: usize,
    result: &Type,
) {
    let (operator, left, right) = operands;
    let left = session.expression_type(left);
    let right = session.expression_type(right);
    if left == Type::Error || right == Type::Error {
        return;
    }
    let code = special_code(operator, &left, &right)
        .or_else(|| (*result == Type::Error).then_some(DiagnosticCode::IncompatibleOperandTypes));
    if let Some(code) = code {
        session.report(code, node);
    }
}

fn special_code(operator: BinaryOperator, left: &Type, right: &Type) -> Option<DiagnosticCode> {
    use BinaryOperator::*;
    if matches!(operator, Less | LessEqual | Greater | GreaterEqual)
        && *left == Type::Boolean
        && *right == Type::Boolean
    {
        return Some(DiagnosticCode::NoOrderBetweenBooleans);
    }
    if matches!(operator, Equal | NotEqual) && (*left == Type::Real || *right == Type::Real) {
        return Some(DiagnosticCode::RealEqualityComparison);
    }
    if matches!(operator, IntegerDivide | Modulo) && (*left == Type::Real || *right == Type::Real) {
        return Some(DiagnosticCode::DivOrModWithRealOperand);
    }
    if operator == Add
        && matches!(left, Type::String | Type::Character)
            != matches!(right, Type::String | Type::Character)
    {
        return Some(DiagnosticCode::CannotConcatenateNumberWithText);
    }
    None
}
