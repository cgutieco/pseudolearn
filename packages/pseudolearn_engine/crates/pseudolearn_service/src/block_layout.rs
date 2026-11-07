use crate::tree_blocks::TreeBlocks;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use std::collections::BTreeSet;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct OpenBlock {
    is_switch: bool,
    in_case: bool,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum LineRole {
    Plain,
    Closer,
    Else,
    CaseLabel,
}

pub struct BlockLayout {
    stack: Vec<OpenBlock>,
    case_starts: BTreeSet<u32>,
    blocks: TreeBlocks,
}

impl BlockLayout {
    pub fn new(tree: &SyntaxTree) -> Self {
        Self {
            stack: Vec::new(),
            case_starts: starts(
                tree,
                &[
                    NodeKind::Labels,
                    NodeKind::DefaultCase,
                    NodeKind::ReceiveBranch,
                ],
            ),
            blocks: TreeBlocks::build(tree),
        }
    }

    pub fn role_of(&self, tree: &SyntaxTree, first_token: usize) -> LineRole {
        let start = u32::try_from(first_token).unwrap_or(u32::MAX);
        if self.blocks.closers.contains(&start) {
            return LineRole::Closer;
        }
        if self.case_starts.contains(&start) {
            return LineRole::CaseLabel;
        }
        match tree.tokens.kind(first_token) {
            Some(TokenKind::Keyword(KeywordKind::ElseKeyword)) => LineRole::Else,
            _ => LineRole::Plain,
        }
    }

    pub fn leaves_block_open(&self, tokens: &[usize]) -> bool {
        let mut balance = 0_usize;
        for slot in tokens.iter().filter_map(|token| u32::try_from(*token).ok()) {
            if self.blocks.openers.contains_key(&slot) {
                balance = balance.saturating_add(1);
            } else if self.blocks.closers.contains(&slot) {
                balance = balance.saturating_sub(1);
            }
        }
        balance > 0
    }

    pub fn depth(&self) -> usize {
        self.stack
            .iter()
            .map(|block| {
                if block.is_switch && block.in_case {
                    2
                } else {
                    1
                }
            })
            .sum()
    }

    pub fn open_depth(&self) -> usize {
        self.stack.len()
    }

    pub fn indent_for(&mut self, role: LineRole) -> usize {
        match role {
            LineRole::Plain | LineRole::Closer => self.depth(),
            LineRole::Else => self.depth().saturating_sub(1),
            LineRole::CaseLabel => {
                let Some(block) = self.stack.last_mut().filter(|block| block.is_switch) else {
                    return self.depth();
                };
                block.in_case = false;
                let depth = self.depth();
                if let Some(settled) = self.stack.last_mut() {
                    settled.in_case = true;
                }
                depth
            }
        }
    }

    pub fn apply_token(&mut self, token: usize) {
        let slot = u32::try_from(token).unwrap_or(u32::MAX);
        if let Some(is_switch) = self.blocks.openers.get(&slot) {
            self.stack.push(OpenBlock {
                is_switch: *is_switch,
                in_case: false,
            });
        } else if self.blocks.closers.contains(&slot) {
            self.stack.pop();
        }
    }

    pub fn pop_leading_closer(&mut self) {
        self.stack.pop();
    }
}

pub fn is_opener(kind: KeywordKind) -> bool {
    matches!(
        kind,
        KeywordKind::Algorithm
            | KeywordKind::Subroutine
            | KeywordKind::ClassKeyword
            | KeywordKind::Method
            | KeywordKind::IfKeyword
            | KeywordKind::WhileKeyword
            | KeywordKind::ForKeyword
            | KeywordKind::Repeat
            | KeywordKind::SwitchKeyword
    )
}

pub fn is_closer(kind: KeywordKind) -> bool {
    matches!(
        kind,
        KeywordKind::EndAlgorithm
            | KeywordKind::EndSubroutine
            | KeywordKind::EndClass
            | KeywordKind::EndMethod
            | KeywordKind::EndIf
            | KeywordKind::EndWhile
            | KeywordKind::EndFor
            | KeywordKind::EndSwitch
            | KeywordKind::Until
    )
}

fn starts(tree: &SyntaxTree, kinds: &[NodeKind]) -> BTreeSet<u32> {
    tree.nodes
        .iter()
        .filter(|node| kinds.contains(&node.kind))
        .map(|node| node.first_token)
        .collect()
}
