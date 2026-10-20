use crate::cursor_context::CodeToken;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{SyntaxTree, TokenKind};

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum ExpectedSlot {
    Unconstrained,
    Condition,
    Assignment { target: String },
    Argument { callee: String, index: usize },
}

pub fn expected_slot(tree: &SyntaxTree, text: &str, line: &[&CodeToken]) -> ExpectedSlot {
    if let Some((callee, index)) = argument_position(tree, text, line) {
        return ExpectedSlot::Argument { callee, index };
    }
    if line.last().is_some_and(|last| is_condition_lead(last.kind)) {
        return ExpectedSlot::Condition;
    }
    match assignment_target(tree, text, line) {
        Some(target) => ExpectedSlot::Assignment { target },
        None => ExpectedSlot::Unconstrained,
    }
}

fn is_condition_lead(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::LogicalAnd
            | TokenKind::LogicalOr
            | TokenKind::LogicalNot
            | TokenKind::Keyword(
                KeywordKind::IfKeyword
                    | KeywordKind::WhileKeyword
                    | KeywordKind::Until
                    | KeywordKind::Not
                    | KeywordKind::And
                    | KeywordKind::Or
            )
    )
}

fn argument_position(
    tree: &SyntaxTree,
    text: &str,
    line: &[&CodeToken],
) -> Option<(String, usize)> {
    let mut depth = 0usize;
    let mut commas = 0usize;
    for (slot, token) in line.iter().enumerate().rev() {
        match token.kind {
            TokenKind::RightParenthesis => depth = depth.saturating_add(1),
            TokenKind::Comma if depth == 0 => commas = commas.saturating_add(1),
            TokenKind::LeftParenthesis if depth == 0 => {
                return callee_before(tree, text, line, slot).map(|name| (name, commas));
            }
            TokenKind::LeftParenthesis => depth = depth.saturating_sub(1),
            _ => {}
        }
    }
    None
}

fn callee_before(
    tree: &SyntaxTree,
    text: &str,
    line: &[&CodeToken],
    parenthesis: usize,
) -> Option<String> {
    let before = line.get(parenthesis.checked_sub(1)?)?;
    (before.kind == TokenKind::Identifier)
        .then(|| tree.tokens.text(text, before.index).map(str::to_owned))
        .flatten()
}

fn assignment_target(tree: &SyntaxTree, text: &str, line: &[&CodeToken]) -> Option<String> {
    let arrow = line
        .iter()
        .position(|token| token.kind == TokenKind::Assignment)?;
    let target = line.get(arrow.checked_sub(1)?)?;
    (target.kind == TokenKind::Identifier)
        .then(|| tree.tokens.text(text, target.index).map(str::to_owned))
        .flatten()
}
