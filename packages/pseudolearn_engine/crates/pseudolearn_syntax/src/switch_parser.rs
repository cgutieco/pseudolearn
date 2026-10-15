use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::statement_parser::{boundary, parse_case_body};
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn switch(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    parse_expression(state, 0)?;
    state.require(
        TokenKind::Keyword(KeywordKind::DoKeyword),
        DiagnosticCode::ExpectedDoKeyword,
    )?;
    loop {
        state.separators();
        if state.kind() == TokenKind::Keyword(KeywordKind::EndSwitch)
            || state.kind() == TokenKind::EndOfFile
        {
            break;
        }
        if state.kind() == TokenKind::Keyword(KeywordKind::DefaultCase) {
            default_case(state)?;
            break;
        }
        if boundary(state.kind()) {
            break;
        }
        case(state)?;
    }
    state.close(
        KeywordKind::EndSwitch,
        DiagnosticCode::UnclosedSwitchStatement,
        start,
    );
    Ok(state.finish(NodeKind::Switch, start, marker))
}

fn case(state: &mut ParserState<'_>) -> Result<(), ()> {
    let start = state.token();
    let marker = state.nodes.len();
    parse_expression(state, 0)?;
    while state.eat(TokenKind::Comma) {
        parse_expression(state, 0)?;
    }
    state.finish(NodeKind::Labels, start, marker);
    state.require(TokenKind::Colon, DiagnosticCode::ExpectedBranchSeparator)?;
    parse_case_body(state);
    state.finish(NodeKind::Statement, start, marker);
    Ok(())
}

fn default_case(state: &mut ParserState<'_>) -> Result<(), ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    state.require(TokenKind::Colon, DiagnosticCode::ExpectedBranchSeparator)?;
    parse_case_body(state);
    state.finish(NodeKind::DefaultCase, start, marker);
    Ok(())
}

pub(crate) fn starts_label(state: &mut ParserState<'_>) -> bool {
    if !state.kind().is_literal() && state.kind() != TokenKind::Minus {
        return false;
    }
    let mut token = state.cursor;
    loop {
        match state.tokens.kind(token) {
            Some(TokenKind::Colon) => return true,
            Some(TokenKind::Newline | TokenKind::Semicolon | TokenKind::EndOfFile) | None => {
                return false;
            }
            _ => token = token.saturating_add(1),
        }
    }
}
