use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::unsupported_opening;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn reject(state: &mut ParserState<'_>) -> bool {
    let start = state.token();
    let word = state.text(start).to_lowercase();
    let Some((code, closings, allow_line)) = unsupported_opening(&word) else {
        return false;
    };
    let cursor = state.cursor;
    state.advance();
    let next = state.kind();
    state.cursor = cursor;
    if !matches!(next, TokenKind::Identifier | TokenKind::Keyword(_))
        && !(allow_line && next == TokenKind::Newline)
    {
        return false;
    }
    let span = state.span();
    state.report(code, span);
    state.advance();
    if closings.is_empty() {
        crate::statement_parser::recover(state);
        return true;
    }
    while state.kind() != TokenKind::EndOfFile {
        let token = state.token();
        if closings.contains(&state.text(token).to_lowercase().as_str()) {
            state.advance();
            break;
        }
        if matches!(
            state.kind(),
            TokenKind::Keyword(
                KeywordKind::EndAlgorithm | KeywordKind::EndSubroutine | KeywordKind::EndClass
            )
        ) {
            break;
        }
        state.advance();
    }
    true
}
