use crate::program_view::ViewNode;
use crate::program_view_annotations::Attributes;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use serde_json::json;

pub(crate) fn attributes(node: &ViewNode, tree: &SyntaxTree) -> Attributes {
    let Some(syntax) = tree.node(node.syntax_index) else {
        return Vec::new();
    };
    let token = usize::try_from(syntax.first_token)
        .ok()
        .and_then(|index| tree.tokens.kind(index));
    if syntax.kind == NodeKind::Declaration {
        return binding(node, tree);
    }
    match token {
        Some(TokenKind::Keyword(KeywordKind::OptionalType)) => {
            vec![("type_constructor", json!("optional"))]
        }
        Some(TokenKind::Keyword(KeywordKind::ResultType)) => {
            vec![("type_constructor", json!("result"))]
        }
        Some(TokenKind::Keyword(KeywordKind::SomeVariant)) => vec![("variant", json!("some"))],
        Some(TokenKind::Keyword(KeywordKind::NoneVariant)) => vec![("variant", json!("none"))],
        Some(TokenKind::Keyword(KeywordKind::SuccessVariant)) => {
            vec![("variant", json!("success"))]
        }
        Some(TokenKind::Keyword(KeywordKind::ErrorVariant)) => vec![("variant", json!("error"))],
        Some(TokenKind::Keyword(KeywordKind::PropagateKeyword)) => {
            vec![("propagates", json!(true))]
        }
        Some(TokenKind::Keyword(KeywordKind::DiscardKeyword)) => vec![("discard", json!(true))],
        _ => Vec::new(),
    }
}

fn binding(node: &ViewNode, tree: &SyntaxTree) -> Attributes {
    let Some(first) = tree
        .node(node.syntax_index)
        .and_then(|node| usize::try_from(node.first_token).ok())
    else {
        return Vec::new();
    };
    let Some(last) = tree
        .ending_tokens
        .get(node.syntax_index)
        .and_then(|last| usize::try_from(*last).ok())
    else {
        return Vec::new();
    };
    let initialized =
        (first..=last).any(|index| tree.tokens.kind(index) == Some(TokenKind::Assignment));
    if !initialized {
        return Vec::new();
    }
    let mutable = (first..=last).any(|index| {
        tree.tokens.kind(index) == Some(TokenKind::Keyword(KeywordKind::MutableKeyword))
    });
    vec![("mutable", json!(mutable)), ("initialized", json!(true))]
}

pub(crate) fn child_role(tree: &SyntaxTree, parent: usize, child: usize) -> &'static str {
    let kind = tree.node(child).map(|node| node.kind);
    match tree.node(parent).map(|node| node.kind) {
        Some(NodeKind::Declaration) if kind == Some(NodeKind::Type) => "type",
        Some(NodeKind::Declaration) => {
            let declared_type = tree.child_indices(parent).iter().copied().find(|index| {
                tree.node(*index)
                    .is_some_and(|node| node.kind == NodeKind::Type)
            });
            if declared_type.is_some_and(|declared_type| child > declared_type) {
                "initializer"
            } else {
                "binding"
            }
        }
        Some(NodeKind::Type) => "type_argument",
        Some(NodeKind::VariantPattern) => "binding",
        _ => "payload",
    }
}

pub(crate) fn node_kind(
    original: crate::program_view_kind::ViewKind,
    tree: &SyntaxTree,
    relation: (Option<usize>, usize),
) -> crate::program_view_kind::ViewKind {
    let Some(parent) = relation.0 else {
        return original;
    };
    if tree
        .node(parent)
        .is_some_and(|node| node.kind == NodeKind::Declaration)
        && tree
            .node(relation.1)
            .is_some_and(|node| node.kind == NodeKind::Identifier)
        && child_role(tree, parent, relation.1) == "initializer"
    {
        crate::program_view_kind::ViewKind::Expression
    } else {
        original
    }
}
