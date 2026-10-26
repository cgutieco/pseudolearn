use crate::collection_model::HirCollection;
use crate::hir::{HirClass, HirField};
use crate::identities::{ClassId, FieldId, TypeId};
use crate::session::AnalysisSession;
use crate::types::{Type, ValueClass};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn identity(session: &AnalysisSession<'_>, name: &str) -> Option<&'static str> {
    let profile = if session.options.profile == pseudolearn_lexicon::Profile::Spanish {
        "es"
    } else {
        "en"
    };
    pseudolearn_syntax::tree::contextual_identity(&name.to_lowercase(), profile)
}

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    let dictionary = match identity(session, name) {
        Some("vectorType") => false,
        Some("dictionaryType") => true,
        _ => return None,
    };
    let arguments = session
        .child(node, NodeKind::TypeArguments)
        .map(|node| session.children(node))
        .unwrap_or_default();
    let expected = if dictionary { 2 } else { 1 };
    if arguments.len() != expected {
        crate::generic_names::count_mismatch(session, node, (name, expected, arguments.len()));
        return Some(Type::Error);
    }
    let kinds: Vec<_> = arguments
        .into_iter()
        .map(|node| crate::type_resolution::resolve(session, node))
        .collect();
    let value = *kinds.last()?;
    let key = dictionary.then(|| kinds.first().copied()).flatten();
    if !valid_key(session, key, node) {
        return Some(Type::Error);
    }
    let existing = session
        .module
        .collections
        .values()
        .find(|model| model.key == key && model.value == value);
    if let Some(existing) = existing {
        return Some(Type::Object(existing.class));
    }
    Some(Type::Object(register(session, node, (key, value))))
}

fn register(
    session: &mut AnalysisSession<'_>,
    node: usize,
    types: (Option<TypeId>, TypeId),
) -> ClassId {
    let class = ClassId(u32::try_from(session.module.classes.len()).unwrap_or(u32::MAX));
    let leaves = leaves(session, types.1);
    let mut canonical: Vec<_> = (0..leaves.len()).collect();
    canonical.sort_by_key(|index| {
        leaves
            .get(*index)
            .is_some_and(|kind| session.module.types.value_class(*kind) == ValueClass::Reference)
    });
    let fields = fields(session, (node, class), types, (&leaves, &canonical));
    let family = if types.0.is_some() {
        "dictionary"
    } else {
        "vector"
    };
    let arguments: Vec<_> = types
        .0
        .into_iter()
        .chain(std::iter::once(types.1))
        .collect();
    let name = crate::generic_labels::instance_name(session, &format!("${family}"), &arguments);
    declare_class(session, node, name, fields);
    session.module.collections.insert(
        class,
        HirCollection {
            class,
            key: types.0,
            value: types.1,
            leaves,
            canonical,
        },
    );
    class
}

fn leaves(session: &AnalysisSession<'_>, kind: TypeId) -> Vec<TypeId> {
    if let Type::Record(record) = session.module.types.get(kind) {
        return session
            .module
            .records
            .get(usize::try_from(record.0).unwrap_or(usize::MAX))
            .map(|record| record.leaf_types.clone())
            .unwrap_or_default();
    }
    vec![kind]
}

fn fields(
    session: &AnalysisSession<'_>,
    owner: (usize, ClassId),
    types: (Option<TypeId>, TypeId),
    values: (&[TypeId], &[usize]),
) -> Vec<HirField> {
    let (node, class) = owner;
    let (key, value) = types;
    let first = session
        .module
        .classes
        .iter()
        .map(|class| class.fields.len())
        .sum::<usize>();
    let names = leaf_names(session, value, values.0.len());
    let leaves = values.1.iter().filter_map(|index| {
        Some((
            format!("$leaf:{}", names.get(*index)?),
            *values.0.get(*index)?,
        ))
    });
    key.into_iter()
        .map(|kind| (key_name(session, kind).to_owned(), kind))
        .chain(leaves)
        .enumerate()
        .map(|(index, (name, type_id))| HirField {
            id: FieldId(u32::try_from(first.saturating_add(index)).unwrap_or(u32::MAX)),
            name,
            type_id,
            owner: class,
            private: true,
            span: session.span(node),
        })
        .collect()
}

fn leaf_names(session: &AnalysisSession<'_>, kind: TypeId, width: usize) -> Vec<String> {
    if let Type::Record(record) = session.module.types.get(kind) {
        if session.module.function_types.contains_key(&record) {
            return (0..width)
                .map(|index| format!("function:{index}"))
                .collect();
        }
        if let Some(model) = session
            .module
            .records
            .get(usize::try_from(record.0).unwrap_or(usize::MAX))
        {
            return model
                .leaf_names
                .iter()
                .map(|name| format!("record:{name}"))
                .collect();
        }
    }
    vec!["value".to_owned()]
}

pub(crate) fn get(session: &AnalysisSession<'_>, kind: &Type) -> Option<HirCollection> {
    let Type::Object(class) = kind else {
        return None;
    };
    session.module.collections.get(class).cloned()
}

pub(crate) fn printable(session: &AnalysisSession<'_>, kind: TypeId) -> bool {
    let kind = session.module.types.get(kind);
    if crate::function_types::get(session, &kind).is_some() {
        return true;
    }
    if let Some(collection) = get(session, &kind) {
        return printable(session, collection.value);
    }
    matches!(
        kind,
        Type::Integer
            | Type::Real
            | Type::Boolean
            | Type::Character
            | Type::String
            | Type::Enum(_)
            | Type::Error
    )
}

fn valid_key(session: &mut AnalysisSession<'_>, key: Option<TypeId>, node: usize) -> bool {
    if let Some(key) = key
        && !matches!(
            session.module.types.get(key),
            Type::Integer
                | Type::Character
                | Type::Boolean
                | Type::String
                | Type::Enum(_)
                | Type::Error
        )
    {
        session.report(DiagnosticCode::InvalidDictionaryKeyType, node);
        return false;
    }
    true
}

fn declare_class(
    session: &mut AnalysisSession<'_>,
    node: usize,
    name: String,
    fields: Vec<HirField>,
) {
    session.tag_class();
    session.module.classes.push(HirClass {
        name,
        superclass: None,
        fields,
        methods: Vec::new(),
        virtual_slots: Vec::new(),
        constructor: None,
        span: session.span(node),
        syntax: node,
    });
}

fn key_name(session: &AnalysisSession<'_>, kind: TypeId) -> &'static str {
    if matches!(session.module.types.get(kind), Type::Enum(_)) {
        "$keyEnum"
    } else {
        "$key"
    }
}
