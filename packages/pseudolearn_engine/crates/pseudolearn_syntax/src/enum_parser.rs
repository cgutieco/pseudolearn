use crate::declaration_parser::name;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn enumeration(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedEnumName)?;
    state.separators();
    if !matches!(
        state.kind(),
        TokenKind::EndOfFile | TokenKind::Keyword(KeywordKind::EndEnum)
    ) {
        members(state)?;
        state.separators();
    }
    state.close(KeywordKind::EndEnum, DiagnosticCode::UnclosedEnum, start);
    Ok(state.finish(NodeKind::EnumUnit, start, marker))
}

fn members(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    name(state, DiagnosticCode::ExpectedEnumMember)?;
    while state.eat(TokenKind::Comma) {
        name(state, DiagnosticCode::ExpectedEnumMember)?;
    }
    Ok(state.finish(NodeKind::EnumMembers, start, marker))
}
