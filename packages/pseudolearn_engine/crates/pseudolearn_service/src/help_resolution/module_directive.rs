use super::{HelpIdentity, HelpIdentityKind, identity};
use crate::query_context::QueryContext;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::{KeywordKind, find_keyword};
use pseudolearn_source::Span;
use pseudolearn_syntax::TokenKind;

pub(super) fn module_directive(
    context: &QueryContext<'_>,
    slot: usize,
) -> Option<(HelpIdentity, Span, &'static str)> {
    let kind = context.tree.tokens.kind(slot)?;
    let directive_keyword = match kind {
        TokenKind::Identifier => find_keyword(context.token_text(slot), context.profile)?,
        TokenKind::Keyword(keyword) => keyword,
        _ => return None,
    };
    for diagnostic in context.syntax_diagnostics {
        if diagnostic.code == DiagnosticCode::ModuleSyntaxOutsideProject
            && let Some(resolution) =
                resolve_diagnostic_context(context, slot, directive_keyword, diagnostic.span)
        {
            return Some(resolution);
        }
    }
    None
}

fn resolve_diagnostic_context(
    context: &QueryContext<'_>,
    slot: usize,
    directive_keyword: KeywordKind,
    span: Span,
) -> Option<(HelpIdentity, Span, &'static str)> {
    let start = (0..context.tree.tokens.token_count())
        .find(|candidate| context.tree.tokens.span(*candidate) == Some(span))?;
    if context.tree.tokens.kind(start) != Some(TokenKind::Identifier) {
        return None;
    }
    let directive = find_keyword(context.token_text(start), context.profile)?;
    let selected_directive = slot == start;
    let selected_alias = directive_keyword == KeywordKind::TypeConnector
        && slot > start
        && same_directive_line(context, start, slot);
    let (id, role, token) = directive_role(directive, selected_directive, selected_alias)?;
    Some((
        identity(HelpIdentityKind::Construction, id, role),
        span,
        token,
    ))
}

fn directive_role(
    directive: KeywordKind,
    selected_directive: bool,
    selected_alias: bool,
) -> Option<(&'static str, &'static str, &'static str)> {
    match directive {
        KeywordKind::ImportKeyword if selected_directive => {
            Some(("importDeclaration", "module_import", "importKeyword"))
        }
        KeywordKind::ExportKeyword if selected_directive => {
            Some(("exportDeclaration", "module_export", "exportKeyword"))
        }
        KeywordKind::ImportKeyword if selected_alias => {
            Some(("importDeclaration", "alias", "typeConnector"))
        }
        _ => None,
    }
}

fn same_directive_line(context: &QueryContext<'_>, start: usize, ending: usize) -> bool {
    let Some(first_slot) = start.checked_add(1) else {
        return false;
    };
    (first_slot..ending).all(|slot| {
        !matches!(
            context.tree.tokens.kind(slot),
            Some(TokenKind::Newline | TokenKind::Semicolon)
        )
    })
}
