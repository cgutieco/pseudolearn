use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{EFFECT_OPERATIONS, EffectOperation, HirExpression, ServiceAnalysis};
use pseudolearn_syntax::{NodeKind, SyntaxTree};
use std::collections::BTreeMap;

pub(crate) type EffectNames = BTreeMap<usize, &'static EffectOperation>;

pub(crate) fn collect(tree: &SyntaxTree, analysis: &ServiceAnalysis) -> EffectNames {
    analysis
        .module
        .expressions
        .kinds
        .iter()
        .filter_map(|kind| {
            let HirExpression::Effect {
                operation,
                receiver,
                source_node_id,
                ..
            } = kind
            else {
                return None;
            };
            let found = EFFECT_OPERATIONS
                .iter()
                .find(|candidate| candidate.id == *operation)?;
            let node = usize::try_from(*source_node_id).ok()?;
            Some((name_token(tree, node, receiver.is_some())?, found))
        })
        .collect()
}

pub(crate) fn spelling(operation: &EffectOperation, profile: Profile) -> &'static str {
    match profile {
        Profile::Spanish => operation.spanish,
        Profile::English => operation.english,
    }
}

fn name_token(tree: &SyntaxTree, node: usize, has_receiver: bool) -> Option<usize> {
    let child = *tree.child_indices(node).get(usize::from(has_receiver))?;
    let syntax = tree.node(child)?;
    if syntax.kind != NodeKind::Identifier {
        return None;
    }
    usize::try_from(syntax.first_token).ok()
}
