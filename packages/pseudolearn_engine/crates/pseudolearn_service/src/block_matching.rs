use crate::block_layout::{is_closer, is_opener};
use crate::completion_keywords::closing_keyword;
use crate::typing_lines::line_start;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{SyntaxTree, TokenKind};
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct OpenerFact {
    pub kind: KeywordKind,
    pub line_start: usize,
    pub closed: bool,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Anchor {
    pub opener_token: usize,
    pub extra_depth: usize,
}

#[derive(Default)]
pub struct BlockMap {
    openers: BTreeMap<usize, OpenerFact>,
    anchors: BTreeMap<usize, Anchor>,
    closers: BTreeMap<usize, usize>,
}

impl BlockMap {
    pub fn opener_at(&self, token: usize) -> Option<&OpenerFact> {
        self.openers.get(&token)
    }

    pub fn anchor_of(&self, token: usize) -> Option<(&OpenerFact, usize)> {
        let anchor = self.anchors.get(&token)?;
        self.openers
            .get(&anchor.opener_token)
            .map(|fact| (fact, anchor.extra_depth))
    }

    pub fn closing_token(&self, opener: usize) -> Option<usize> {
        self.closers.get(&opener).copied()
    }

    pub fn opening_token(&self, closer: usize) -> Option<usize> {
        self.anchors.get(&closer).map(|anchor| anchor.opener_token)
    }
}

pub fn build_block_map(tree: &SyntaxTree, text: &str) -> BlockMap {
    let mut map = BlockMap::default();
    let mut stack: Vec<usize> = Vec::new();
    for index in 0..tree.tokens.token_count() {
        let (Some(TokenKind::Keyword(kind)), Some(span)) =
            (tree.tokens.kind(index), tree.tokens.span(index))
        else {
            continue;
        };
        let start = usize::try_from(span.start).unwrap_or(usize::MAX);
        if is_opener(kind) {
            map.openers.insert(
                index,
                OpenerFact {
                    kind,
                    line_start: line_start(text, start),
                    closed: false,
                },
            );
            stack.push(index);
        } else if is_closer(kind) {
            close_block(&mut map, &mut stack, index, kind);
        } else {
            anchor_branch(&mut map, &stack, index, kind);
        }
    }
    map
}

pub fn openers_before(tree: &SyntaxTree, limit: usize) -> Vec<usize> {
    let mut stack = Vec::new();
    for index in 0..tree.tokens.token_count() {
        let (Some(TokenKind::Keyword(kind)), Some(span)) =
            (tree.tokens.kind(index), tree.tokens.span(index))
        else {
            continue;
        };
        if usize::try_from(span.ending).unwrap_or(usize::MAX) > limit {
            break;
        }
        if is_opener(kind) {
            stack.push(index);
        } else if is_closer(kind) {
            truncate_matching(&mut stack, tree, kind);
        }
    }
    stack
}

fn truncate_matching(stack: &mut Vec<usize>, tree: &SyntaxTree, kind: KeywordKind) {
    let matching = stack.iter().rposition(|opener| {
        matches!(tree.tokens.kind(*opener), Some(TokenKind::Keyword(opening))
            if closing_keyword(opening) == kind)
    });
    if let Some(depth) = matching {
        stack.truncate(depth);
    }
}

fn close_block(map: &mut BlockMap, stack: &mut Vec<usize>, token: usize, closer: KeywordKind) {
    let matching = stack.iter().rposition(|opener| {
        map.openers
            .get(opener)
            .is_some_and(|fact| closing_keyword(fact.kind) == closer)
    });
    let Some(depth) = matching else {
        return;
    };
    let Some(opener_token) = stack.get(depth).copied() else {
        return;
    };
    stack.truncate(depth);
    if let Some(fact) = map.openers.get_mut(&opener_token) {
        fact.closed = true;
    }
    map.closers.insert(opener_token, token);
    map.anchors.insert(
        token,
        Anchor {
            opener_token,
            extra_depth: 0,
        },
    );
}

fn anchor_branch(map: &mut BlockMap, stack: &[usize], token: usize, kind: KeywordKind) {
    let (wanted, extra_depth) = match kind {
        KeywordKind::ElseKeyword => (KeywordKind::IfKeyword, 0),
        KeywordKind::DefaultCase => (KeywordKind::SwitchKeyword, 1),
        _ => return,
    };
    let Some(opener_token) = stack.last().copied() else {
        return;
    };
    if map
        .openers
        .get(&opener_token)
        .is_some_and(|fact| fact.kind == wanted)
    {
        map.anchors.insert(
            token,
            Anchor {
                opener_token,
                extra_depth,
            },
        );
    }
}
