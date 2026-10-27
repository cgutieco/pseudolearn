use crate::hir::{HirClass, HirRecord, HirRecordField};
use crate::identities::{ClassId, RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_abi::EffectValueKind;

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    let kind = match name {
        "Bytes" | "bytes" => EffectValueKind::Bytes,
        "ErrorES" | "IoError" => return Some(error_type(session, node)),
        _ => capability_kind(name)?,
    };
    Some(opaque(session, node, kind))
}

fn capability_kind(name: &str) -> Option<EffectValueKind> {
    use pseudolearn_abi::CapabilityKind;
    Some(match crate::capability_types::find_capability_kind(name)? {
        CapabilityKind::Console => EffectValueKind::Console,
        CapabilityKind::Arguments => EffectValueKind::Arguments,
        CapabilityKind::Directory => EffectValueKind::Directory,
        CapabilityKind::File => EffectValueKind::File,
        CapabilityKind::Clock => EffectValueKind::Clock,
        CapabilityKind::Timer => EffectValueKind::Timer,
    })
}

pub(crate) fn value_type(
    session: &mut AnalysisSession<'_>,
    node: usize,
    kind: EffectValueKind,
) -> TypeId {
    let kind = match kind {
        EffectValueKind::Integer => Type::Integer,
        EffectValueKind::Boolean => Type::Boolean,
        EffectValueKind::Text => Type::String,
        EffectValueKind::TextList => return crate::effect_vectors::text_vector(session, node),
        other => opaque(session, node, other),
    };
    session.module.types.intern(kind)
}

fn opaque(session: &mut AnalysisSession<'_>, node: usize, kind: EffectValueKind) -> Type {
    if let Some(class) = session
        .module
        .opaque_types
        .iter()
        .find_map(|(class, found)| (*found == kind).then_some(*class))
    {
        return Type::Object(class);
    }
    let class = ClassId(u32::try_from(session.module.classes.len()).unwrap_or(u32::MAX));
    session.tag_class();
    session.module.classes.push(HirClass {
        name: format!("$effect:{kind:?}"),
        superclass: None,
        fields: Vec::new(),
        methods: Vec::new(),
        virtual_slots: Vec::new(),
        constructor: None,
        span: session.span(node),
        syntax: node,
    });
    session.module.opaque_types.insert(class, kind);
    Type::Object(class)
}

pub(crate) fn error_type(session: &mut AnalysisSession<'_>, node: usize) -> Type {
    if let Some((index, _)) = session
        .module
        .records
        .iter()
        .enumerate()
        .find(|(_, record)| record.name == "$IoError")
    {
        return Type::Record(RecordId(u32::try_from(index).unwrap_or(u32::MAX)));
    }
    let record = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    let text = session.module.types.intern(Type::String);
    let boolean = session.module.types.intern(Type::Boolean);
    let spanish = session.options.profile == pseudolearn_lexicon::Profile::Spanish;
    let names = if spanish {
        ["Codigo", "Incierto"]
    } else {
        ["code", "uncertain"]
    };
    let fields = names
        .into_iter()
        .zip([text, boolean])
        .enumerate()
        .map(|(index, (name, type_id))| HirRecordField {
            name: name.to_owned(),
            type_id,
            offset: u32::try_from(index).unwrap_or(u32::MAX),
            width: 1,
        })
        .collect();
    session.module.records.push(HirRecord {
        name: "$IoError".to_owned(),
        fields,
        leaf_types: vec![text, boolean],
        leaf_names: names.into_iter().map(str::to_owned).collect(),
        span: session.span(node),
        syntax: node,
    });
    Type::Record(record)
}

pub(crate) fn receiver(session: &AnalysisSession<'_>, kind: &Type) -> Option<EffectValueKind> {
    let Type::Object(class) = kind else {
        return None;
    };
    session.module.opaque_types.get(class).copied()
}
