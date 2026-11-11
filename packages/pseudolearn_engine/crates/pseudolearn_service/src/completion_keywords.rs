use crate::completion_pool::{CandidatePool, identified, plain_entry};
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
            identity: Some(kind.as_str().to_owned()),
            action: CompletionAction::Template {
                construction: name.to_owned(),
            },
        },
        None => identified(
            plain_entry(label, CompletionKind::Keyword, None),
            kind.as_str(),
        ),
    }
}

pub fn closing_keyword(opener: KeywordKind) -> Option<KeywordKind> {
    match opener {
        KeywordKind::Algorithm => Some(KeywordKind::EndAlgorithm),
        KeywordKind::Subroutine => Some(KeywordKind::EndSubroutine),
        KeywordKind::Function => Some(KeywordKind::EndFunction),
        KeywordKind::ClassKeyword => Some(KeywordKind::EndClass),
        KeywordKind::Method => Some(KeywordKind::EndMethod),
        KeywordKind::IfKeyword => Some(KeywordKind::EndIf),
        KeywordKind::WhileKeyword => Some(KeywordKind::EndWhile),
        KeywordKind::ForKeyword => Some(KeywordKind::EndFor),
        KeywordKind::SwitchKeyword => Some(KeywordKind::EndSwitch),
        KeywordKind::Repeat => Some(KeywordKind::Until),
        KeywordKind::RecordKeyword => Some(KeywordKind::EndRecord),
        KeywordKind::EnumKeyword => Some(KeywordKind::EndEnum),
        KeywordKind::SelectKeyword => Some(KeywordKind::EndSelect),
        KeywordKind::TasksKeyword => Some(KeywordKind::EndTasks),
        _ => None,
    }
}

const MODULE_STRUCTURES: &[KeywordKind] = &[
    KeywordKind::ImportKeyword,
    KeywordKind::ExportKeyword,
    KeywordKind::ConstantKeyword,
    KeywordKind::Algorithm,
    KeywordKind::Subroutine,
    KeywordKind::Function,
    KeywordKind::ClassKeyword,
    KeywordKind::RecordKeyword,
    KeywordKind::EnumKeyword,
    KeywordKind::PublicVisibility,
    KeywordKind::PrivateVisibility,
];

const CLASS_STRUCTURES: &[KeywordKind] = &[
    KeywordKind::Declare,
    KeywordKind::Dimension,
    KeywordKind::Method,
    KeywordKind::PublicVisibility,
    KeywordKind::PrivateVisibility,
];

const BODY_STRUCTURES: &[KeywordKind] = &[
    KeywordKind::Declare,
    KeywordKind::Dimension,
    KeywordKind::ConstantKeyword,
    KeywordKind::Write,
    KeywordKind::Read,
    KeywordKind::IfKeyword,
    KeywordKind::WhileKeyword,
    KeywordKind::ForKeyword,
    KeywordKind::Repeat,
    KeywordKind::SwitchKeyword,
    KeywordKind::SelectKeyword,
    KeywordKind::TasksKeyword,
    KeywordKind::SpawnKeyword,
    KeywordKind::DiscardKeyword,
];

pub fn structure_keywords(innermost: Option<&KeywordKind>) -> &'static [KeywordKind] {
    match innermost {
        None => MODULE_STRUCTURES,
        Some(KeywordKind::ClassKeyword) => CLASS_STRUCTURES,
        Some(
            KeywordKind::RecordKeyword | KeywordKind::EnumKeyword | KeywordKind::SelectKeyword,
        ) => &[],
        Some(_) => BODY_STRUCTURES,
    }
}

const PARAMETER_OWNERS: &[KeywordKind] = &[
    KeywordKind::Subroutine,
    KeywordKind::Function,
    KeywordKind::Method,
];

fn inside_open_parameters(tokens: &[TokenKind]) -> bool {
    let opened = tokens
        .iter()
        .filter(|token| **token == TokenKind::LeftParenthesis)
        .count();
    let closed = tokens
        .iter()
        .filter(|token| **token == TokenKind::RightParenthesis)
        .count();
    opened > closed
}

fn parameter_mode_follow_ups(tokens: &[TokenKind], first: KeywordKind) -> Vec<KeywordKind> {
    let after_name_or_type = matches!(
        tokens.last(),
        Some(
            TokenKind::Identifier
                | TokenKind::Keyword(
                    KeywordKind::IntegerType
                        | KeywordKind::RealType
                        | KeywordKind::BooleanType
                        | KeywordKind::CharacterType
                        | KeywordKind::StringType
                )
        )
    );
    if PARAMETER_OWNERS.contains(&first) && inside_open_parameters(tokens) && after_name_or_type {
        vec![KeywordKind::ByValue, KeywordKind::ByReference]
    } else {
        Vec::new()
    }
}

fn class_header_follow_ups(tokens: &[TokenKind]) -> Vec<KeywordKind> {
    let named = tokens.len() >= 2 && tokens.get(1) == Some(&TokenKind::Identifier);
    let inherits = tokens.contains(&TokenKind::Keyword(KeywordKind::InheritsFrom));
    if named && !inherits {
        vec![KeywordKind::InheritsFrom]
    } else {
        Vec::new()
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
        KeywordKind::Method if tokens.len() == 1 => vec![KeywordKind::Constructor],
        KeywordKind::ClassKeyword => class_header_follow_ups(tokens),
        KeywordKind::ImportKeyword if !has(KeywordKind::TypeConnector) => {
            vec![KeywordKind::TypeConnector]
        }
        _ => parameter_mode_follow_ups(tokens, first),
    }
}

pub fn follow_up_keywords(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for kind in expected_follow_ups(&scope.context.line_tokens) {
        pool.add(1, keyword_entry(kind, scope.profile));
    }
}
