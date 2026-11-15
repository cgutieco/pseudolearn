use crate::workspace_model::WorkspaceIndex;
use pseudolearn_source::IdentifierNormalizer;
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use std::collections::hash_map::DefaultHasher;
use std::collections::{BTreeMap, BTreeSet};
use std::hash::{Hash, Hasher};

pub(crate) type ReverseDependencies = BTreeMap<String, BTreeSet<String>>;

pub(crate) fn template_consumers(
    (previous, current): (&WorkspaceIndex, &WorkspaceIndex),
    changed: &BTreeSet<String>,
    reverse: &ReverseDependencies,
) -> BTreeSet<String> {
    let mut consumers = BTreeSet::new();
    for path in changed {
        let before = templates_of(previous, path);
        let after = templates_of(current, path);
        let edited: BTreeSet<String> = before
            .iter()
            .chain(after.iter())
            .filter(|(name, _)| before.get(*name) != after.get(*name))
            .map(|(name, _)| name.clone())
            .collect();
        for name in edited {
            consumers.extend(instantiating_importers(current, reverse, path, &name));
        }
    }
    consumers
}

fn instantiating_importers(
    index: &WorkspaceIndex,
    reverse: &ReverseDependencies,
    origin: &str,
    name: &str,
) -> BTreeSet<String> {
    let mut found = BTreeSet::new();
    let mut frontier = vec![origin.to_owned()];
    while let Some(target) = frontier.pop() {
        for importer in reverse.get(&target).into_iter().flatten() {
            if mentions(index, importer, name) && found.insert(importer.clone()) {
                frontier.push(importer.clone());
            }
        }
    }
    found
}

fn mentions(index: &WorkspaceIndex, path: &str, name: &str) -> bool {
    let (Some(parsed), Some(file)) = (index.parsed_units.get(path), index.files.get(path)) else {
        return false;
    };
    let tree = &parsed.tree;
    (0..tree.tokens.token_count()).any(|slot| {
        tree.tokens.kind(slot) == Some(TokenKind::Identifier)
            && tree
                .tokens
                .text(&file.text, slot)
                .is_some_and(|text| IdentifierNormalizer::equals(text, name))
    })
}

fn templates_of(index: &WorkspaceIndex, path: &str) -> BTreeMap<String, u64> {
    let (Some(parsed), Some(file)) = (index.parsed_units.get(path), index.files.get(path)) else {
        return BTreeMap::new();
    };
    let tree: &SyntaxTree = &parsed.tree;
    (0..tree.nodes.len())
        .filter(|node| is_template(tree, *node))
        .filter_map(|node| {
            let name = template_name(tree, &file.text, node)?;
            let span = tree.span_for_node(node)?;
            let start = usize::try_from(span.start).ok()?;
            let ending = usize::try_from(span.ending).ok()?;
            let mut hasher = DefaultHasher::new();
            file.text.get(start..ending).hash(&mut hasher);
            Some((IdentifierNormalizer::normalize(&name), hasher.finish()))
        })
        .collect()
}

fn is_template(tree: &SyntaxTree, node: usize) -> bool {
    let unit = tree.node(node).is_some_and(|syntax| {
        matches!(
            syntax.kind,
            NodeKind::Subprogram
                | NodeKind::RecordUnit
                | NodeKind::ClassUnit
                | NodeKind::InterfaceUnit
                | NodeKind::VariantUnit
        )
    });
    unit && child_of_kind(tree, node, NodeKind::TypeParameters).is_some()
}

fn template_name(tree: &SyntaxTree, text: &str, node: usize) -> Option<String> {
    let name = child_of_kind(tree, node, NodeKind::Identifier)?;
    let token = usize::try_from(tree.node(name)?.first_token).ok()?;
    tree.tokens.text(text, token).map(str::to_owned)
}

fn child_of_kind(tree: &SyntaxTree, node: usize, kind: NodeKind) -> Option<usize> {
    tree.child_indices(node)
        .iter()
        .copied()
        .find(|child| tree.node(*child).is_some_and(|syntax| syntax.kind == kind))
}
