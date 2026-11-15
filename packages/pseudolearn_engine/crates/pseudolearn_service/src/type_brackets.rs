use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use std::collections::BTreeSet;

const TYPE_NODES: &[NodeKind] = &[
    NodeKind::Type,
    NodeKind::TypeArguments,
    NodeKind::TypeParameters,
];

pub fn angle_brackets(tree: &SyntaxTree) -> BTreeSet<usize> {
    let mut brackets = BTreeSet::new();
    for (index, node) in tree.nodes.iter().enumerate() {
        if !TYPE_NODES.contains(&node.kind) {
            continue;
        }
        let Some(ending) = tree.ending_tokens.get(index) else {
            continue;
        };
        let (Ok(first), Ok(ending)) = (usize::try_from(node.first_token), usize::try_from(*ending))
        else {
            continue;
        };
        brackets.extend((first..=ending).filter(|token| {
            matches!(
                tree.tokens.kind(*token),
                Some(TokenKind::Less | TokenKind::Greater)
            )
        }));
    }
    brackets
}
