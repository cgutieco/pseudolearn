use crate::completion_pool::{CandidatePool, plain_entry};
use crate::completion_scope::SourceScope;
use crate::completion_templates::{construction_for, get_template};
use crate::completion_types::{CompletionAction, CompletionEntry, CompletionKind};
use crate::spelling::keyword_spelling;
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_syntax::TokenKind;

pub fn keyword_entry(kind: KeywordKind, profile: Profile) -> CompletionEntry {
    let label = keyword_spelling(kind, profile);
    let construction = construction_for(kind);
    match construction.and_then(|name| get_template(name, profile).map(|text| (name, text))) {
        Some((name, template)) => CompletionEntry {
            label,
            kind: CompletionKind::Snippet,
            detail: Some(match profile {
                Profile::Spanish => "Estructura".to_owned(),
                Profile::English => "Structure".to_owned(),
            }),
            insert_text: Some(template),
            bilingual_origin: None,
            detail_key: Some("structure".to_owned()),
            detail_arguments: Vec::new(),
            inline: false,
            action: CompletionAction::Template {
                construction: name.to_owned(),
            },
        },
        None => plain_entry(label, CompletionKind::Keyword, None),
    }
}

pub fn closing_keyword(opener: KeywordKind) -> KeywordKind {
    match opener {
        KeywordKind::Algorithm => KeywordKind::EndAlgorithm,
        KeywordKind::Subroutine => KeywordKind::EndSubroutine,
        KeywordKind::ClassKeyword => KeywordKind::EndClass,
        KeywordKind::Method => KeywordKind::EndMethod,
        KeywordKind::IfKeyword => KeywordKind::EndIf,
        KeywordKind::WhileKeyword => KeywordKind::EndWhile,
        KeywordKind::ForKeyword => KeywordKind::EndFor,
        KeywordKind::SwitchKeyword => KeywordKind::EndSwitch,
        _ => KeywordKind::Until,
    }
}

pub fn structure_keywords(innermost: Option<&KeywordKind>) -> &'static [KeywordKind] {
    match innermost {
        None => &[
            KeywordKind::Algorithm,
            KeywordKind::Subroutine,
            KeywordKind::ClassKeyword,
        ],
        Some(KeywordKind::ClassKeyword) => &[
            KeywordKind::Declare,
            KeywordKind::Dimension,
            KeywordKind::Method,
            KeywordKind::PublicVisibility,
            KeywordKind::PrivateVisibility,
        ],
        Some(_) => &[
            KeywordKind::Declare,
            KeywordKind::Dimension,
            KeywordKind::Write,
            KeywordKind::Read,
            KeywordKind::IfKeyword,
            KeywordKind::WhileKeyword,
            KeywordKind::ForKeyword,
            KeywordKind::Repeat,
            KeywordKind::SwitchKeyword,
        ],
    }
}

fn expected_follow_ups(tokens: &[TokenKind]) -> Vec<KeywordKind> {
    let has = |kind: KeywordKind| tokens.contains(&TokenKind::Keyword(kind));
    let Some(TokenKind::Keyword(first)) = tokens.first().copied() else {
        return Vec::new();
    };
    match first {
        KeywordKind::IfKeyword if !has(KeywordKind::Then) => vec![KeywordKind::Then],
        KeywordKind::WhileKeyword | KeywordKind::SwitchKeyword if !has(KeywordKind::DoKeyword) => {
            vec![KeywordKind::DoKeyword]
        }
        KeywordKind::ForKeyword if !has(KeywordKind::To) => vec![KeywordKind::To],
        KeywordKind::ForKeyword if !has(KeywordKind::DoKeyword) => {
            vec![KeywordKind::Step, KeywordKind::DoKeyword]
        }
        KeywordKind::Declare if !has(KeywordKind::TypeConnector) => {
            vec![KeywordKind::TypeConnector]
        }
        KeywordKind::Write if !has(KeywordKind::WithoutNewline) => {
            vec![KeywordKind::WithoutNewline]
        }
        _ => Vec::new(),
    }
}

pub fn follow_up_keywords(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for kind in expected_follow_ups(&scope.context.line_tokens) {
        pool.add(1, keyword_entry(kind, scope.profile));
    }
}
