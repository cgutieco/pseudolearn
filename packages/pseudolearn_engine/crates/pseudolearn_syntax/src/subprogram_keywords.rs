use crate::parser_state::ParserState;
use crate::tokens::{TokenKind, Tokens};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub fn opens_subprogram(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Keyword(KeywordKind::Subroutine | KeywordKind::Function)
    )
}

pub fn closes_subprogram(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Keyword(KeywordKind::EndSubroutine | KeywordKind::EndFunction)
    )
}

pub fn subprogram_closing(opening: TokenKind) -> KeywordKind {
    if opening == TokenKind::Keyword(KeywordKind::Function) {
        KeywordKind::EndFunction
    } else {
        KeywordKind::EndSubroutine
    }
}

pub(crate) fn closing_at(tokens: &Tokens, opening: u32) -> KeywordKind {
    usize::try_from(opening)
        .ok()
        .and_then(|index| tokens.kind(index))
        .map_or(KeywordKind::EndSubroutine, subprogram_closing)
}

pub(crate) fn close(state: &mut ParserState<'_>, opening: u32) {
    let closing = closing_at(state.tokens, opening);
    let foreign = closes_subprogram(state.kind()) && state.kind() != TokenKind::Keyword(closing);
    state.close(closing, DiagnosticCode::UnclosedSubroutine, opening);
    if foreign {
        state.advance();
    }
}
