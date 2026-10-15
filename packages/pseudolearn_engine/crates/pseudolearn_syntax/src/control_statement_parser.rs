use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::statement_parser::parse_statement_block;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parse_if_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia_and_newlines();
    let _condition = parse_expression(parser_state, 0)?;
    parser_state.skip_trivia();
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::Then)) {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::ExpectedThenKeyword, span));
    }
    parse_statement_block(parser_state);
    if parser_state.eat_if(TokenKind::Keyword(KeywordKind::ElseKeyword)) {
        parse_statement_block(parser_state);
    }
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::EndIf)) {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::UnclosedIfStatement, span));
    }
    Some(parser_state.push_node(NodeKind::IfStatement, first_token, 1))
}

pub(crate) fn parse_while_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia_and_newlines();
    let _condition = parse_expression(parser_state, 0)?;
    parser_state.skip_trivia();
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::DoKeyword)) {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::ExpectedDoKeyword, span));
    }
    parse_statement_block(parser_state);
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::EndWhile)) {
        let span = parser_state.current_span();
        parser_state.diagnostics.push(Diagnostic::new(
            DiagnosticCode::UnclosedWhileStatement,
            span,
        ));
    }
    Some(parser_state.push_node(NodeKind::WhileStatement, first_token, 1))
}

pub(crate) fn parse_repeat_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parse_statement_block(parser_state);
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::Until)) {
        let span = parser_state.current_span();
        parser_state.diagnostics.push(Diagnostic::new(
            DiagnosticCode::UnclosedRepeatStatement,
            span,
        ));
        return None;
    }
    let _condition = parse_expression(parser_state, 0)?;
    Some(parser_state.push_node(NodeKind::RepeatStatement, first_token, 1))
}

pub(crate) fn parse_for_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia();
    if parser_state.current_kind() != TokenKind::Identifier {
        let span = parser_state.current_span();
        parser_state.diagnostics.push(Diagnostic::new(
            DiagnosticCode::ExpectedForLoopVariable,
            span,
        ));
        return None;
    }
    parser_state.advance();
    parser_state.skip_trivia();
    parser_state.eat_if(TokenKind::Assignment);
    let _start_value = parse_expression(parser_state, 0)?;
    parser_state.skip_trivia();
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::To)) {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::ExpectedToKeyword, span));
    }
    let _end_value = parse_expression(parser_state, 0)?;
    if parser_state.eat_if(TokenKind::Keyword(KeywordKind::Step)) {
        let _step_value = parse_expression(parser_state, 0)?;
    }
    parser_state.eat_if(TokenKind::Keyword(KeywordKind::DoKeyword));
    parse_statement_block(parser_state);
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::EndFor)) {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::UnclosedForStatement, span));
    }
    Some(parser_state.push_node(NodeKind::ForStatement, first_token, 1))
}

pub(crate) fn parse_switch_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    let _value = parse_expression(parser_state, 0)?;
    parser_state.eat_if(TokenKind::Keyword(KeywordKind::DoKeyword));
    while !is_switch_terminator(parser_state.current_kind()) {
        if parser_state.current_kind() == TokenKind::Keyword(KeywordKind::DefaultCase) {
            parser_state.advance();
            parser_state.eat_if(TokenKind::Colon);
            parse_statement_block(parser_state);
            break;
        }
        parse_case_clause(parser_state);
    }
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::EndSwitch)) {
        let span = parser_state.current_span();
        parser_state.diagnostics.push(Diagnostic::new(
            DiagnosticCode::UnclosedSwitchStatement,
            span,
        ));
    }
    Some(parser_state.push_node(NodeKind::SwitchStatement, first_token, 1))
}

fn parse_case_clause(parser_state: &mut ParserState<'_>) {
    let clause_token = parser_state.current_token_u32();
    let before = parser_state.current_token_u32();
    let _label = parse_expression(parser_state, 0);
    while parser_state.eat_if(TokenKind::Comma) {
        let _next_label = parse_expression(parser_state, 0);
    }
    parser_state.eat_if(TokenKind::Colon);
    parse_statement_block(parser_state);
    if parser_state.current_token_u32() == before
        && parser_state.current_kind() != TokenKind::EndOfFile
    {
        parser_state.advance();
    }
    parser_state.push_node(NodeKind::CaseClause, clause_token, 1);
}

fn is_switch_terminator(token_kind: TokenKind) -> bool {
    matches!(
        token_kind,
        TokenKind::EndOfFile
            | TokenKind::Keyword(KeywordKind::EndSwitch)
            | TokenKind::Keyword(KeywordKind::EndAlgorithm)
            | TokenKind::Keyword(KeywordKind::EndSubroutine)
            | TokenKind::Keyword(KeywordKind::EndClass)
    )
}
