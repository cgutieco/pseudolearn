use crate::generic_state::GenericTemplate;
use crate::identities::TypeId;
use crate::interface_model::{HirConstraint, InterfaceId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    arguments: &[TypeId],
    origin: usize,
) -> bool {
    let mut valid = true;
    for index in 0..template.constraints.len() {
        valid &= check_one(session, template, (index, arguments), origin);
    }
    valid
}

fn check_one(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (index, arguments): (usize, &[TypeId]),
    origin: usize,
) -> bool {
    let Some(Some(name)) = template.constraints.get(index).cloned() else {
        return true;
    };
    let Some(interface) = crate::generic_home::at_home(session, template, |session| {
        constraint_at_home(session, template, (index, arguments), &name)
    }) else {
        return false;
    };
    let satisfied = arguments
        .get(index)
        .is_some_and(|argument| satisfies(session, *argument, interface));
    if !satisfied {
        let related = crate::generic_home::at_home(session, template, |session| {
            session
                .tree
                .span_for_node(template.node)
                .unwrap_or_default()
        });
        session.named_report(DiagnosticCode::GenericConstraintNotSatisfied, origin, &name);
        if let Some(diagnostic) = session.diagnostics.last_mut() {
            diagnostic.related.push(related);
        }
    }
    satisfied
}

fn constraint_at_home(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (index, arguments): (usize, &[TypeId]),
    name: &str,
) -> Option<InterfaceId> {
    let interface = match crate::generic_interfaces::constraint(session, template, index, arguments)
    {
        crate::generic_interfaces::InterfaceLookup::Found(interface) => interface,
        crate::generic_interfaces::InterfaceLookup::Reported => return None,
        crate::generic_interfaces::InterfaceLookup::Missing => {
            session.named_report(DiagnosticCode::UnknownInterface, template.node, name);
            return None;
        }
    };
    record(session, template, index, interface);
    Some(interface)
}

pub(crate) fn record(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    index: usize,
    interface: InterfaceId,
) {
    let parameter = template.parameters.get(index).cloned().unwrap_or_default();
    let parameter_span = session
        .child(template.node, pseudolearn_syntax::NodeKind::TypeParameters)
        .and_then(|parameters| session.children(parameters).get(index).copied())
        .map(|node| session.span(node))
        .unwrap_or_else(|| session.span(template.node));
    let constraint = HirConstraint {
        unit: session.unit,
        template: template.node,
        parameter,
        interface,
        span: parameter_span,
    };
    if !session.module.constraints.contains(&constraint) {
        session.module.constraints.push(constraint);
    }
}

fn satisfies(session: &AnalysisSession<'_>, kind: TypeId, interface: InterfaceId) -> bool {
    match session.module.types.get(kind) {
        Type::Object(class) => crate::interface_realizations::satisfies(session, class, interface),
        Type::Record(record) => session.generic.constraints.get(&record) == Some(&interface),
        Type::Error => true,
        _ => false,
    }
}

pub(crate) fn call(
    session: &mut AnalysisSession<'_>,
    node: usize,
    receiver: crate::identities::RecordId,
    purpose: crate::expression_checker::ExpressionPurpose,
) -> Option<crate::identities::ExpressionId> {
    let interface = *session.generic.constraints.get(&receiver)?;
    let name_node = session.children(node).get(1).copied().unwrap_or(node);
    let name = session.name(name_node);
    let signature = session
        .module
        .interfaces
        .get(usize::try_from(interface.0).ok()?)?
        .methods
        .iter()
        .find(|method| method.name == name)
        .map(|method| method.signature.clone());
    let Some(signature) = signature else {
        session.named_report(DiagnosticCode::UndefinedMember, name_node, &name);
        return Some(crate::expression_checker::invalid(session, node));
    };
    arguments(session, node, &signature.parameters);
    let result = crate::call_checker::check_result(session, signature.result, (node, purpose));
    Some(session.emit(crate::HirExpression::Invalid, result, session.span(node)))
}

fn arguments(
    session: &mut AnalysisSession<'_>,
    node: usize,
    parameters: &[(crate::TypeId, crate::hir::Passing)],
) {
    let arguments = session
        .child(node, pseudolearn_syntax::NodeKind::Arguments)
        .map(|node| session.children(node))
        .unwrap_or_default();
    if arguments.len() != parameters.len() {
        crate::argument_checker::arity(session, (parameters.len(), arguments.len()), node);
    }
    for (node, parameter) in arguments.into_iter().zip(parameters.iter().copied()) {
        crate::function_calls::argument(session, node, parameter);
    }
}
