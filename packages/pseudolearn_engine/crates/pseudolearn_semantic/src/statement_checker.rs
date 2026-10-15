use crate::arena::SymbolId;
use crate::expression_checker::check_expression_node;
use crate::session::AnalysisSession;
use crate::symbols::{Symbol, SymbolKind};
use crate::types::Type;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_source::Span;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub fn check_statement_node(session: &mut AnalysisSession<'_>, node_index: usize) {
    let node = match session.syntax_tree.nodes.get(node_index) {
        Some(entry) => *entry,
        None => return,
    };
    match node.kind {
        NodeKind::VariableDeclaration => check_variable_declaration(session, node.first_token),
        NodeKind::AssignmentStatement => check_assignment(session, node.first_token),
        NodeKind::IfStatement | NodeKind::WhileStatement => {
            check_condition_statement(session, node_index)
        }
        _ => {}
    }
}

fn check_variable_declaration(session: &mut AnalysisSession<'_>, first_token: u32) {
    let mut token_index = usize::try_from(first_token).unwrap_or(0).saturating_add(1);
    let mut names = Vec::new();
    while token_index < session.syntax_tree.tokens.token_count() {
        match session.syntax_tree.tokens.kind(token_index) {
            Some(TokenKind::Identifier) => {
                if let Some(text) = session
                    .syntax_tree
                    .tokens
                    .text(session.source_text.as_str(), token_index)
                {
                    let span = session
                        .syntax_tree
                        .tokens
                        .span(token_index)
                        .unwrap_or_default();
                    names.push((text.to_owned(), span));
                }
            }
            Some(TokenKind::Keyword(_)) => break,
            _ => {}
        }
        token_index = token_index.saturating_add(1);
    }
    let declared_type = Type::Integer;
    for (name, span) in names {
        insert_variable(session, name, declared_type.clone(), span);
    }
}

fn insert_variable(
    session: &mut AnalysisSession<'_>,
    name: String,
    declared_type: Type,
    span: Span,
) {
    let scope = match session.scopes.get_mut(session.current_scope.0) {
        Some(entry) => entry,
        None => return,
    };
    if scope.find_local(&name).is_some() {
        session.diagnostics.push(Diagnostic::new(
            DiagnosticCode::DuplicateVariableDeclaration,
            span,
        ));
        return;
    }
    let symbol = Symbol::new(
        name.clone(),
        SymbolKind::Variable,
        span,
        session.current_scope,
    )
    .with_type(declared_type);
    let symbol_id = session.symbols.allocate(symbol);
    scope.insert(&name, SymbolId(symbol_id));
}

fn check_assignment(session: &mut AnalysisSession<'_>, first_token: u32) {
    let target_token_index = usize::try_from(first_token).unwrap_or(0);
    let target_name = match session
        .syntax_tree
        .tokens
        .text(session.source_text.as_str(), target_token_index)
    {
        Some(text) => text,
        None => return,
    };
    let span = session
        .syntax_tree
        .tokens
        .span(target_token_index)
        .unwrap_or_default();
    let scope = match session.scopes.get(session.current_scope.0) {
        Some(entry) => entry,
        None => return,
    };
    let resolved = scope.resolve(target_name, session.scopes);
    match resolved {
        Some(symbol_id) => {
            if let Some(symbol) = session.symbols.get_mut(symbol_id.0) {
                symbol.mark_assigned();
            }
        }
        None => {
            if session.is_strict {
                session
                    .diagnostics
                    .push(Diagnostic::new(DiagnosticCode::UndeclaredVariable, span));
            }
        }
    }
}

fn check_condition_statement(session: &mut AnalysisSession<'_>, node_index: usize) {
    let condition_index = node_index.saturating_add(1);
    let condition_type = check_expression_node(session, condition_index);
    if !condition_type.is_error() && !condition_type.is_boolean() {
        let node = match session.syntax_tree.nodes.get(node_index) {
            Some(entry) => entry,
            None => return,
        };
        let first_token = usize::try_from(node.first_token).unwrap_or(0);
        let span = session
            .syntax_tree
            .tokens
            .span(first_token)
            .unwrap_or_default();
        session
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::NonBooleanCondition, span));
    }
}
