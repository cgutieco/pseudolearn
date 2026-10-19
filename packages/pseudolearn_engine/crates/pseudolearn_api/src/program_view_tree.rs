use crate::program_view::ViewNode;
use crate::program_view_kind::{ViewKind, classify, syntax_name};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};

struct PendingViewNode {
    syntax_index: usize,
    view_parent: Option<usize>,
    view_parent_syntax: Option<usize>,
    syntax_parent: Option<NodeKind>,
}

struct NodeCollector<'tree> {
    tree: &'tree SyntaxTree,
    source: &'tree SourceText,
    nodes: Vec<ViewNode>,
}

pub(crate) fn collect_nodes(tree: &SyntaxTree, source: &SourceText) -> Vec<ViewNode> {
    let Some(root) = tree.nodes.len().checked_sub(1) else {
        return Vec::new();
    };
    NodeCollector {
        tree,
        source,
        nodes: Vec::new(),
    }
    .collect(root)
}

impl NodeCollector<'_> {
    fn collect(mut self, root: usize) -> Vec<ViewNode> {
        let mut pending = vec![PendingViewNode {
            syntax_index: root,
            view_parent: None,
            view_parent_syntax: None,
            syntax_parent: None,
        }];
        while let Some(pending_node) = pending.pop() {
            self.collect_node(pending_node, &mut pending);
        }
        self.nodes
    }

    fn collect_node(&mut self, pending_node: PendingViewNode, pending: &mut Vec<PendingViewNode>) {
        let Some(syntax_node) = self.tree.node(pending_node.syntax_index) else {
            return;
        };
        let syntax_kind = syntax_node.kind;
        let next_parent = self.append_view_node(&pending_node, syntax_kind);
        self.push_children(&pending_node, next_parent, pending);
    }

    fn append_view_node(
        &mut self,
        pending_node: &PendingViewNode,
        syntax_kind: NodeKind,
    ) -> Option<usize> {
        let index = pending_node.syntax_index;
        let Some((kind, syntax_name, span)) =
            view_node_parts(self.tree, index, syntax_kind, pending_node.syntax_parent)
        else {
            return pending_node.view_parent;
        };
        let ordinal = self.nodes.len();
        self.nodes.push(ViewNode {
            syntax_index: index,
            kind,
            syntax_kind: syntax_name,
            start_byte: span.start,
            end_byte: span.ending,
            start: self.source.line_and_column(span.start),
            end: self.source.line_and_column(span.ending),
            parent: pending_node.view_parent,
            children: Vec::new(),
            child_roles: Vec::new(),
            dimensions: parameter_dimensions(self.tree, index),
        });
        self.link_parent(ordinal, pending_node);
        Some(ordinal)
    }

    fn link_parent(&mut self, ordinal: usize, pending_node: &PendingViewNode) {
        let Some(parent) = pending_node.view_parent else {
            return;
        };
        let role = pending_node
            .view_parent_syntax
            .map_or("child", |syntax_parent| {
                child_role(self.tree, syntax_parent, pending_node.syntax_index)
            });
        if let Some(owner) = self.nodes.get_mut(parent) {
            owner.children.push(ordinal);
            owner.child_roles.push(role);
        }
    }

    fn push_children(
        &self,
        pending_node: &PendingViewNode,
        view_parent: Option<usize>,
        pending: &mut Vec<PendingViewNode>,
    ) {
        let Some(syntax_kind) = self
            .tree
            .node(pending_node.syntax_index)
            .map(|node| node.kind)
        else {
            return;
        };
        let view_parent_syntax =
            view_parent.and_then(|parent| self.nodes.get(parent).map(|node| node.syntax_index));
        for child in self
            .tree
            .child_indices(pending_node.syntax_index)
            .iter()
            .rev()
        {
            pending.push(PendingViewNode {
                syntax_index: *child,
                view_parent,
                view_parent_syntax,
                syntax_parent: Some(syntax_kind),
            });
        }
    }
}

fn view_node_parts(
    tree: &SyntaxTree,
    index: usize,
    syntax_kind: NodeKind,
    syntax_parent: Option<NodeKind>,
) -> Option<(ViewKind, &'static str, Span)> {
    Some((
        classify(syntax_kind, syntax_parent)?,
        syntax_name(syntax_kind)?,
        tree.span_for_node(index)?,
    ))
}

fn parameter_dimensions(tree: &SyntaxTree, index: usize) -> Option<usize> {
    if tree.node(index)?.kind != NodeKind::Parameter {
        return None;
    }
    let start = usize::try_from(tree.node(index)?.first_token).ok()?;
    let end = usize::try_from(*tree.ending_tokens.get(index)?).ok()?;
    let mut in_dimensions = false;
    let mut count = 0_usize;
    for token in start..=end {
        match tree.tokens.kind(token) {
            Some(TokenKind::LeftBracket) => {
                in_dimensions = true;
                count = 1;
            }
            Some(TokenKind::Comma) if in_dimensions => count = count.saturating_add(1),
            Some(TokenKind::RightBracket) if in_dimensions => return Some(count),
            _ => {}
        }
    }
    Some(0)
}

fn child_role(tree: &SyntaxTree, parent: usize, child: usize) -> &'static str {
    let (Some(parent_node), Some(child_node)) = (tree.node(parent), tree.node(child)) else {
        return "child";
    };
    match parent_node.kind {
        NodeKind::Conditional => conditional_role(tree, parent, child_node),
        NodeKind::WhileLoop | NodeKind::RepeatLoop | NodeKind::ForLoop => {
            loop_role(parent_node.kind, child_node.kind)
        }
        NodeKind::Switch => switch_role(child_node.kind),
        NodeKind::AlgorithmUnit | NodeKind::Subroutine => unit_role(child_node.kind),
        NodeKind::ClassUnit => class_role(child_node.kind),
        NodeKind::MethodMember | NodeKind::ConstructorMember => member_role(child_node.kind),
        NodeKind::Parameters => "parameter",
        NodeKind::Statement => statement_role(child_node.kind),
        NodeKind::Body => "statement",
        NodeKind::DefaultCase => default_case_role(child_node.kind),
        _ => "child",
    }
}

fn conditional_role(
    tree: &SyntaxTree,
    parent: usize,
    child: &pseudolearn_syntax::SyntaxNode,
) -> &'static str {
    match child.kind {
        NodeKind::Body if token_after_else(tree, parent, child.first_token) => "else_body",
        NodeKind::Body => "then_body",
        _ => "condition",
    }
}

fn loop_role(parent: NodeKind, child: NodeKind) -> &'static str {
    if child == NodeKind::Body {
        return "body";
    }
    if parent == NodeKind::ForLoop {
        return "loop_header";
    }
    "condition"
}

fn switch_role(child: NodeKind) -> &'static str {
    match child {
        NodeKind::DefaultCase => "default_case",
        NodeKind::Statement => "case",
        _ => "selector",
    }
}

fn unit_role(child: NodeKind) -> &'static str {
    if child == NodeKind::Body {
        "body"
    } else {
        "signature"
    }
}

fn class_role(child: NodeKind) -> &'static str {
    match child {
        NodeKind::FieldDeclaration | NodeKind::MethodMember | NodeKind::ConstructorMember => {
            "member"
        }
        _ => "name_or_base",
    }
}

fn member_role(child: NodeKind) -> &'static str {
    match child {
        NodeKind::Body => "body",
        NodeKind::Parameters => "parameters",
        _ => "signature",
    }
}

fn statement_role(child: NodeKind) -> &'static str {
    match child {
        NodeKind::Labels => "labels",
        NodeKind::Body => "body",
        _ => "statement",
    }
}

fn default_case_role(child: NodeKind) -> &'static str {
    if child == NodeKind::Body {
        "body"
    } else {
        "statement"
    }
}

fn token_after_else(tree: &SyntaxTree, parent: usize, child_token: u32) -> bool {
    let Some((start, end, child)) = token_range(tree, parent, child_token) else {
        return false;
    };
    (start..child.min(end))
        .any(|token| tree.tokens.kind(token) == Some(TokenKind::Keyword(KeywordKind::ElseKeyword)))
}

fn token_range(
    tree: &SyntaxTree,
    parent: usize,
    child_token: u32,
) -> Option<(usize, usize, usize)> {
    let parent_node = tree.node(parent)?;
    let start = usize::try_from(parent_node.first_token).ok()?;
    let end = usize::try_from(*tree.ending_tokens.get(parent)?).ok()?;
    let child = usize::try_from(child_token).ok()?;
    Some((start, end, child))
}
