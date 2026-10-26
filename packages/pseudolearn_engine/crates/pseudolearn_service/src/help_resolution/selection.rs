use crate::query_context::QueryContext;
use pseudolearn_syntax::TokenKind;

pub(super) fn token_identity(
    context: &QueryContext<'_>,
    slot: usize,
    kind: TokenKind,
) -> Option<String> {
    if let Some(identity) = crate::contextual_tokens::collect(
        context.tree,
        context.source,
        context.analysis,
        context.profile,
    )
    .get(&slot)
    {
        return Some((*identity).to_owned());
    }
    match kind {
        TokenKind::Identifier
            if context
                .index
                .at_token_span(context.tree.tokens.span(slot)?)
                .is_none() =>
        {
            pseudolearn_lexicon::find_builtin(context.token_text(slot), context.profile)
                .map(|builtin| builtin.as_str().to_owned())
        }
        TokenKind::BooleanLiteral(value) => {
            Some(if value { "booleanTrue" } else { "booleanFalse" }.to_owned())
        }
        TokenKind::Keyword(keyword) => Some(
            super::operator::keyword_operator_identity(keyword)
                .map_or_else(|| keyword.as_str(), |id| id)
                .to_owned(),
        ),
        other => super::operator::operator_identity(other).map(str::to_owned),
    }
}

pub(super) fn selected_token(context: &QueryContext<'_>, offset: usize) -> Option<usize> {
    let mut ending_candidate = None;
    for slot in 0..context.tree.tokens.token_count() {
        let (Some(kind), Some(span)) = (
            context.tree.tokens.kind(slot),
            context.tree.tokens.span(slot),
        ) else {
            continue;
        };
        if kind.is_trivia() || kind == TokenKind::EndOfFile {
            continue;
        }
        let Some(start) = usize::try_from(span.start).ok() else {
            continue;
        };
        let Some(ending) = usize::try_from(span.ending).ok() else {
            continue;
        };
        if start <= offset && offset < ending {
            return Some(slot);
        }
        if ending == offset {
            ending_candidate = Some(slot);
        }
    }
    ending_candidate
}
