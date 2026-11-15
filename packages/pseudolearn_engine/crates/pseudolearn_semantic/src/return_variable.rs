use crate::expression_model::HirExpression;
use crate::identities::{ExpressionId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_source::Span;
use pseudolearn_syntax::NodeKind;

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct ReturnVariable {
    pub name: String,
    pub header: Span,
}

pub(crate) fn result(session: &mut AnalysisSession<'_>, function: usize) -> Option<TypeId> {
    let variable = session.child(function, NodeKind::ReturnVariable)?;
    let name_node = session.child(variable, NodeKind::Identifier)?;
    let name = session.name(name_node);
    let declared = session.child(function, NodeKind::Body).and_then(|body| {
        session
            .children(body)
            .into_iter()
            .find_map(|statement| declared_type(session, statement, &name))
    });
    if let Some(kind) = declared {
        return Some(crate::type_resolution::resolve(session, kind));
    }
    session.named_report(DiagnosticCode::ReturnVariableNotDeclared, name_node, &name);
    Some(session.module.types.intern(Type::Error))
}

fn declared_type(session: &AnalysisSession<'_>, statement: usize, name: &str) -> Option<usize> {
    let declaration = match session.kind(statement) {
        NodeKind::Statement => session.children(statement).first().copied()?,
        _ => statement,
    };
    if session.kind(declaration) != NodeKind::Declaration {
        return None;
    }
    let names = session.children(declaration);
    names
        .iter()
        .any(|child| session.kind(*child) == NodeKind::Identifier && session.name(*child) == name)
        .then(|| session.child(declaration, NodeKind::Type))
        .flatten()
}

pub(crate) fn prepare(session: &mut AnalysisSession<'_>, function: usize) {
    let variable = session
        .child(function, NodeKind::ReturnVariable)
        .and_then(|variable| session.child(variable, NodeKind::Identifier))
        .map(|name_node| ReturnVariable {
            name: session.name(name_node),
            header: session.span(function_header(session, function)),
        });
    session.control.return_variable = variable;
}

fn function_header(session: &AnalysisSession<'_>, function: usize) -> usize {
    session
        .child(function, NodeKind::Parameters)
        .unwrap_or(function)
}

pub(crate) fn returned_value(
    session: &mut AnalysisSession<'_>,
    span: Span,
) -> Option<ExpressionId> {
    let variable = session.control.return_variable.clone()?;
    let local = session.local(&variable.name)?;
    let declaration = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))?
        .clone();
    session.reads.insert(local);
    if !session
        .initialized
        .get(usize::try_from(local.0).unwrap_or(usize::MAX))
        .copied()
        .unwrap_or(false)
    {
        let cause = session.assignment.dropped.get(&local).copied();
        crate::definite_assignment_report::report(session, local, span, cause);
        if let Some(diagnostic) = session.diagnostics.last_mut() {
            diagnostic.related.push(variable.header);
        }
    }
    Some(session.emit(HirExpression::Local(local), declaration.type_id, span))
}

pub(crate) fn finish(
    session: &mut AnalysisSession<'_>,
    closing: Span,
    body: &mut Vec<crate::identities::StatementId>,
) {
    if session.control.return_variable.is_none() {
        return;
    }
    let value = returned_value(session, closing);
    session.returned = true;
    body.push(session.statement(crate::statement_model::HirStatement::Return(value), closing));
}
