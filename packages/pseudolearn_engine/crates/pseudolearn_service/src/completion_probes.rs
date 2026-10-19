use crate::navigation::Position;
use crate::positions::position_at;
use crate::spelling::{boolean_spelling, builtin_spelling, keyword_spelling};
use crate::symbol_index::SymbolIndex;
use pseudolearn_lexicon::{Profile, find_builtin};
use pseudolearn_semantic::{SemanticOptions, analyze_for_service};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind, parse_source};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ProbeCategory {
    Keyword,
    Identifier,
    StandardFunction,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct CompletionProbe {
    pub token_start: usize,
    pub token_chars: usize,
    pub expected: String,
    pub category: ProbeCategory,
}

pub fn completion_probes(text: &str, profile: Profile) -> Vec<CompletionProbe> {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, profile);
    let analysis = analyze_for_service(
        &tree,
        &source,
        SemanticOptions {
            profile,
            strict: false,
        },
    );
    let index = SymbolIndex::build(&tree, &analysis);
    (0..tree.tokens.token_count())
        .filter_map(|slot| probe_for_token(&tree, &index, (text, profile), slot))
        .collect()
}

fn probe_for_token(
    tree: &SyntaxTree,
    index: &SymbolIndex,
    document: (&str, Profile),
    slot: usize,
) -> Option<CompletionProbe> {
    let (text, profile) = document;
    let span = tree.tokens.span(slot)?;
    let word = tree.tokens.text(text, slot)?;
    let (expected, category) = match tree.tokens.kind(slot)? {
        TokenKind::Keyword(keyword) if is_word(word) => {
            (keyword_spelling(keyword, profile), ProbeCategory::Keyword)
        }
        TokenKind::BooleanLiteral(value) => {
            (boolean_spelling(value, profile), ProbeCategory::Keyword)
        }
        TokenKind::Identifier => identifier_probe(index, span.start, word, profile)?,
        _ => return None,
    };
    let token_chars = word.chars().count();
    (token_chars >= 3).then_some(CompletionProbe {
        token_start: usize::try_from(span.start).ok()?,
        token_chars,
        expected,
        category,
    })
}

fn identifier_probe(
    index: &SymbolIndex,
    start: u32,
    word: &str,
    profile: Profile,
) -> Option<(String, ProbeCategory)> {
    let entry = index.at_offset(usize::try_from(start).unwrap_or(0));
    if let Some(found) = entry.filter(|found| found.span.start == start) {
        return (!found.is_declaration).then(|| (word.to_owned(), ProbeCategory::Identifier));
    }
    find_builtin(word, profile).map(|builtin| {
        (
            builtin_spelling(builtin, profile),
            ProbeCategory::StandardFunction,
        )
    })
}

fn is_word(word: &str) -> bool {
    word.chars()
        .all(|glyph| glyph.is_alphabetic() || glyph == ' ')
}

pub fn truncated_query(
    text: &str,
    probe: &CompletionProbe,
    typed_chars: usize,
) -> (String, Position) {
    let head = text.get(..probe.token_start).unwrap_or("");
    let typed: String = text
        .get(probe.token_start..)
        .unwrap_or("")
        .chars()
        .take(typed_chars)
        .collect();
    let truncated = format!("{head}{typed}");
    let position = position_at(&truncated, truncated.len());
    (truncated, position)
}
