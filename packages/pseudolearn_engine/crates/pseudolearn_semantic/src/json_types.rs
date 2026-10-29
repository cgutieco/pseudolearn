#![forbid(unsafe_code)]

use crate::hir::{HirEnum, HirRecord, HirRecordField};
use crate::identities::{EnumId, RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use crate::variant_model::VariantFamily;
use pseudolearn_abi::EffectValueKind;
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_source::IdentifierNormalizer;

const KIND_ENUM: &str = "jsonKind";
const ERROR_ENUM: &str = "jsonErrorCode";
const ERROR_RECORD: &str = "$JsonError";

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    if keyword_matches(name, KeywordKind::JsonValueType, session.options.profile) {
        return Some(crate::effect_types::opaque(
            session,
            node,
            EffectValueKind::JsonValue,
        ));
    }
    if keyword_matches(name, KeywordKind::JsonKindType, session.options.profile) {
        return Some(Type::Enum(ensure_enum(session, KIND_ENUM)));
    }
    if keyword_matches(
        name,
        KeywordKind::JsonErrorCodeType,
        session.options.profile,
    ) {
        return Some(Type::Enum(ensure_enum(session, ERROR_ENUM)));
    }
    if keyword_matches(name, KeywordKind::JsonErrorType, session.options.profile) {
        return Some(Type::Record(ensure_error_record(session, node)));
    }
    None
}

pub(crate) fn value_type(
    session: &mut AnalysisSession<'_>,
    node: usize,
    kind: EffectValueKind,
) -> TypeId {
    match kind {
        EffectValueKind::JsonValue => {
            let opaque = crate::effect_types::opaque(session, node, kind);
            session.module.types.intern(opaque)
        }
        EffectValueKind::JsonKind => {
            let enumeration = ensure_enum(session, KIND_ENUM);
            session.module.types.intern(Type::Enum(enumeration))
        }
        EffectValueKind::JsonResult => result_type(session, node),
        EffectValueKind::OptionalBoolean => optional_type(session, node, Type::Boolean),
        EffectValueKind::OptionalInteger => optional_type(session, node, Type::Integer),
        EffectValueKind::OptionalReal => optional_type(session, node, Type::Real),
        EffectValueKind::OptionalText => optional_type(session, node, Type::String),
        EffectValueKind::OptionalJsonValue => {
            let value = crate::effect_types::opaque(session, node, EffectValueKind::JsonValue);
            optional_type(session, node, value)
        }
        _ => session.module.types.intern(Type::Error),
    }
}

pub(crate) fn builtin_enum(session: &mut AnalysisSession<'_>, name: &str) -> Option<EnumId> {
    [KIND_ENUM, ERROR_ENUM]
        .into_iter()
        .find(|identity| {
            keyword_matches(name, enum_type_keyword(identity), session.options.profile)
        })
        .map(|identity| ensure_enum(session, identity))
}

fn optional_type(session: &mut AnalysisSession<'_>, node: usize, inner: Type) -> TypeId {
    let inner = session.module.types.intern(inner);
    crate::variant_types::register(
        session,
        VariantFamily::Optional,
        vec![None, Some(inner)],
        node,
    )
}

fn result_type(session: &mut AnalysisSession<'_>, node: usize) -> TypeId {
    let json_value = crate::effect_types::opaque(session, node, EffectValueKind::JsonValue);
    let json_value = session.module.types.intern(json_value);
    let error_record = ensure_error_record(session, node);
    let json_error = session.module.types.intern(Type::Record(error_record));
    crate::variant_types::register(
        session,
        VariantFamily::Result,
        vec![Some(json_value), Some(json_error)],
        node,
    )
}

fn ensure_error_record(session: &mut AnalysisSession<'_>, node: usize) -> RecordId {
    if let Some((index, _)) = session
        .module
        .records
        .iter()
        .enumerate()
        .find(|(_, record)| record.name == ERROR_RECORD)
    {
        return RecordId(u32::try_from(index).unwrap_or(u32::MAX));
    }
    let record = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    let enumeration = ensure_enum(session, ERROR_ENUM);
    let code = session.module.types.intern(Type::Enum(enumeration));
    let integer = session.module.types.intern(Type::Integer);
    let profile = session.options.profile;
    let fields = error_fields(profile, code, integer);
    let leaf_names = fields.iter().map(|field| field.name.clone()).collect();
    let leaf_types = fields.iter().map(|field| field.type_id).collect();
    session.module.records.push(HirRecord {
        name: ERROR_RECORD.to_owned(),
        fields,
        leaf_types,
        leaf_names,
        span: session.span(node),
        syntax: node,
    });
    record
}

fn error_fields(profile: Profile, code: TypeId, integer: TypeId) -> Vec<HirRecordField> {
    [
        (KeywordKind::JsonErrorCodeField, code),
        (KeywordKind::JsonErrorLineField, integer),
        (KeywordKind::JsonErrorColumnField, integer),
    ]
    .into_iter()
    .enumerate()
    .map(|(index, (keyword, type_id))| HirRecordField {
        name: keyword.lexeme(profile).unwrap_or_default().to_owned(),
        type_id,
        offset: u32::try_from(index).unwrap_or(u32::MAX),
        width: 1,
    })
    .collect::<Vec<_>>()
}

fn ensure_enum(session: &mut AnalysisSession<'_>, identity: &str) -> EnumId {
    if let Some(enumeration) = session.module.builtin_enums.get(identity) {
        return *enumeration;
    }
    let members = enum_members(identity)
        .into_iter()
        .map(|keyword| {
            keyword
                .lexeme(session.options.profile)
                .unwrap_or_default()
                .to_owned()
        })
        .collect();
    let enumeration = EnumId(u32::try_from(session.module.enums.len()).unwrap_or(u32::MAX));
    session.module.enums.push(HirEnum {
        name: format!("${identity}"),
        members,
        span: session.span(0),
    });
    session
        .module
        .builtin_enums
        .insert(identity.to_owned(), enumeration);
    enumeration
}

fn enum_members(identity: &str) -> Vec<KeywordKind> {
    if identity == KIND_ENUM {
        vec![
            KeywordKind::JsonKindNull,
            KeywordKind::JsonKindBoolean,
            KeywordKind::JsonKindNumber,
            KeywordKind::JsonKindString,
            KeywordKind::JsonKindArray,
            KeywordKind::JsonKindObject,
        ]
    } else {
        vec![
            KeywordKind::JsonErrorCodeInvalidSyntax,
            KeywordKind::JsonErrorCodeUnexpectedEnd,
            KeywordKind::JsonErrorCodeDuplicateKey,
            KeywordKind::JsonErrorCodeDepthExceeded,
            KeywordKind::JsonErrorCodeInvalidEscape,
            KeywordKind::JsonErrorCodeTrailingContent,
        ]
    }
}

fn enum_type_keyword(identity: &str) -> KeywordKind {
    if identity == KIND_ENUM {
        KeywordKind::JsonKindType
    } else {
        KeywordKind::JsonErrorCodeType
    }
}

fn keyword_matches(name: &str, keyword: KeywordKind, profile: Profile) -> bool {
    keyword
        .lexeme(profile)
        .is_some_and(|lexeme| IdentifierNormalizer::normalize(lexeme) == name)
}
