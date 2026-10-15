use crate::tokens::{TokenKind, Tokens};
use crate::tree::SyntaxTree;
use pseudolearn_source::SourceText;

pub fn reprint_lossless(source: &SourceText, tokens: &Tokens) -> String {
    let mut outcome = String::new();
    if source.bom_prefix_length() > 0 {
        outcome.push('\u{FEFF}');
    }
    let total_tokens = tokens.token_count();
    for token_index in 0..total_tokens {
        if tokens.kind(token_index) == Some(TokenKind::EndOfFile) {
            continue;
        }
        if let Some(token_slice) = tokens.text(source.as_str(), token_index) {
            outcome.push_str(token_slice);
        }
    }
    outcome
}

pub fn reprint(source: &SourceText, tree: &SyntaxTree) -> String {
    reprint_lossless(source, &tree.tokens)
}

pub fn verify_reprint_identity(source: &SourceText, tree: &SyntaxTree) -> bool {
    let reconstructed = reprint(source, tree);
    reconstructed == source.as_str()
}
