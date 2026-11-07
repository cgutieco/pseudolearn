use pseudolearn_semantic::{ServiceAnalysis, ServiceSymbolTarget};
use pseudolearn_syntax::{SyntaxTree, TokenKind};
use std::collections::{BTreeMap, BTreeSet};

type Tokens = BTreeMap<usize, &'static str>;

const CONSTRUCTOR_IDENTITIES: [&str; 3] = ["vectorType", "dictionaryType", "channelType"];

pub(crate) fn register(
    tree: &SyntaxTree,
    analysis: &ServiceAnalysis,
    candidates: &Tokens,
    output: &mut Tokens,
) {
    let user_starts: BTreeSet<u32> = analysis
        .occurrences
        .iter()
        .filter(|occurrence| !matches!(occurrence.target, ServiceSymbolTarget::Builtin(_)))
        .map(|occurrence| occurrence.span.start)
        .collect();
    for (token, identity) in candidates {
        let user_name = tree
            .tokens
            .span(*token)
            .is_some_and(|span| user_starts.contains(&span.start));
        if CONSTRUCTOR_IDENTITIES.contains(identity)
            && !user_name
            && neighbour(tree, *token, Direction::Following) == Some(TokenKind::LeftParenthesis)
            && neighbour(tree, *token, Direction::Preceding) != Some(TokenKind::Dot)
        {
            output.insert(*token, *identity);
        }
    }
}

enum Direction {
    Preceding,
    Following,
}

fn neighbour(tree: &SyntaxTree, token: usize, direction: Direction) -> Option<TokenKind> {
    let mut cursor = token;
    loop {
        cursor = match direction {
            Direction::Preceding => cursor.checked_sub(1)?,
            Direction::Following => cursor.checked_add(1)?,
        };
        let kind = tree.tokens.kind(cursor)?;
        if !kind.is_trivia() {
            return Some(kind);
        }
    }
}
