use crate::program_view::ViewNode;
use crate::program_view_annotations::{AnnotationContext, Attributes, first_token};
use crate::program_view_kind::ViewKind;
use pseudolearn_syntax::{NodeKind, SyntaxTree};
use serde_json::json;

pub(crate) fn classify(kind: NodeKind) -> Option<ViewKind> {
    match kind {
        NodeKind::TaskScope
        | NodeKind::SpawnStatement
        | NodeKind::SelectStatement
        | NodeKind::ReceiveBranch => Some(ViewKind::Statement),
        NodeKind::AwaitExpression | NodeKind::SpawnExpression => Some(ViewKind::Expression),
        _ => None,
    }
}

pub(crate) fn syntax_name(kind: NodeKind) -> Option<&'static str> {
    Some(match kind {
        NodeKind::TaskScope => "task_scope",
        NodeKind::SpawnStatement => "spawn_statement",
        NodeKind::SpawnExpression => "spawn_expression",
        NodeKind::AwaitExpression => "await_expression",
        NodeKind::SelectStatement => "select_statement",
        NodeKind::ReceiveBranch => "receive_branch",
        _ => return None,
    })
}

pub(crate) fn type_attributes(
    node: &ViewNode,
    context: &AnnotationContext<'_>,
) -> Option<Attributes> {
    let token = first_token(context.tree, node.syntax_index)?;
    let name = context.tree.tokens.text(context.source.as_str(), token)?;
    let builtin = match name.to_lowercase().as_str() {
        "tarea" | "task" => "task",
        "canal" | "channel" => "channel",
        "inmutable" | "immutable" => "immutable",
        "fallotareas" | "taskfailure" => "task_failure",
        _ => return None,
    };
    Some(vec![("builtin_type", json!(builtin))])
}

pub(crate) fn subroutine_attributes(
    node: &ViewNode,
    context: &AnnotationContext<'_>,
) -> Attributes {
    let Some(first) = first_token(context.tree, node.syntax_index) else {
        return Vec::new();
    };
    let modifier = (first.saturating_add(1)..first.saturating_add(4))
        .filter(|index| {
            context
                .tree
                .tokens
                .kind(*index)
                .is_some_and(|kind| !kind.is_trivia())
        })
        .find_map(|index| context.tree.tokens.text(context.source.as_str(), index));
    match modifier.map(str::to_lowercase).as_deref() {
        Some("suspendible" | "suspendable") => vec![("suspendable", json!(true))],
        _ => Vec::new(),
    }
}

pub(crate) fn child_role(tree: &SyntaxTree, parent: usize, child: usize) -> Option<&'static str> {
    let parent_kind = tree.node(parent)?.kind;
    let child_kind = tree.node(child)?.kind;
    match parent_kind {
        NodeKind::TaskScope => Some(match child_kind {
            NodeKind::Body => "body",
            _ => "failure_binding",
        }),
        NodeKind::SelectStatement => Some("branch"),
        NodeKind::ReceiveBranch if child_kind == NodeKind::Body => Some("body"),
        NodeKind::ReceiveBranch => Some(receive_operand_role(tree, parent, child)),
        _ => None,
    }
}

fn receive_operand_role(tree: &SyntaxTree, parent: usize, child: usize) -> &'static str {
    let first_operand = tree
        .child_indices(parent)
        .iter()
        .copied()
        .find(|candidate| {
            tree.node(*candidate)
                .is_some_and(|node| node.kind != NodeKind::Body)
        });
    if first_operand == Some(child) {
        "binding"
    } else {
        "channel"
    }
}
