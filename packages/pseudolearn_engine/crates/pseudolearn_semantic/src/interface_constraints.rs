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
    for (index, constraint) in template.constraints.iter().enumerate() {
        let Some(name) = constraint else {
            continue;
        };
        let Some(interface) = crate::interface_registry::find(session, name) else {
            session.named_report(DiagnosticCode::UnknownInterface, template.node, name);
            valid = false;
            continue;
        };
        if !arguments
            .get(index)
            .is_some_and(|argument| satisfies(session, *argument, interface))
        {
            session.named_report(DiagnosticCode::GenericConstraintNotSatisfied, origin, name);
            if let Some(diagnostic) = session.diagnostics.last_mut() {
                diagnostic.related.push(
                    session
                        .tree
                        .span_for_node(template.node)
                        .unwrap_or_default(),
                );
            }
            valid = false;
        }
        record(session, template, index, interface);
    }
    valid
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
    crate::call_checker::check_result(session, signature.result, (node, purpose));
    Some(session.emit(
        crate::HirExpression::Invalid,
        signature.result,
        session.span(node),
    ))
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
