use crate::expression_checker::{ExpressionPurpose, check_for};
use crate::expression_model::HirExpression;
use crate::identities::{ClassId, ExpressionId, FunctionId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::{KeywordKind, find_builtin};
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) struct MethodCall {
    pub node: usize,
    pub target: usize,
    pub receiver: ExpressionId,
    pub class: ClassId,
    pub name: String,
    pub arguments: usize,
    pub purpose: ExpressionPurpose,
}

pub(crate) fn call(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    let children = session.children(node);
    let target = children.first().copied().unwrap_or(node);
    let name = session.name(target);
    if let Some(record) = session.declared.records.get(&name).copied() {
        return crate::record_access::construct(session, node, record);
    }
    let arguments = session.child(node, NodeKind::Arguments).unwrap_or(node);
    let mut arguments = arguments_for(session, arguments);
    if let Some(function) = session.functions.get(&name).copied() {
        crate::argument_checker::check(session, function, &mut arguments, node);
        return emit_call(session, function, arguments, (node, purpose));
    }
    if let Some(function) = find_builtin(&name, session.options.profile) {
        return crate::builtin_checker::check(session, function, arguments, node);
    }
    session.named_report(DiagnosticCode::UndeclaredSubroutine, target, &name);
    crate::expression_checker::invalid(session, node)
}

pub(crate) fn arguments_for(
    session: &mut AnalysisSession<'_>,
    arguments: usize,
) -> Vec<ExpressionId> {
    session
        .children(arguments)
        .into_iter()
        .map(|argument| check_for(session, argument, ExpressionPurpose::Argument))
        .collect()
}

pub(crate) fn emit_call(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
    arguments: Vec<ExpressionId>,
    context: (usize, ExpressionPurpose),
) -> ExpressionId {
    let (node, purpose) = context;
    let result = crate::hierarchy::function(session, function)
        .map(|function| function.result)
        .unwrap_or_else(|| session.module.types.intern(Type::Error));
    check_result(session, result, (node, purpose));
    session.called.insert(function);
    session.emit(
        HirExpression::Call {
            function,
            arguments,
        },
        result,
        session.span(node),
    )
}

pub(crate) fn instantiate(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let name_node = session.child(node, NodeKind::Identifier).unwrap_or(node);
    let name = session.name(name_node);
    let arguments = session.child(node, NodeKind::Arguments).unwrap_or(node);
    let mut arguments = arguments_for(session, arguments);
    let Some(class) = session.classes.get(&name).copied() else {
        session.named_report(DiagnosticCode::UndeclaredClass, name_node, &name);
        return crate::expression_checker::invalid(session, node);
    };
    let constructor =
        crate::hierarchy::class_model(session, class).and_then(|class| class.constructor);
    if let Some(constructor) = constructor {
        crate::argument_checker::check(session, constructor, &mut arguments, node);
        session.called.insert(constructor);
    } else if !arguments.is_empty() {
        crate::argument_checker::arity(session, (0, arguments.len()), node);
    }
    let kind = session.module.types.intern(Type::Object(class));
    session.emit(
        HirExpression::New { class, arguments },
        kind,
        session.span(node),
    )
}

pub(crate) fn method(session: &mut AnalysisSession<'_>, invocation: MethodCall) -> ExpressionId {
    let arguments = arguments_for(session, invocation.arguments);
    match method_target(session, &invocation) {
        MethodTarget::Declared(function) => emit_method(session, invocation, function, arguments),
        MethodTarget::Implicit if arguments.is_empty() => {
            let kind = session.module.types.intern(Type::Unit);
            session.emit(
                HirExpression::SuperCall {
                    receiver: invocation.class,
                    function: None,
                    arguments,
                },
                kind,
                session.span(invocation.node),
            )
        }
        MethodTarget::Implicit => {
            crate::argument_checker::arity(session, (0, arguments.len()), invocation.node);
            crate::expression_checker::invalid(session, invocation.node)
        }
        MethodTarget::Missing => crate::expression_checker::invalid(session, invocation.node),
    }
}

enum MethodTarget {
    Declared(FunctionId),
    Implicit,
    Missing,
}

fn method_target(session: &mut AnalysisSession<'_>, invocation: &MethodCall) -> MethodTarget {
    let name_node = session
        .tree
        .child_indices(invocation.node)
        .get(1)
        .copied()
        .unwrap_or(invocation.node);
    if session.token_kind(name_node) == Some(TokenKind::Keyword(KeywordKind::Constructor)) {
        return crate::hierarchy::class_model(session, invocation.class)
            .and_then(|class| class.constructor)
            .map(MethodTarget::Declared)
            .unwrap_or(MethodTarget::Implicit);
    }
    let Some(function) = crate::hierarchy::find_method(session, invocation.class, &invocation.name)
    else {
        session.named_report(DiagnosticCode::UndefinedMember, name_node, &invocation.name);
        return MethodTarget::Missing;
    };
    if crate::hierarchy::function(session, function)
        .is_some_and(|function| function.private && session.owner() != function.owner)
    {
        session.named_report(
            DiagnosticCode::PrivateMemberAccess,
            name_node,
            &invocation.name,
        );
        if let Some(owner) =
            crate::hierarchy::function(session, function).and_then(|function| function.owner)
        {
            crate::diagnostic_arguments::class_name(session, owner);
        }
    }
    MethodTarget::Declared(function)
}

fn emit_method(
    session: &mut AnalysisSession<'_>,
    invocation: MethodCall,
    function: FunctionId,
    mut arguments: Vec<ExpressionId>,
) -> ExpressionId {
    crate::argument_checker::check(session, function, &mut arguments, invocation.node);
    let Some(signature) = crate::hierarchy::function(session, function).cloned() else {
        return crate::expression_checker::invalid(session, invocation.node);
    };
    session.called.insert(function);
    check_result(
        session,
        signature.result,
        (invocation.node, invocation.purpose),
    );
    let kind = if session.kind(invocation.target) == NodeKind::SuperClass {
        HirExpression::SuperCall {
            receiver: invocation.class,
            function: Some(function),
            arguments,
        }
    } else {
        HirExpression::VirtualCall {
            receiver: invocation.receiver,
            function,
            arguments,
        }
    };
    session.emit(kind, signature.result, session.span(invocation.node))
}

fn check_result(
    session: &mut AnalysisSession<'_>,
    result: crate::identities::TypeId,
    context: (usize, ExpressionPurpose),
) {
    let (node, purpose) = context;
    if purpose != ExpressionPurpose::Statement && session.module.types.get(result) == Type::Unit {
        session.report(DiagnosticCode::CallAsExpressionWithoutReturnType, node);
    }
    if purpose == ExpressionPurpose::Statement && session.module.types.get(result) != Type::Unit {
        session.report(DiagnosticCode::DiscardedReturnValue, node);
    }
}
