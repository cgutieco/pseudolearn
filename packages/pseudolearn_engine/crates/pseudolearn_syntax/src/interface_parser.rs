use crate::declaration_parser::{name, parse_type};
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn starts(state: &mut ParserState<'_>) -> bool {
    crate::contextual::followed_by(state, "interfaceKeyword", TokenKind::Identifier)
}

pub(crate) fn interface(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedClassName)?;
    loop {
        state.separators();
        if crate::contextual::matches(state, "endInterface") || unit_boundary(state.kind()) {
            break;
        }
        let before = state.cursor;
        if signature(state).is_err() {
            crate::statement_parser::recover(state);
        }
        if state.cursor == before {
            state.advance();
        }
    }
    close(state, start);
    Ok(state.finish(NodeKind::InterfaceUnit, start, marker))
}

fn signature(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.require(
        TokenKind::Keyword(KeywordKind::Method),
        DiagnosticCode::ExpectedInterfaceSignature,
    )?;
    name(state, DiagnosticCode::ExpectedSubroutineName)?;
    crate::parameter_parser::parameters(state)?;
    if state.keyword(KeywordKind::TypeConnector) {
        parse_type(state)?;
    }
    crate::statement_parser::terminator(state)?;
    Ok(state.finish(NodeKind::InterfaceSignature, start, marker))
}

fn close(state: &mut ParserState<'_>, opening: u32) {
    if crate::contextual::eat(state, "endInterface") {
        return;
    }
    let span = state.span();
    state.report(DiagnosticCode::UnclosedInterface, span);
    let opening = usize::try_from(opening)
        .ok()
        .and_then(|token| state.tokens.span(token));
    if let (Some(diagnostic), Some(opening)) = (state.diagnostics.last_mut(), opening) {
        diagnostic.related.push(opening);
    }
}

fn unit_boundary(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::EndOfFile
            | TokenKind::Keyword(
                KeywordKind::Algorithm | KeywordKind::ClassKeyword | KeywordKind::Subroutine
            )
    )
}

pub(crate) fn reject_nested(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let span = state.span();
    state.report(DiagnosticCode::InterfaceInsideAlgorithm, span);
    state.advance();
    while !crate::contextual::eat(state, "endInterface")
        && !crate::statement_parser::boundary(state.kind())
    {
        state.advance();
    }
    Err(())
}

pub(crate) fn realization(state: &mut ParserState<'_>) -> Result<(), ()> {
    if !crate::contextual::matches(state, "implementsKeyword") {
        return Ok(());
    }
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedClassName)?;
    while state.eat(TokenKind::Comma) {
        name(state, DiagnosticCode::ExpectedClassName)?;
    }
    state.finish(NodeKind::Realization, start, marker);
    Ok(())
}
