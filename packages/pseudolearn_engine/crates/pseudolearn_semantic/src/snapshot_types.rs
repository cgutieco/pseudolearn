use crate::identities::{ExpressionId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_syntax::NodeKind;

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    if crate::collection_types::identity(session, name) != Some("immutableType") {
        return None;
    }
    let arguments = session
        .child(node, NodeKind::TypeArguments)
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    if arguments.len() != 1 {
        crate::generic_names::count_mismatch(session, node, (name, 1, arguments.len()));
        return Some(Type::Error);
    }
    let inner = crate::type_resolution::resolve(session, *arguments.first()?);
    Some(Type::Immutable(inner))
}

pub(crate) fn read_type(
    session: &mut AnalysisSession<'_>,
    receiver: ExpressionId,
    kind: TypeId,
) -> TypeId {
    if matches!(session.expression_type(receiver), Type::Immutable(_))
        && crate::transferability::violation(&session.module, kind).is_some()
    {
        session.module.types.intern(Type::Immutable(kind))
    } else {
        kind
    }
}

pub(crate) fn underlying(session: &AnalysisSession<'_>, kind: &Type) -> Type {
    match kind {
        Type::Immutable(inner) => session.module.types.representation(*inner),
        other => other.clone(),
    }
}

pub(crate) fn readonly(session: &AnalysisSession<'_>, expression: ExpressionId) -> bool {
    if matches!(session.expression_type(expression), Type::Immutable(_)) {
        return true;
    }
    let Some(index) = usize::try_from(expression.0).ok() else {
        return false;
    };
    match session.module.expressions.kinds.get(index) {
        Some(crate::HirExpression::Element { array, .. }) => readonly(session, *array),
        Some(crate::HirExpression::RecordField { record, .. }) => readonly(session, *record),
        Some(crate::HirExpression::Field { receiver, .. }) => readonly(session, *receiver),
        _ => false,
    }
}

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    arguments: Vec<ExpressionId>,
    node: usize,
) -> ExpressionId {
    if arguments.len() != 1 {
        crate::argument_checker::arity(session, (1, arguments.len()), node);
    }
    let Some(value) = arguments.first().copied() else {
        return crate::expression_checker::invalid(session, node);
    };
    let inner = session.module.types.intern(session.expression_type(value));
    if let Some(failure) = crate::snapshot_support::violation(&session.module, inner) {
        session.report(
            pseudolearn_diagnostics::DiagnosticCode::SnapshotNotSupported,
            node,
        );
        crate::diagnostic_arguments::last_type(session, failure.kind);
        if let Some(diagnostic) = session.diagnostics.last_mut() {
            diagnostic.arguments.insert(
                "path".to_owned(),
                pseudolearn_diagnostics::DiagnosticArgument::Lexeme(failure.path),
            );
        }
    }
    crate::result_obligations::consume(session, value);
    let result = if matches!(session.module.types.get(inner), Type::Immutable(_)) {
        inner
    } else {
        session.module.types.intern(Type::Immutable(inner))
    };
    session.emit(
        crate::HirExpression::Builtin {
            function: pseudolearn_lexicon::BuiltinKind::Snapshot,
            arguments,
        },
        result,
        session.span(node),
    )
}

pub(crate) fn reject_write(
    session: &mut AnalysisSession<'_>,
    destination: ExpressionId,
    node: usize,
) -> bool {
    let index = usize::try_from(destination.0).unwrap_or(usize::MAX);
    let owner = match session.module.expressions.kinds.get(index) {
        Some(crate::HirExpression::Element { array, .. }) => Some(*array),
        Some(crate::HirExpression::RecordField { record, .. }) => Some(*record),
        Some(crate::HirExpression::Field { receiver, .. }) => Some(*receiver),
        _ => None,
    };
    if owner.is_some_and(|owner| readonly(session, owner)) {
        session.report(
            pseudolearn_diagnostics::DiagnosticCode::ImmutableValueWrite,
            node,
        );
        true
    } else {
        false
    }
}

pub(crate) fn comparison_type(
    session: &AnalysisSession<'_>,
    operator: crate::expression_model::BinaryOperator,
    operands: (ExpressionId, ExpressionId),
) -> Type {
    use crate::expression_model::BinaryOperator;
    let left = session.expression_type(operands.0);
    let right = session.expression_type(operands.1);
    let comparison = matches!(
        operator,
        BinaryOperator::Equal
            | BinaryOperator::NotEqual
            | BinaryOperator::Less
            | BinaryOperator::LessEqual
            | BinaryOperator::Greater
            | BinaryOperator::GreaterEqual
    );
    if comparison && (matches!(left, Type::Immutable(_)) || matches!(right, Type::Immutable(_))) {
        let left = underlying(session, &left);
        let right = underlying(session, &right);
        if left != right {
            return Type::Error;
        }
        return crate::operator_types::result_type(operator, &left, &right);
    }
    crate::operator_types::result_type(operator, &left, &right)
}

pub(crate) fn builtin_argument(
    session: &AnalysisSession<'_>,
    function: pseudolearn_lexicon::BuiltinKind,
    expression: ExpressionId,
) -> Type {
    use pseudolearn_lexicon::BuiltinKind;
    let kind = session.expression_type(expression);
    if matches!(
        function,
        BuiltinKind::Length
            | BuiltinKind::CharacterAt
            | BuiltinKind::CharacterCode
            | BuiltinKind::ToText
    ) {
        underlying(session, &kind)
    } else {
        kind
    }
}
