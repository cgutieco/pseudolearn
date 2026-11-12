use pseudolearn_lexicon::{BuiltinKind, KeywordKind, Profile};
use pseudolearn_syntax::{SyntaxTree, TokenKind};

pub fn keyword_spelling(kind: KeywordKind, profile: Profile) -> String {
    canonical_word(kind.lexeme(profile).unwrap_or(""), profile)
}

pub fn canonical_word(lexeme: &str, profile: Profile) -> String {
    match profile {
        Profile::Spanish => lexeme.to_owned(),
        Profile::English => capitalize_words(lexeme),
    }
}

pub(crate) fn positioned_keyword_spelling(
    tree: &SyntaxTree,
    index: usize,
    kind: KeywordKind,
    profile: Profile,
) -> String {
    match kind.lexeme(profile) {
        Some(lexeme) if crate::identifier_roles::is_member_access(tree, index) => lexeme.to_owned(),
        _ => keyword_spelling(kind, profile),
    }
}

pub(crate) fn contextual_word_spelling(
    tree: &SyntaxTree,
    index: usize,
    identity: &str,
    profile: Profile,
) -> Option<String> {
    let lexeme = pseudolearn_syntax::contextual_spelling(identity, profile.as_str())?;
    if crate::identifier_roles::is_member_access(tree, index) || precedes_call(tree, index) {
        return Some(lexeme.to_owned());
    }
    Some(canonical_word(lexeme, profile))
}

fn precedes_call(tree: &SyntaxTree, index: usize) -> bool {
    let mut cursor = index;
    while let Some(kind) = tree.tokens.kind(cursor.saturating_add(1)) {
        cursor = cursor.saturating_add(1);
        if kind != TokenKind::Whitespace {
            return kind == TokenKind::LeftParenthesis;
        }
    }
    false
}

pub fn boolean_spelling(value: bool, profile: Profile) -> String {
    let kind = if value {
        KeywordKind::BooleanTrue
    } else {
        KeywordKind::BooleanFalse
    };
    keyword_spelling(kind, profile)
}

pub fn builtin_spelling(kind: BuiltinKind, profile: Profile) -> String {
    kind.lexeme(profile).unwrap_or("").to_owned()
}

fn capitalize_words(lexeme: &str) -> String {
    let mut spelled = String::with_capacity(lexeme.len());
    let mut at_word_start = true;
    for character in lexeme.chars() {
        if at_word_start {
            spelled.extend(character.to_uppercase());
        } else {
            spelled.push(character);
        }
        at_word_start = character == ' ';
    }
    spelled
}
