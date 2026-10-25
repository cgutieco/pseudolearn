use crate::declaration_parser::name;
use crate::parser_state::ParserState;
use crate::statement_parser::{recover, terminator};
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn record(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedRecordName)?;
    crate::generic_parser::optional_parameters(state)?;
    loop {
        state.separators();
        if matches!(
            state.kind(),
            TokenKind::EndOfFile | TokenKind::Keyword(KeywordKind::EndRecord)
        ) {
            break;
        }
        let before = state.cursor;
        if field(state).is_err() {
            recover(state);
        }
        if state.cursor == before {
            state.advance();
        }
    }
    state.close(
        KeywordKind::EndRecord,
        DiagnosticCode::UnclosedRecord,
        start,
    );
    Ok(state.finish(NodeKind::RecordUnit, start, marker))
}

fn field(state: &mut ParserState<'_>) -> Result<usize, ()> {
    if state.kind() != TokenKind::Keyword(KeywordKind::Declare) {
        let span = state.span();
        state.report(DiagnosticCode::ExpectedRecordField, span);
        return Err(());
    }
    let start = state.token();
    let marker = state.nodes.len();
    crate::declaration_parser::field(state)?;
    terminator(state)?;
    Ok(state.finish(NodeKind::RecordField, start, marker))
}
