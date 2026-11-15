use crate::parser_state::ParserState;
use crate::tokens::TokenKind;

pub(crate) fn matches(state: &mut ParserState<'_>, identity: &str) -> bool {
    let token = state.token();
    let profile = if state.profile == pseudolearn_lexicon::Profile::Spanish {
        "es"
    } else {
        "en"
    };
    state.kind() == TokenKind::Identifier
        && crate::tree::contextual_identity(&state.text(token).to_lowercase(), profile)
            == Some(identity)
}

pub(crate) fn eat(state: &mut ParserState<'_>, identity: &str) -> bool {
    if !matches(state, identity) {
        return false;
    }
    state.advance();
    true
}

pub(crate) fn followed_by(state: &mut ParserState<'_>, identity: &str, kind: TokenKind) -> bool {
    if !matches(state, identity) {
        return false;
    }
    let cursor = state.cursor;
    state.advance();
    let matches = state.kind() == kind;
    state.cursor = cursor;
    matches
}
