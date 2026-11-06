use crate::expression_model::HirExpression;
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::{BuiltinKind, signature_for_builtin};

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    function: BuiltinKind,
    mut arguments: Vec<ExpressionId>,
    node: usize,
) -> ExpressionId {
    if function == BuiltinKind::Snapshot {
        return crate::snapshot_types::check(session, arguments, node);
    }
    let signature = signature_for_builtin(function);
    if signature.arity() != arguments.len() {
        crate::argument_checker::arity(session, (signature.arity(), arguments.len()), node);
    }
    let widest = signature.return_type == "widestNumeric";
    let real = !widest
        || arguments
            .iter()
            .any(|argument| session.expression_type(*argument) == Type::Real);
    for (expected, argument) in signature.parameter_types.iter().zip(&mut arguments) {
        *argument = check_argument(session, (function, expected), *argument, (node, real));
    }
    let result = result_type(session, signature.return_type, &arguments, (widest, real));
    let result = session.module.types.intern(result);
    session.emit(
        HirExpression::Builtin {
            function,
            arguments,
        },
        result,
        session.span(node),
    )
}

fn check_argument(
    session: &mut AnalysisSession<'_>,
    (function, expected): (BuiltinKind, &str),
    argument: ExpressionId,
    (node, real): (usize, bool),
) -> ExpressionId {
    let actual = crate::snapshot_types::builtin_argument(session, function, argument);
    if !compatible(expected, &actual) {
        session.report(DiagnosticCode::IncompatibleArgumentType, node);
    }
    if real && matches!(expected, "numeric" | "real") {
        return crate::expression_checker::widen(session, argument, &Type::Real);
    }
    if expected == "string" {
        return crate::expression_checker::widen(session, argument, &Type::String);
    }
    argument
}

fn compatible(expected: &str, actual: &Type) -> bool {
    if matches!(actual, Type::Unknown | Type::Error) {
        return true;
    }
    match expected {
        "numeric" | "real" => matches!(actual, Type::Integer | Type::Real),
        "string" => matches!(actual, Type::String | Type::Character),
        "anyClass" => matches!(actual, Type::Object(_)),
        "anyPrimitive" => matches!(
            actual,
            Type::Integer | Type::Real | Type::Boolean | Type::Character | Type::String
        ),
        _ => *actual == primitive(expected),
    }
}

fn primitive(name: &str) -> Type {
    match name {
        "integer" => Type::Integer,
        "real" => Type::Real,
        "boolean" => Type::Boolean,
        "character" => Type::Character,
        "string" => Type::String,
        _ => Type::Error,
    }
}

fn result_type(
    session: &AnalysisSession<'_>,
    return_type: &str,
    arguments: &[ExpressionId],
    (widest, real): (bool, bool),
) -> Type {
    if widest {
        if real { Type::Real } else { Type::Integer }
    } else if return_type == "sameAsFirstArgument" {
        arguments
            .first()
            .map(|argument| session.expression_type(*argument))
            .unwrap_or(Type::Error)
    } else {
        primitive(return_type)
    }
}
