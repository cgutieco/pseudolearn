use crate::session::AnalysisSession;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::TokenKind;

pub(crate) fn opens_with_function(session: &AnalysisSession<'_>, node: usize) -> bool {
    let Some(start) = session
        .tree
        .node(node)
        .and_then(|syntax| usize::try_from(syntax.first_token).ok())
    else {
        return false;
    };
    (start..session.tree.tokens.token_count())
        .filter_map(|token| session.tree.tokens.kind(token))
        .find(|kind| !kind.is_trivia() && !visibility(*kind))
        == Some(TokenKind::Keyword(KeywordKind::Function))
}

fn visibility(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Keyword(KeywordKind::PublicVisibility | KeywordKind::PrivateVisibility)
    )
}
