use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use std::collections::{BTreeMap, BTreeSet};

const BLOCK_NODES: &[NodeKind] = &[
    NodeKind::AlgorithmUnit,
    NodeKind::Subprogram,
    NodeKind::FunctionLiteral,
    NodeKind::ClassUnit,
    NodeKind::MethodMember,
    NodeKind::ConstructorMember,
    NodeKind::RecordUnit,
    NodeKind::EnumUnit,
    NodeKind::InterfaceUnit,
    NodeKind::VariantUnit,
    NodeKind::Conditional,
    NodeKind::WhileLoop,
    NodeKind::ForLoop,
    NodeKind::ForEachLoop,
    NodeKind::RepeatLoop,
    NodeKind::Switch,
    NodeKind::SelectStatement,
    NodeKind::TaskScope,
    NodeKind::DeferStatement,
];

const LABELED_NODES: &[NodeKind] = &[NodeKind::Switch, NodeKind::SelectStatement];

#[derive(Default)]
pub struct TreeBlocks {
    pub openers: BTreeMap<u32, bool>,
    pub closers: BTreeSet<u32>,
}

impl TreeBlocks {
    pub fn build(tree: &SyntaxTree) -> Self {
        let mut blocks = Self::default();
        for (index, node) in tree.nodes.iter().enumerate() {
            if !BLOCK_NODES.contains(&node.kind) {
                continue;
            }
            let Some(closer) = closing_token(tree, index) else {
                continue;
            };
            blocks
                .openers
                .insert(node.first_token, LABELED_NODES.contains(&node.kind));
            blocks.closers.insert(closer);
        }
        blocks
    }
}

fn closing_token(tree: &SyntaxTree, index: usize) -> Option<u32> {
    let node = tree.nodes.get(index)?;
    let ending = *tree.ending_tokens.get(index)?;
    if node.kind != NodeKind::RepeatLoop {
        return Some(ending);
    }
    (node.first_token..=ending).rev().find(|token| {
        usize::try_from(*token)
            .ok()
            .and_then(|token| tree.tokens.kind(token))
            == Some(TokenKind::Keyword(KeywordKind::Until))
    })
}
