use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{NodeKind, SyntaxTree};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct SyntaxNodeId {
    pub unit_name: String,
    pub unit_kind: String,
    pub structural_path: Vec<u32>,
}

pub fn compute_unit_name(tree: &SyntaxTree, source: &SourceText, node_index: usize) -> String {
    for &child_index in tree.child_indices(node_index) {
        let Some(child) = tree.node(child_index) else {
            continue;
        };
        if child.kind != NodeKind::Identifier {
            continue;
        };
        let Some(span) = tree.span_for_node(child_index) else {
            continue;
        };
        if let Some(slice) = source.slice(span) {
            return slice.to_owned();
        }
    }
    String::from("anonymous")
}

pub fn compute_node_identities(
    tree: &SyntaxTree,
    source: &SourceText,
) -> Vec<(SyntaxNodeId, Span)> {
    let mut identities = Vec::new();
    let Some(root_index) = tree.nodes.len().checked_sub(1) else {
        return identities;
    };
    let top_children = tree.child_indices(root_index);
    for (unit_position, &child_index) in top_children.iter().enumerate() {
        let Some(child) = tree.node(child_index) else {
            continue;
        };
        let Some(child_span) = tree.span_for_node(child_index) else {
            continue;
        };
        let unit_name = compute_unit_name(tree, source, child_index);
        let unit_kind = format!("{:?}", child.kind);
        let path = vec![u32::try_from(unit_position).unwrap_or(0)];
        identities.push((
            SyntaxNodeId {
                unit_name: unit_name.clone(),
                unit_kind: unit_kind.clone(),
                structural_path: path.clone(),
            },
            child_span,
        ));
        let builder = NodeIdentityBuilder {
            tree,
            unit_name,
            unit_kind,
        };
        builder.collect_children(child_index, &path, &mut identities);
    }
    identities
}

struct NodeIdentityBuilder<'syntax> {
    tree: &'syntax SyntaxTree,
    unit_name: String,
    unit_kind: String,
}

impl NodeIdentityBuilder<'_> {
    fn collect_children(
        &self,
        node_index: usize,
        current_path: &[u32],
        output: &mut Vec<(SyntaxNodeId, Span)>,
    ) {
        for (position, &child_index) in self.tree.child_indices(node_index).iter().enumerate() {
            let Some(child_span) = self.tree.span_for_node(child_index) else {
                continue;
            };
            let mut child_path = current_path.to_vec();
            child_path.push(u32::try_from(position).unwrap_or(0));
            output.push((
                SyntaxNodeId {
                    unit_name: self.unit_name.clone(),
                    unit_kind: self.unit_kind.clone(),
                    structural_path: child_path.clone(),
                },
                child_span,
            ));
            self.collect_children(child_index, &child_path, output);
        }
    }
}
