use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn block_opening(kind: TokenKind) -> Option<KeywordKind> {
    match kind {
        TokenKind::Keyword(
            opening @ (KeywordKind::IfKeyword
            | KeywordKind::WhileKeyword
            | KeywordKind::Repeat
            | KeywordKind::ForKeyword
            | KeywordKind::SwitchKeyword
            | KeywordKind::TasksKeyword
            | KeywordKind::SelectKeyword),
        ) => Some(opening),
        _ => None,
    }
}

fn owner(kind: TokenKind) -> Option<KeywordKind> {
    let TokenKind::Keyword(keyword) = kind else {
        return None;
    };
    Some(match keyword {
        KeywordKind::ElseKeyword | KeywordKind::EndIf => KeywordKind::IfKeyword,
        KeywordKind::EndWhile => KeywordKind::WhileKeyword,
        KeywordKind::Until => KeywordKind::Repeat,
        KeywordKind::EndFor => KeywordKind::ForKeyword,
        KeywordKind::EndSwitch | KeywordKind::DefaultCase => KeywordKind::SwitchKeyword,
        KeywordKind::EndTasks => KeywordKind::TasksKeyword,
        KeywordKind::EndSelect => KeywordKind::SelectKeyword,
        _ => return None,
    })
}

pub(crate) fn discard_stray(state: &mut ParserState<'_>) -> bool {
    let Some(opening) = owner(state.kind()) else {
        return false;
    };
    if state.open_blocks.contains(&opening) {
        return false;
    }
    let span = state.span();
    state.report(DiagnosticCode::UnexpectedStatement, span);
    state.advance();
    true
}
