use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::{DiagnosticArgument, DiagnosticType, TypeName};
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn type_argument(session: &AnalysisSession<'_>, kind: &Type) -> DiagnosticArgument {
    let name = match kind {
        Type::Integer => TypeName::Token(KeywordKind::IntegerType.as_str().to_owned()),
        Type::Real => TypeName::Token(KeywordKind::RealType.as_str().to_owned()),
        Type::Boolean => TypeName::Token(KeywordKind::BooleanType.as_str().to_owned()),
        Type::Character => TypeName::Token(KeywordKind::CharacterType.as_str().to_owned()),
        Type::String => TypeName::Token(KeywordKind::StringType.as_str().to_owned()),
        Type::Enum(enumeration) => TypeName::Named(
            usize::try_from(enumeration.0)
                .ok()
                .and_then(|slot| session.module.enums.get(slot))
                .map(|model| model.name.clone())
                .unwrap_or_default(),
        ),
        Type::Immutable(inner) => immutable_name(session, *inner),
        Type::Record(record) => TypeName::Named(record_name(session, *record)),
        Type::Object(class) => TypeName::Named(object_name(session, *class)),
        Type::Task(inner) => TypeName::Named(generic_name(
            session,
            KeywordKind::TaskType.lexeme(session.options.profile),
            &[*inner],
        )),
        Type::Array { element, rank } => {
            let DiagnosticArgument::Type(mut element) =
                type_argument(session, &session.module.types.get(*element))
            else {
                return DiagnosticArgument::Lexeme(String::new());
            };
            element.rank = element.rank.saturating_add(*rank);
            return DiagnosticArgument::Type(element);
        }
        _ => TypeName::Named(format!("{kind:?}")),
    };
    DiagnosticArgument::Type(DiagnosticType { name, rank: 0 })
}

pub(crate) fn last_type(session: &mut AnalysisSession<'_>, type_id: crate::identities::TypeId) {
    let argument = type_argument(session, &session.module.types.get(type_id));
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.arguments.insert("type".to_owned(), argument);
    }
}

pub(crate) fn assignment_types(session: &mut AnalysisSession<'_>, expected: &Type, actual: &Type) {
    let expected = type_argument(session, expected);
    let actual = type_argument(session, actual);
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.arguments.insert("expected".to_owned(), expected);
        diagnostic.arguments.insert("found".to_owned(), actual);
    }
}

pub(crate) fn class_name(session: &mut AnalysisSession<'_>, owner: crate::identities::ClassId) {
    let name = crate::hierarchy::class_model(session, owner)
        .map(|class| class.name.clone())
        .unwrap_or_default();
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic
            .arguments
            .insert("className".to_owned(), DiagnosticArgument::Lexeme(name));
    }
}

pub(crate) fn lexeme(
    session: &AnalysisSession<'_>,
    code: pseudolearn_diagnostics::DiagnosticCode,
    node: usize,
) -> String {
    if code == pseudolearn_diagnostics::DiagnosticCode::IncompatibleOperandTypes {
        let span = session.operator_span(node);
        return usize::try_from(span.start)
            .ok()
            .zip(usize::try_from(span.ending).ok())
            .and_then(|(start, ending)| session.source.as_str().get(start..ending))
            .unwrap_or("")
            .to_owned();
    }
    let node = if matches!(
        session.kind(node),
        pseudolearn_syntax::NodeKind::ClassUnit
            | pseudolearn_syntax::NodeKind::Subprogram
            | pseudolearn_syntax::NodeKind::MethodMember
            | pseudolearn_syntax::NodeKind::AlgorithmUnit
    ) {
        session
            .child(node, pseudolearn_syntax::NodeKind::Identifier)
            .unwrap_or(node)
    } else {
        node
    };
    session.lexeme(node).to_owned()
}

fn variant_name(session: &AnalysisSession<'_>, record: crate::identities::RecordId) -> String {
    let Some(variant) = session.module.variants.get(&record) else {
        return String::new();
    };
    let keyword = match variant.family {
        crate::variant_model::VariantFamily::Optional => KeywordKind::OptionalType,
        crate::variant_model::VariantFamily::Result => KeywordKind::ResultType,
        crate::variant_model::VariantFamily::User => {
            return session
                .module
                .user_variants
                .get(&record)
                .map(|model| model.name.clone())
                .unwrap_or_default();
        }
    };
    let arguments: Vec<_> = variant
        .payloads
        .iter()
        .flatten()
        .map(|kind| argument_display(session, *kind))
        .collect();
    format!(
        "{}<{}>",
        keyword.lexeme(session.options.profile).unwrap_or(""),
        arguments.join(", ")
    )
}

fn record_name(session: &AnalysisSession<'_>, record: crate::identities::RecordId) -> String {
    if let Some(signature) = session.module.function_types.get(&record) {
        let keyword = if signature.pure {
            KeywordKind::Function
        } else {
            KeywordKind::Subroutine
        };
        return keyword
            .lexeme(session.options.profile)
            .unwrap_or("")
            .to_owned();
    }
    if let Some(element) = session.module.channels.get(&record) {
        return generic_name(session, contextual(session, "channelType"), &[*element]);
    }
    if session.module.variants.contains_key(&record) {
        return variant_name(session, record);
    }
    usize::try_from(record.0)
        .ok()
        .and_then(|index| session.module.records.get(index))
        .map(|model| model.name.clone())
        .unwrap_or_default()
}

fn argument_display(session: &AnalysisSession<'_>, kind: crate::identities::TypeId) -> String {
    let DiagnosticArgument::Type(argument) =
        type_argument(session, &session.module.types.get(kind))
    else {
        return String::new();
    };
    let name = match argument.name {
        TypeName::Named(name) => name,
        TypeName::Token(token) => KeywordKind::all()
            .iter()
            .find(|keyword| keyword.as_str() == token)
            .and_then(|keyword| keyword.lexeme(session.options.profile))
            .unwrap_or("")
            .to_owned(),
    };
    if argument.rank == 0 {
        name
    } else {
        format!(
            "{name}[{}]",
            ",".repeat(usize::try_from(argument.rank.saturating_sub(1)).unwrap_or(0))
        )
    }
}

fn immutable_name(session: &AnalysisSession<'_>, inner: crate::identities::TypeId) -> TypeName {
    let name =
        pseudolearn_syntax::contextual_spelling("immutableType", session.options.profile.as_str())
            .unwrap_or("");
    TypeName::Named(format!("{name}<{}>", argument_display(session, inner)))
}

fn object_name(session: &AnalysisSession<'_>, class: crate::identities::ClassId) -> String {
    if let Some(collection) = session.module.collections.get(&class) {
        return match collection.key {
            Some(key) => generic_name(
                session,
                contextual(session, "dictionaryType"),
                &[key, collection.value],
            ),
            None => generic_name(
                session,
                contextual(session, "vectorType"),
                &[collection.value],
            ),
        };
    }
    crate::hierarchy::class_model(session, class)
        .map(|class| class.name.clone())
        .unwrap_or_default()
}

fn contextual(session: &AnalysisSession<'_>, identity: &str) -> Option<&'static str> {
    pseudolearn_syntax::contextual_spelling(identity, session.options.profile.as_str())
}

fn generic_name(
    session: &AnalysisSession<'_>,
    lexeme: Option<&str>,
    arguments: &[crate::identities::TypeId],
) -> String {
    let arguments: Vec<_> = arguments
        .iter()
        .map(|kind| argument_display(session, *kind))
        .collect();
    format!("{}<{}>", lexeme.unwrap_or(""), arguments.join(", "))
}
