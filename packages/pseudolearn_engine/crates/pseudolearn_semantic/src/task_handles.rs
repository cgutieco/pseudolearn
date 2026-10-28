use crate::expression_checker::ExpressionPurpose;
use crate::expression_model::HirExpression;
use crate::identities::{ExpressionId, FunctionId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn spawn_statement(
    session: &mut AnalysisSession<'_>,
    node: usize,
) -> Option<HirStatement> {
    let expression_node = session.children(node).first().copied()?;
    let expression = spawn(session, expression_node, ExpressionPurpose::Statement);
    Some(HirStatement::Spawn(expression))
}

pub(crate) fn spawn(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    if !valid_spawn_context(session, node) {
        return crate::expression_checker::invalid(session, node);
    }
    if !suspendible_target(session, node) {
        return crate::expression_checker::invalid(session, node);
    }
    let call_purpose = spawn_call_purpose(session, node, purpose);
    let call = checked_call(session, node, call_purpose);
    let Some(HirExpression::Call {
        function,
        arguments,
    }) = expression(session, call).cloned()
    else {
        return crate::expression_checker::invalid(session, node);
    };
    check_arguments(session, function, &arguments, node);
    let result = session.expression_type(call);
    crate::task_failure_types::spawned(session, &result, node);
    let payload = task_payload(session, result);
    let kind = session.module.types.intern(Type::Task(payload));
    session.emit(
        HirExpression::TaskSpawn {
            function,
            arguments,
        },
        kind,
        session.span(node),
    )
}

fn valid_spawn_context(session: &mut AnalysisSession<'_>, node: usize) -> bool {
    if session.control.cleaning {
        session.report(DiagnosticCode::TaskScopeInsideDefer, node);
        return false;
    }
    if session.control.task_scopes == 0 {
        session.report(DiagnosticCode::SpawnOutsideTaskScope, node);
        return false;
    }
    true
}

fn suspendible_target(session: &mut AnalysisSession<'_>, node: usize) -> bool {
    let is_suspendible = if let Some(function) = target(session, node) {
        session
            .module
            .functions
            .get(usize::try_from(function.0).unwrap_or(usize::MAX))
            .is_some_and(|model| model.suspendible)
    } else {
        generic_target(session, node)
            .is_some_and(|template| crate::suspension_checker::declared(session, template.node))
    };
    if !is_suspendible {
        session.report(DiagnosticCode::SpawnTargetNotSuspendible, node);
    }
    is_suspendible
}

fn generic_target<'session>(
    session: &'session AnalysisSession<'_>,
    node: usize,
) -> Option<&'session crate::generic_state::GenericTemplate> {
    let identifier = session
        .children(node)
        .into_iter()
        .find(|child| session.kind(*child) == NodeKind::Identifier)?;
    let name = session.name(identifier);
    if session.local(&name).is_some() {
        return None;
    }
    session.generics.functions.get(&name)
}

fn target(session: &AnalysisSession<'_>, node: usize) -> Option<FunctionId> {
    let name_node = session
        .children(node)
        .into_iter()
        .find(|child| session.kind(*child) == NodeKind::Identifier)?;
    let name = session.name(name_node);
    if session.local(&name).is_some() {
        return None;
    }
    session.functions.get(&name).copied()
}

fn checked_call(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    session.awaited_calls.push(node);
    let result = crate::call_checker::call(session, node, purpose);
    session.awaited_calls.pop();
    result
}

fn expression<'session>(
    session: &'session AnalysisSession<'_>,
    expression: ExpressionId,
) -> Option<&'session HirExpression> {
    usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.kinds.get(index))
}

fn check_arguments(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
    arguments: &[ExpressionId],
    node: usize,
) {
    let parameters = session
        .module
        .functions
        .get(usize::try_from(function.0).unwrap_or(usize::MAX))
        .map(|model| model.parameters.clone())
        .unwrap_or_default();
    for (index, argument) in arguments.iter().enumerate() {
        if parameters
            .get(index)
            .and_then(|parameter| {
                usize::try_from(parameter.0)
                    .ok()
                    .and_then(|index| session.module.locals.get(index))
            })
            .is_some_and(|parameter| parameter.passing == crate::hir::Passing::Reference)
        {
            session.report(DiagnosticCode::TaskByReferenceArgument, node);
        }
        let kind = session
            .module
            .types
            .intern(session.expression_type(*argument));
        crate::transferability::report(
            session,
            kind,
            node,
            DiagnosticCode::TaskArgumentNotTransferable,
        );
    }
}

fn task_payload(session: &mut AnalysisSession<'_>, result: Type) -> crate::identities::TypeId {
    if let Type::Record(record) = result
        && let Some(variant) = session.module.variants.get(&record)
        && variant.family == crate::variant_model::VariantFamily::Result
        && let Some(Some(payload)) = variant.payloads.first()
    {
        return *payload;
    }
    session.module.types.intern(result)
}

fn spawn_call_purpose(
    session: &AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionPurpose {
    target(session, node)
        .and_then(|function| {
            session
                .module
                .functions
                .get(usize::try_from(function.0).ok()?)
        })
        .map(|function| {
            if session.module.types.get(function.result) == Type::Unit {
                purpose
            } else {
                ExpressionPurpose::Value
            }
        })
        .unwrap_or_else(|| {
            if generic_target(session, node)
                .is_some_and(|template| session.child(template.node, NodeKind::Type).is_some())
            {
                ExpressionPurpose::Value
            } else {
                purpose
            }
        })
}
