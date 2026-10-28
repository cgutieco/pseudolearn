use crate::hir::HirModule;
use crate::identities::TypeId;
use crate::transferability::TransferFailure;
use crate::types::Type;
use std::collections::BTreeSet;

enum Frame {
    Enter(TypeId, String),
    Exit,
}

pub(crate) fn violation(module: &HirModule, kind: TypeId) -> Option<TransferFailure> {
    let mut pending = vec![Frame::Enter(
        kind,
        crate::transferability::root_name(module, kind),
    )];
    let mut visited = BTreeSet::new();
    let mut path = Vec::new();
    while let Some(frame) = pending.pop() {
        let Frame::Enter(kind, component) = frame else {
            path.pop();
            continue;
        };
        if !visited.insert(kind) {
            continue;
        }
        path.push(component);
        let Ok(children) = children(module, kind) else {
            return Some(TransferFailure {
                kind,
                path: path.join("."),
            });
        };
        pending.push(Frame::Exit);
        pending.extend(
            children
                .into_iter()
                .rev()
                .map(|(kind, component)| Frame::Enter(kind, component)),
        );
    }
    None
}

fn children(module: &HirModule, kind: TypeId) -> Result<Vec<(TypeId, String)>, ()> {
    match module.types.get(kind) {
        Type::Integer
        | Type::Real
        | Type::Boolean
        | Type::Character
        | Type::String
        | Type::Enum(_)
        | Type::Immutable(_)
        | Type::Error => Ok(Vec::new()),
        Type::Array { element, .. } => Ok(vec![(element, "element".to_owned())]),
        Type::Object(class) if module.opaque_types.contains_key(&class) => Ok(Vec::new()),
        Type::Object(class) => module
            .collections
            .get(&class)
            .map(|model| vec![(model.value, "element".to_owned())])
            .ok_or(()),
        Type::Record(record) if module.channels.contains_key(&record) => Ok(Vec::new()),
        Type::Record(record) if !module.function_types.contains_key(&record) => {
            record_children(module, record)
        }
        _ => Err(()),
    }
}

fn record_children(
    module: &HirModule,
    record: crate::identities::RecordId,
) -> Result<Vec<(TypeId, String)>, ()> {
    if let Some(variant) = module.variants.get(&record) {
        return Ok(variant
            .payloads
            .iter()
            .enumerate()
            .filter_map(|(index, kind)| Some(((*kind)?, format!("alternative{index}"))))
            .collect());
    }
    let model = module
        .records
        .get(usize::try_from(record.0).map_err(|_| ())?)
        .ok_or(())?;
    if model.leaf_types.is_empty() {
        return Err(());
    }
    Ok(model
        .fields
        .iter()
        .map(|field| (field.type_id, field.name.clone()))
        .collect())
}
