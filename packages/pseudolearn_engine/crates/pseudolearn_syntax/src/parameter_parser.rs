use crate::declaration_parser::{name, parse_type};
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parameters(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.require(
        TokenKind::LeftParenthesis,
        DiagnosticCode::ExpectedSubroutineLeftParenthesis,
    )?;
    if !state.eat(TokenKind::RightParenthesis) {
        parameter(state)?;
        while state.eat(TokenKind::Comma) {
            parameter(state)?;
        }
        state.require(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        )?;
    }
    Ok(state.finish(NodeKind::Parameters, start, marker))
}

fn parameter(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    if matches!(
        state.kind(),
        TokenKind::Keyword(KeywordKind::ByReference | KeywordKind::ByValue)
    ) {
        let span = state.span();
        state.report(DiagnosticCode::PassingModifierBeforeParameterName, span);
        return Err(());
    }
    name(state, DiagnosticCode::ExpectedParameterName)?;
    if state.eat(TokenKind::LeftBracket) {
        while state.eat(TokenKind::Comma) {}
        state.require(TokenKind::RightBracket, DiagnosticCode::UnclosedBracket)?;
    }
    if state.keyword(KeywordKind::TypeConnector) {
        parse_type(state)?;
    }
    state.keyword(KeywordKind::ByReference);
    state.keyword(KeywordKind::ByValue);
    Ok(state.finish(NodeKind::Parameter, start, marker))
}
