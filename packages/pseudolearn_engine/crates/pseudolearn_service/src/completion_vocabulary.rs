use crate::completion_pool::{CandidatePool, identified, keyed_entry, plain_entry};
use crate::completion_scope::SourceScope;
use crate::completion_types::CompletionKind;
use crate::spelling::canonical_word;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::TokenKind;

const LIBRARY_TYPES: &[&str] = &[
    "vectorType",
    "dictionaryType",
    "bytesType",
    "channelType",
    "dateTimeType",
    "ioErrorType",
    "httpMethodType",
    "httpRequestType",
    "httpResponseType",
    "taskFailureType",
    "immutableType",
    "argumentsCapabilityType",
    "clockCapabilityType",
    "consoleCapabilityType",
    "directoryCapabilityType",
    "environmentCapabilityType",
    "fileCapabilityType",
    "networkCapabilityType",
    "timerCapabilityType",
];

const LIBRARY_KEYWORD_TYPES: &[KeywordKind] = &[
    KeywordKind::OptionalType,
    KeywordKind::ResultType,
    KeywordKind::TaskType,
    KeywordKind::JsonValueType,
    KeywordKind::JsonKindType,
    KeywordKind::JsonErrorType,
    KeywordKind::JsonErrorCodeType,
];

const CAPABILITY_REQUESTS: &[&str] = &[
    "requestConsole",
    "requestArguments",
    "requestClock",
    "requestDirectory",
    "requestEnvironment",
    "requestTimer",
];

const LOOP_BLOCKS: &[KeywordKind] = &[
    KeywordKind::WhileKeyword,
    KeywordKind::ForKeyword,
    KeywordKind::Repeat,
];

const SUBPROGRAM_BLOCKS: &[KeywordKind] = &[
    KeywordKind::Subroutine,
    KeywordKind::Function,
    KeywordKind::Method,
];

fn contextual_label(scope: &SourceScope<'_>, identity: &str) -> Option<String> {
    let lexeme = pseudolearn_syntax::contextual_spelling(identity, scope.profile.as_str())?;
    Some(canonical_word(lexeme, scope.profile))
}

fn library_type(scope: &SourceScope<'_>, label: String, identity: &str, pool: &mut CandidatePool) {
    let entry = keyed_entry(
        label,
        CompletionKind::Type,
        ("library_type", Vec::new()),
        Some(scope.label("Tipo de la biblioteca", "Library type")),
    );
    pool.add(1, identified(entry, identity));
}

pub fn library_types(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for identity in LIBRARY_TYPES {
        if let Some(label) = contextual_label(scope, identity) {
            library_type(scope, label, identity, pool);
        }
    }
    for kind in LIBRARY_KEYWORD_TYPES {
        let label = crate::spelling::keyword_spelling(*kind, scope.profile);
        library_type(scope, label, kind.as_str(), pool);
    }
}

pub fn capability_requests(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for identity in CAPABILITY_REQUESTS {
        if let Some(label) = contextual_label(scope, identity) {
            let entry = keyed_entry(
                label,
                CompletionKind::Function,
                ("capability_request", Vec::new()),
                Some(scope.label("Solicitud de capacidad", "Capability request")),
            );
            pool.add(3, identified(entry, identity));
        }
    }
}

fn statement_word(scope: &SourceScope<'_>, identity: &str, pool: &mut CandidatePool) {
    if let Some(label) = contextual_label(scope, identity) {
        pool.add(
            2,
            identified(plain_entry(label, CompletionKind::Keyword, None), identity),
        );
    }
}

pub fn contextual_statements(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    let blocks = &scope.context.open_blocks;
    if blocks.iter().any(|block| LOOP_BLOCKS.contains(block)) {
        statement_word(scope, "breakKeyword", pool);
    }
    if blocks.iter().any(|block| SUBPROGRAM_BLOCKS.contains(block)) {
        statement_word(scope, "deferKeyword", pool);
    }
}

pub fn module_statements(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for identity in ["interfaceKeyword", "variantKeyword"] {
        statement_word(scope, identity, pool);
    }
}

fn contextual_follow_up_identities(tokens: &[TokenKind]) -> Vec<&'static str> {
    let Some(TokenKind::Keyword(first)) = tokens.first().copied() else {
        return Vec::new();
    };
    let identifiers = tokens
        .iter()
        .filter(|token| **token == TokenKind::Identifier)
        .count();
    match first {
        KeywordKind::ForKeyword if tokens.len() == 1 => vec!["eachKeyword"],
        KeywordKind::ForKeyword if tokens.len() == 3 && identifiers == 2 => vec!["inKeyword"],
        KeywordKind::ClassKeyword if identifiers >= 1 && tokens.len() >= 2 => {
            vec!["implementsKeyword"]
        }
        _ => Vec::new(),
    }
}

pub fn contextual_follow_ups(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for identity in contextual_follow_up_identities(&scope.context.line_tokens) {
        if let Some(label) = contextual_label(scope, identity) {
            pool.add(
                1,
                identified(plain_entry(label, CompletionKind::Keyword, None), identity),
            );
        }
    }
}
