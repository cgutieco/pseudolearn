use crate::expression_checker::{ExpressionPurpose, check_for};
use crate::hir::FunctionKind;
use crate::identities::StatementId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn body(session: &mut AnalysisSession<'_>, node: usize) -> Vec<StatementId> {
    session
        .children(node)
        .into_iter()
        .filter_map(|statement| check(session, statement))
        .collect()
}

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<StatementId> {
    if session.kind(node) == NodeKind::Statement {
        return session
            .tree
            .child_indices(node)
            .first()
            .copied()
            .and_then(|child| check(session, child));
    }
    let kind = match session.kind(node) {
        NodeKind::Declaration => crate::binding_checker::initialize(session, node)?,
        NodeKind::DimensionDeclaration => return crate::dimension_checker::check(session, node),
        NodeKind::AssignmentStatement => crate::assignment_checker::assignment(session, node)?,
        NodeKind::Output => output(session, node),
        NodeKind::Input => crate::assignment_checker::input(session, node),
        NodeKind::CallStatement => {
            let expression = session.tree.child_indices(node).first().copied()?;
            HirStatement::Call(check_for(session, expression, ExpressionPurpose::Statement))
        }
        NodeKind::ReturnStatement => returned(session, node),
        NodeKind::DiscardStatement => crate::variant_statements::discard(session, node)?,
        NodeKind::Conditional
        | NodeKind::WhileLoop
        | NodeKind::RepeatLoop
        | NodeKind::ForLoop
        | NodeKind::Switch => crate::control_checker::check(session, node)?,
        _ => return None,
    };
    Some(session.statement(kind, session.span(node)))
}

fn output(session: &mut AnalysisSession<'_>, node: usize) -> HirStatement {
    let values: Vec<_> = session
        .children(node)
        .into_iter()
        .map(|expression| crate::expression_checker::check(session, expression))
        .collect();
    for value in &values {
        crate::variant_statements::output_error(session, *value, node);
    }
    let newline = !session.has_token(node, TokenKind::Keyword(KeywordKind::WithoutNewline));
    HirStatement::Write { values, newline }
}

fn returned(session: &mut AnalysisSession<'_>, node: usize) -> HirStatement {
    let mut value = crate::variant_statements::returned_value(session, node);
    let Some(function) = crate::hierarchy::function(session, session.current).cloned() else {
        return HirStatement::Return(value);
    };
    let expected = session.module.types.get(function.result);
    let violation = match (function.kind, value) {
        (FunctionKind::Main, _) => Some(DiagnosticCode::ReturnOutsideSubroutine),
        (FunctionKind::Constructor, Some(_)) => Some(DiagnosticCode::ReturnWithValueInConstructor),
        (_, Some(_)) if expected == Type::Unit => {
            Some(DiagnosticCode::ReturnExpressionInVoidSubroutine)
        }
        (_, None) if expected != Type::Unit => Some(DiagnosticCode::MissingReturnExpression),
        _ => None,
    };
    if let Some(code) = violation {
        session.report(code, node);
    }
    if let Some(expression) = value {
        if expected != Type::Unit
            && !crate::type_resolution::assignable(
                session,
                &expected,
                &session.expression_type(expression),
            )
        {
            session.report(DiagnosticCode::IncompatibleReturnType, node);
        }
        value = Some(crate::expression_checker::widen(
            session, expression, &expected,
        ));
    }
    crate::result_obligations::finish(session);
    session.pending_results.clear();
    session.returned = true;
    HirStatement::Return(value)
}
