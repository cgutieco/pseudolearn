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

#[derive(Default)]
pub struct BlockLayout {
    stack: Vec<OpenBlock>,
    case_starts: BTreeSet<u32>,
}

impl BlockLayout {
    pub fn new(tree: &SyntaxTree) -> Self {
        let case_starts = tree
            .nodes
            .iter()
            .filter(|node| matches!(node.kind, NodeKind::Labels | NodeKind::DefaultCase))
            .map(|node| node.first_token)
            .collect();
        Self {
            stack: Vec::new(),
            case_starts,
        }
    }

    pub fn role_of(&self, tree: &SyntaxTree, first_token: usize) -> LineRole {
        let start = u32::try_from(first_token).unwrap_or(u32::MAX);
        if self.case_starts.contains(&start) {
            return LineRole::CaseLabel;
        }
        match tree.tokens.kind(first_token) {
            Some(TokenKind::Keyword(kind)) if is_closer(kind) => LineRole::Closer,
            Some(TokenKind::Keyword(KeywordKind::ElseKeyword)) => LineRole::Else,
            _ => LineRole::Plain,
        }
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

    pub fn apply_keyword(&mut self, kind: KeywordKind) {
        if is_opener(kind) {
            self.stack.push(OpenBlock {
                is_switch: kind == KeywordKind::SwitchKeyword,
                in_case: false,
            });
        } else if is_closer(kind) {
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
