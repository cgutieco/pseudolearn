use crate::program_view::ViewNode;
use crate::program_view_tokens::{binary_identity, literal_attribute, unary_identity};
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_semantic::{HirExpression, SemanticOptions, analyze_for_service};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) type Attributes = Vec<(&'static str, Value)>;

pub(crate) struct AnnotationContext<'tree> {
    pub(crate) tree: &'tree SyntaxTree,
    pub(crate) source: &'tree SourceText,
    pub(crate) profile: Profile,
    pub(crate) strict: bool,
}

pub(crate) fn annotate(nodes: &mut [ViewNode], context: &AnnotationContext<'_>) {
    let builtins = builtin_calls(context);
    for node in nodes.iter_mut() {
        node.attributes = attributes_for(node, context, &builtins);
    }
}

fn attributes_for(
    node: &ViewNode,
    context: &AnnotationContext<'_>,
    builtins: &BTreeMap<(u32, u32), &'static str>,
) -> Attributes {
    let Some(kind) = context
        .tree
        .node(node.syntax_index)
        .map(|syntax| syntax.kind)
    else {
        return Vec::new();
    };
    match kind {
        NodeKind::Postfix => postfix_attributes(node, context.tree, builtins),
        NodeKind::Literal => literal_attribute(node, context).unwrap_or_default(),
        NodeKind::Type => primitive_attribute(node, context.tree).unwrap_or_default(),
        NodeKind::Output => without_newline_attribute(node, context.tree),
        NodeKind::Unary | NodeKind::Minus | NodeKind::Not => {
            unary_attribute(node, context.tree).unwrap_or_default()
        }
        other if is_binary(other) => binary_attribute(node, context.tree),
        _ => Vec::new(),
    }
}

fn postfix_attributes(
    node: &ViewNode,
    tree: &SyntaxTree,
    builtins: &BTreeMap<(u32, u32), &'static str>,
) -> Attributes {
    let mut attributes = Attributes::new();
    if let Some(builtin) = builtins.get(&(node.start_byte, node.end_byte)) {
        attributes.push(("builtin", json!(builtin)));
    }
    let first = first_token(tree, node.syntax_index).and_then(|token| tree.tokens.kind(token));
    if first == Some(TokenKind::Keyword(KeywordKind::SuperClass)) {
        attributes.push(("receiver", json!("super")));
        if names_constructor_after_super(tree, node) {
            attributes.push(("super_constructor", json!(true)));
        }
    }
    attributes
}

fn names_constructor_after_super(tree: &SyntaxTree, node: &ViewNode) -> bool {
    let Some(first) = first_token(tree, node.syntax_index) else {
        return false;
    };
    let mut significant = (first..)
        .skip(1)
        .map_while(|token| tree.tokens.kind(token))
        .filter(|kind| !kind.is_trivia());
    significant.nth(1) == Some(TokenKind::Keyword(KeywordKind::Constructor))
}

fn is_binary(kind: NodeKind) -> bool {
    matches!(
        kind,
        NodeKind::Addition
            | NodeKind::And
            | NodeKind::Conjunction
            | NodeKind::Disjunction
            | NodeKind::Divide
            | NodeKind::Equality
            | NodeKind::IntegerDivide
            | NodeKind::Modulo
            | NodeKind::Multiplication
            | NodeKind::Or
            | NodeKind::Ordering
            | NodeKind::Power
            | NodeKind::PowerExpression
    )
}

pub(crate) fn first_token(tree: &SyntaxTree, index: usize) -> Option<usize> {
    usize::try_from(tree.node(index)?.first_token).ok()
}

pub(crate) fn last_token(tree: &SyntaxTree, index: usize) -> Option<usize> {
    usize::try_from(*tree.ending_tokens.get(index)?).ok()
}

fn unary_attribute(node: &ViewNode, tree: &SyntaxTree) -> Option<Attributes> {
    let kind = tree.tokens.kind(first_token(tree, node.syntax_index)?)?;
    Some(vec![("operator", json!(unary_identity(kind)?))])
}

fn binary_attribute(node: &ViewNode, tree: &SyntaxTree) -> Attributes {
    let operators: Vec<&str> = tree
        .child_indices(node.syntax_index)
        .windows(2)
        .filter_map(|pair| operator_between(tree, pair))
        .collect();
    vec![("operators", json!(operators))]
}

fn operator_between(tree: &SyntaxTree, pair: &[usize]) -> Option<&'static str> {
    let from = last_token(tree, *pair.first()?)?.checked_add(1)?;
    let until = first_token(tree, *pair.get(1)?)?;
    (from..until).find_map(|token| tree.tokens.kind(token).and_then(binary_identity))
}

fn primitive_attribute(node: &ViewNode, tree: &SyntaxTree) -> Option<Attributes> {
    let kind = tree.tokens.kind(first_token(tree, node.syntax_index)?)?;
    let primitive = match kind {
        TokenKind::Keyword(KeywordKind::IntegerType) => "integer",
        TokenKind::Keyword(KeywordKind::RealType) => "real",
        TokenKind::Keyword(KeywordKind::StringType) => "string",
        TokenKind::Keyword(KeywordKind::CharacterType) => "character",
        TokenKind::Keyword(KeywordKind::BooleanType) => "boolean",
        _ => return None,
    };
    Some(vec![("primitive", json!(primitive))])
}

fn without_newline_attribute(node: &ViewNode, tree: &SyntaxTree) -> Attributes {
    let range = first_token(tree, node.syntax_index).zip(last_token(tree, node.syntax_index));
    let present = range.is_some_and(|(first, last)| {
        (first..=last).any(|token| {
            tree.tokens.kind(token) == Some(TokenKind::Keyword(KeywordKind::WithoutNewline))
        })
    });
    if present {
        vec![("without_newline", json!(true))]
    } else {
        Vec::new()
    }
}

fn builtin_calls(context: &AnnotationContext<'_>) -> BTreeMap<(u32, u32), &'static str> {
    let options = SemanticOptions {
        profile: context.profile,
        strict: context.strict,
    };
    let analysis = analyze_for_service(context.tree, context.source, options);
    let expressions = &analysis.module.expressions;
    expressions
        .kinds
        .iter()
        .zip(&expressions.spans)
        .filter_map(|(kind, span)| match kind {
            HirExpression::Builtin { function, .. } => {
                Some(((span.start, span.ending), function.as_str()))
            }
            _ => None,
        })
        .collect()
}
