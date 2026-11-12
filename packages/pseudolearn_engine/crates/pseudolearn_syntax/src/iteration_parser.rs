use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn for_each(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    state.kind();
    state.advance();
    let bindings_start = state.token();
    let bindings_marker = state.nodes.len();
    crate::declaration_parser::name(state, DiagnosticCode::ExpectedForLoopVariable)?;
    if state.eat(TokenKind::Comma) {
        crate::declaration_parser::name(state, DiagnosticCode::ExpectedForLoopVariable)?;
    }
    state.finish(NodeKind::IterationBindings, bindings_start, bindings_marker);
    if !crate::contextual::eat(state, "inKeyword") {
        let span = state.span();
        state.report(DiagnosticCode::InvalidForEachCollection, span);
        return Err(());
    }
    crate::expression_parser::parse_expression(state, 0)?;
    state.require(
        TokenKind::Keyword(KeywordKind::DoKeyword),
        DiagnosticCode::ExpectedDoKeyword,
    )?;
    crate::statement_parser::parse_statement_block(state);
    state.close(
        KeywordKind::EndFor,
        DiagnosticCode::UnclosedForStatement,
        start,
    );
    Ok(state.finish(NodeKind::ForEachLoop, start, marker))
}

pub(crate) fn starts(state: &mut ParserState<'_>) -> bool {
    let cursor = state.cursor;
    state.advance();
    let found = crate::contextual::matches(state, "eachKeyword");
    state.cursor = cursor;
    found
}

pub(crate) fn defer(state: &mut ParserState<'_>) -> Result<usize, ()> {
    state.enter()?;
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    crate::statement_parser::parse_statement_block(state);
    if !crate::contextual::eat(state, "endDefer") {
        let span = state.span();
        state.report(DiagnosticCode::UnclosedDefer, span);
    }
    state.leave();
    Ok(state.finish(NodeKind::DeferStatement, start, marker))
}

pub(crate) fn break_statement(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    crate::statement_parser::terminator(state)?;
    Ok(state.finish(NodeKind::BreakStatement, start, marker))
}

pub(crate) fn statement(state: &mut ParserState<'_>) -> Option<Result<usize, ()>> {
    if crate::interface_parser::starts(state) {
        return Some(crate::interface_parser::reject_nested(state));
    }
    if crate::contextual::followed_by(state, "deferKeyword", TokenKind::Newline) {
        return Some(defer(state));
    }
    if crate::contextual::followed_by(state, "breakKeyword", TokenKind::Semicolon)
        || crate::contextual::followed_by(state, "breakKeyword", TokenKind::Newline)
    {
        return Some(break_statement(state));
    }
    None
}
