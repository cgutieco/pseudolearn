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
    for (expected, argument) in signature.parameter_types.iter().zip(&mut arguments) {
        let actual = crate::snapshot_types::builtin_argument(session, function, *argument);
        if !compatible(expected, &actual) {
            session.report(DiagnosticCode::IncompatibleArgumentType, node);
        }
        if matches!(*expected, "numeric" | "real") {
            *argument = crate::expression_checker::widen(session, *argument, &Type::Real);
        }
    }
    let result = if signature.return_type == "sameAsFirstArgument" {
        arguments
            .first()
            .map(|argument| session.expression_type(*argument))
            .unwrap_or(Type::Error)
    } else {
        primitive(signature.return_type)
    };
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

fn compatible(expected: &str, actual: &Type) -> bool {
    if matches!(actual, Type::Unknown | Type::Error) {
        return true;
    }
    match expected {
        "numeric" | "real" => matches!(actual, Type::Integer | Type::Real),
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
