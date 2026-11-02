use super::{
    HelpCertainty, HelpIdentityKind, HelpSymbol, ResolutionTarget, contextual_certainty, identity,
};
use crate::hover::hover_for_token;
use crate::query_context::QueryContext;
use pseudolearn_source::Span;
use pseudolearn_syntax::TokenKind;

pub(super) fn target(
    context: &QueryContext<'_>,
    slot: usize,
    span: Span,
) -> Option<ResolutionTarget> {
    if let Some(target) = contextual_identifier_target(context, slot, span) {
        return Some(target);
    }
    if context.index.at_token_span(span).is_some() {
        let outcome = hover_for_token(context, slot)?;
        return Some(ResolutionTarget {
            identity: None,
            symbol: Some(HelpSymbol {
                category: symbol_category(outcome.category).to_owned(),
                identifier: outcome.identifier,
            }),
            certainty: HelpCertainty::Certain,
            enclosing: None,
        });
    }
    if is_member_access(context, slot) {
        return None;
    }
    let builtin = pseudolearn_lexicon::find_builtin(context.token_text(slot), context.profile)?;
    Some(ResolutionTarget {
        identity: Some(identity(
            HelpIdentityKind::Builtin,
            builtin.as_str(),
            "call",
        )),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing: None,
    })
}

fn contextual_identifier_target(
    context: &QueryContext<'_>,
    slot: usize,
    span: Span,
) -> Option<ResolutionTarget> {
    let generic = super::context::generic_constraint(context, slot).map(|(identity, enclosing)| {
        ResolutionTarget {
            identity: Some(identity),
            symbol: None,
            certainty: contextual_certainty(context),
            enclosing: Some(enclosing),
        }
    });
    generic.or_else(|| super::context::contextual_target(context, slot, span))
}

fn is_member_access(context: &QueryContext<'_>, slot: usize) -> bool {
    slot.checked_sub(1)
        .is_some_and(|previous| context.tree.tokens.kind(previous) == Some(TokenKind::Dot))
}

fn symbol_category(category: crate::hover::HoverCategory) -> &'static str {
    match category {
        crate::hover::HoverCategory::Variable => "variable",
        crate::hover::HoverCategory::Parameter => "parameter",
        crate::hover::HoverCategory::Field => "field",
        crate::hover::HoverCategory::Function => "function",
        crate::hover::HoverCategory::Procedure => "procedure",
        crate::hover::HoverCategory::Method => "method",
        crate::hover::HoverCategory::Class => "class",
        crate::hover::HoverCategory::Builtin => "builtin",
        crate::hover::HoverCategory::Keyword => "keyword",
    }
}
