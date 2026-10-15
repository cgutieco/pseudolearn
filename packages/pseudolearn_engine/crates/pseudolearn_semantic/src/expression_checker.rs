use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_source::Span;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub fn check_expression_node(session: &mut AnalysisSession<'_>, node_index: usize) -> Type {
    let node = match session.syntax_tree.nodes.get(node_index) {
        Some(entry) => *entry,
        None => return Type::Error,
    };
    match node.kind {
        NodeKind::LiteralExpression => check_literal(session, node.first_token),
        NodeKind::IdentifierExpression => check_identifier(session, node.first_token),
        NodeKind::BinaryExpression => check_binary(session, node_index),
        NodeKind::UnaryExpression => check_unary(session, node_index),
        _ => Type::Unknown,
    }
}

fn check_literal(session: &AnalysisSession<'_>, first_token: u32) -> Type {
    let token_index = usize::try_from(first_token).unwrap_or(0);
    match session.syntax_tree.tokens.kind(token_index) {
        Some(TokenKind::IntegerLiteral) => Type::Integer,
        Some(TokenKind::RealLiteral) => Type::Real,
        Some(TokenKind::StringLiteral) => Type::String,
        Some(TokenKind::CharacterLiteral) => Type::Character,
        Some(TokenKind::BooleanLiteral(_)) => Type::Boolean,
        _ => Type::Unknown,
    }
}

fn check_identifier(session: &mut AnalysisSession<'_>, first_token: u32) -> Type {
    let token_index = usize::try_from(first_token).unwrap_or(0);
    let identifier_text = match session
        .syntax_tree
        .tokens
        .text(session.source_text.as_str(), token_index)
    {
        Some(text) => text,
        None => return Type::Error,
    };
    let span = session
        .syntax_tree
        .tokens
        .span(token_index)
        .unwrap_or_default();
    let current_scope_instance = match session.scopes.get(session.current_scope.0) {
        Some(scope) => scope,
        None => return Type::Error,
    };
    let resolved_symbol_id = current_scope_instance.resolve(identifier_text, session.scopes);
    match resolved_symbol_id {
        Some(symbol_id) => handle_resolved_symbol(session, symbol_id, span),
        None => {
            if session.is_strict {
                session.diagnostics.push(
                    Diagnostic::new(DiagnosticCode::UndeclaredVariable, span)
                        .with_argument("lexeme", identifier_text),
                );
                Type::Error
            } else {
                session.diagnostics.push(
                    Diagnostic::new(DiagnosticCode::UndeclaredVariable, span)
                        .with_severity(pseudolearn_diagnostics::DiagnosticSeverity::Warning)
                        .with_argument("lexeme", identifier_text),
                );
                Type::Unknown
            }
        }
    }
}

fn handle_resolved_symbol(
    session: &mut AnalysisSession<'_>,
    symbol_id: crate::arena::SymbolId,
    span: Span,
) -> Type {
    let Some(symbol) = session.symbols.get_mut(symbol_id.0) else {
        return Type::Error;
    };
    if session.is_strict && !symbol.is_assigned {
        session.diagnostics.push(Diagnostic::new(
            DiagnosticCode::UninitializedVariableRead,
            span,
        ));
    }
    symbol.mark_read();
    symbol.inferred_type.clone()
}

fn check_binary(session: &mut AnalysisSession<'_>, node_index: usize) -> Type {
    let node = match session.syntax_tree.nodes.get(node_index) {
        Some(entry) => *entry,
        None => return Type::Error,
    };
    let first_token = usize::try_from(node.first_token).unwrap_or(0);
    let span = session
        .syntax_tree
        .tokens
        .span(first_token)
        .unwrap_or_default();
    let left_index = node_index.saturating_add(1);
    let left_type = check_expression_node(session, left_index);
    let right_index = left_index.saturating_add(1);
    let right_type = check_expression_node(session, right_index);
    combine_binary_types(session, &left_type, &right_type, span)
}

fn combine_binary_types(
    session: &mut AnalysisSession<'_>,
    left_type: &Type,
    right_type: &Type,
    span: Span,
) -> Type {
    if left_type.is_error() || right_type.is_error() {
        return Type::Error;
    }
    if *left_type == Type::Boolean && *right_type == Type::Boolean {
        return Type::Boolean;
    }
    if left_type.is_numeric() && right_type.is_numeric() {
        if *left_type == Type::Real || *right_type == Type::Real {
            return Type::Real;
        }
        return Type::Integer;
    }
    if *left_type == Type::String || *right_type == Type::String {
        if left_type.is_numeric() || right_type.is_numeric() {
            session.diagnostics.push(Diagnostic::new(
                DiagnosticCode::CannotConcatenateNumberWithText,
                span,
            ));
            return Type::Error;
        }
        return Type::String;
    }
    session.diagnostics.push(Diagnostic::new(
        DiagnosticCode::IncompatibleOperandTypes,
        span,
    ));
    Type::Error
}

fn check_unary(session: &mut AnalysisSession<'_>, node_index: usize) -> Type {
    let operand_index = node_index.saturating_add(1);
    let operand_type = check_expression_node(session, operand_index);
    if operand_type.is_error() {
        return Type::Error;
    }
    operand_type
}
