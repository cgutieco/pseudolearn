use crate::completion_members::member_candidates;
use crate::completion_pool::CandidatePool;
use crate::completion_scope::SourceScope;
use crate::completion_sources::{expression_candidates, statement_candidates, type_candidates};
pub use crate::completion_types::{CompletionEntry, CompletionKind, CompletionQuery};
use crate::cursor_context::{CursorKind, analyze_cursor};
use crate::positions::offset_at;
use crate::spelling::keyword_spelling;
use pseudolearn_lexicon::{KeywordKind, Profile};

pub fn complete_at_position(query: &CompletionQuery) -> Vec<CompletionEntry> {
    let offset = offset_at(query.source.as_str(), query.position);
    let context = analyze_cursor(query.tree, query.source, offset);
    if context.kind == CursorKind::Inert {
        return Vec::new();
    }
    let scope = SourceScope {
        analysis: query.analysis,
        context: &context,
        profile: query.profile,
        offset,
    };
    let mut pool = CandidatePool::default();
    fill_pool(&scope, &mut pool);
    pool.finish(&context.prefix, query.profile)
}

fn fill_pool(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    match &scope.context.kind {
        CursorKind::Member { receiver } => member_candidates(scope, receiver, pool),
        CursorKind::TypeSlot => type_candidates(scope, pool),
        CursorKind::StatementStart => {
            statement_candidates(scope, pool);
            bilingual_hints(scope, pool);
        }
        CursorKind::Expression => {
            expression_candidates(scope, pool);
            bilingual_hints(scope, pool);
        }
        CursorKind::Inert => {}
    }
}

fn bilingual_hints(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    let prefix = &scope.context.prefix;
    if prefix.chars().count() < 3 {
        return;
    }
    let foreign_profile = match scope.profile {
        Profile::Spanish => Profile::English,
        Profile::English => Profile::Spanish,
    };
    let typed_native = scope.profile.fold_word(prefix);
    let typed_foreign = foreign_profile.fold_word(prefix);
    for kind in KeywordKind::all() {
        let Some(foreign) = kind
            .lexeme(foreign_profile)
            .filter(|word| is_wordlike(word))
        else {
            continue;
        };
        let native = keyword_spelling(*kind, scope.profile);
        let direct = scope.profile.fold_word(&native).starts_with(&typed_native);
        if direct
            || !foreign_profile
                .fold_word(foreign)
                .starts_with(&typed_foreign)
        {
            continue;
        }
        pool.add_hint(5, hint_entry(native, foreign, scope.profile));
    }
}

fn is_wordlike(word: &str) -> bool {
    word.chars()
        .all(|glyph| glyph.is_alphabetic() || glyph == ' ')
}

fn hint_entry(native: String, foreign: &str, profile: Profile) -> CompletionEntry {
    CompletionEntry {
        label: native,
        kind: CompletionKind::Keyword,
        detail: Some(hint_detail(profile, foreign)),
        insert_text: None,
        bilingual_origin: Some(foreign.to_owned()),
    }
}

fn hint_detail(profile: Profile, foreign: &str) -> String {
    match profile {
        Profile::Spanish => format!("Equivalente de {foreign}"),
        Profile::English => format!("Equivalent of {foreign}"),
    }
}
