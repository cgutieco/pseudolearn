use super::{HelpIdentity, HelpIdentityKind, identity};
use crate::query_context::QueryContext;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::Span;
use pseudolearn_syntax::{NodeKind, SyntaxTree};

pub(super) fn contextual_keyword(
    context: &QueryContext<'_>,
    slot: usize,
    keyword: KeywordKind,
) -> Option<(HelpIdentity, Span)> {
    let (node, span) = smallest_node(context, slot, |node| {
        contextual_parts(node, keyword).is_some()
    })?;
    let (kind, id, role) = contextual_parts(node, keyword)?;
    Some((identity(kind, id, role), span))
}

fn contextual_parts(
    node: NodeKind,
    keyword: KeywordKind,
) -> Option<(HelpIdentityKind, &'static str, &'static str)> {
    match node {
        NodeKind::AlgorithmUnit => algorithm_parts(keyword),
        NodeKind::ForLoop => for_parts(keyword),
        NodeKind::WhileLoop => while_parts(keyword),
        NodeKind::Switch => switch_parts(keyword),
        NodeKind::RepeatLoop => repeat_parts(keyword),
        NodeKind::Parameter => parameter_parts(keyword),
        _ => None,
    }
}

fn algorithm_parts(keyword: KeywordKind) -> Option<(HelpIdentityKind, &'static str, &'static str)> {
    match keyword {
        KeywordKind::Algorithm => Some((HelpIdentityKind::Construction, "algorithm", "opening")),
        KeywordKind::EndAlgorithm => Some((HelpIdentityKind::Construction, "algorithm", "closing")),
        _ => None,
    }
}

fn for_parts(keyword: KeywordKind) -> Option<(HelpIdentityKind, &'static str, &'static str)> {
    match keyword {
        KeywordKind::ForKeyword => Some((HelpIdentityKind::Construction, "for", "opening")),
        KeywordKind::To => Some((HelpIdentityKind::Construction, "for", "range_limit")),
        KeywordKind::Step => Some((HelpIdentityKind::Construction, "for", "step_clause")),
        KeywordKind::DoKeyword => Some((HelpIdentityKind::Construction, "for", "body_start")),
        KeywordKind::EndFor => Some((HelpIdentityKind::Construction, "for", "closing")),
        _ => None,
    }
}

fn while_parts(keyword: KeywordKind) -> Option<(HelpIdentityKind, &'static str, &'static str)> {
    match keyword {
        KeywordKind::WhileKeyword => Some((HelpIdentityKind::Construction, "while", "opening")),
        KeywordKind::DoKeyword => Some((HelpIdentityKind::Construction, "while", "body_start")),
        KeywordKind::EndWhile => Some((HelpIdentityKind::Construction, "while", "closing")),
        _ => None,
    }
}

fn switch_parts(keyword: KeywordKind) -> Option<(HelpIdentityKind, &'static str, &'static str)> {
    match keyword {
        KeywordKind::SwitchKeyword => Some((HelpIdentityKind::Construction, "switch", "opening")),
        KeywordKind::DoKeyword => Some((HelpIdentityKind::Construction, "switch", "body_start")),
        KeywordKind::EndSwitch => Some((HelpIdentityKind::Construction, "switch", "closing")),
        _ => None,
    }
}

fn repeat_parts(keyword: KeywordKind) -> Option<(HelpIdentityKind, &'static str, &'static str)> {
    match keyword {
        KeywordKind::Repeat => Some((HelpIdentityKind::Construction, "repeat", "opening")),
        KeywordKind::Until => Some((HelpIdentityKind::Construction, "repeat", "condition_start")),
        _ => None,
    }
}

fn parameter_parts(keyword: KeywordKind) -> Option<(HelpIdentityKind, &'static str, &'static str)> {
    match keyword {
        KeywordKind::ByReference => {
            Some((HelpIdentityKind::Role, "parameter", "pass_by_reference"))
        }
        KeywordKind::ByValue => Some((HelpIdentityKind::Role, "parameter", "pass_by_value")),
        _ => None,
    }
}

pub(super) fn smallest_node(
    context: &QueryContext<'_>,
    slot: usize,
    accepts: impl Fn(NodeKind) -> bool,
) -> Option<(NodeKind, Span)> {
    smallest_in_tree(context.tree, slot, accepts)
}

pub(super) fn smallest_in_tree(
    tree: &SyntaxTree,
    slot: usize,
    accepts: impl Fn(NodeKind) -> bool,
) -> Option<(NodeKind, Span)> {
    let mut best: Option<(usize, NodeKind, Span)> = None;
    for (index, node) in tree.nodes.iter().enumerate() {
        if !accepts(node.kind) {
            continue;
        }
        let Some(first) = usize::try_from(node.first_token).ok() else {
            continue;
        };
        let Some(ending) = tree
            .ending_tokens
            .get(index)
            .and_then(|value| usize::try_from(*value).ok())
        else {
            continue;
        };
        if slot < first || slot > ending {
            continue;
        }
        let width = ending.saturating_sub(first);
        let Some(span) = tree.span_for_node(index) else {
            continue;
        };
        if best.is_none_or(|(best_width, _, _)| width < best_width) {
            best = Some((width, node.kind, span));
        }
    }
    best.map(|(_, kind, span)| (kind, span))
}
