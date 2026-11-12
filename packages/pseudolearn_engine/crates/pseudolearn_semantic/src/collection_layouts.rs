use crate::session::AnalysisSession;
use crate::types::ValueClass;

pub(crate) fn refresh(session: &mut AnalysisSession<'_>) {
    let collections: Vec<_> = session.module.collections.values().cloned().collect();
    for mut collection in collections {
        let leaves = crate::collection_types::leaves(session, collection.value);
        if leaves == collection.leaves {
            continue;
        }
        let names = crate::collection_types::leaf_names(session, collection.value, leaves.len());
        collection.canonical = (0..leaves.len()).collect();
        collection.canonical.sort_by_key(|index| {
            leaves.get(*index).is_some_and(|kind| {
                session.module.types.value_class(*kind) == ValueClass::Reference
            })
        });
        collection.leaves = leaves;
        replace_fields(session, &collection, &names);
        session
            .module
            .collections
            .insert(collection.class, collection);
    }
}

fn replace_fields(
    session: &mut AnalysisSession<'_>,
    collection: &crate::collection_model::HirCollection,
    names: &[String],
) {
    let first = session
        .module
        .classes
        .iter()
        .flat_map(|class| &class.fields)
        .map(|field| field.id.0)
        .max()
        .map_or(0, |last| last.saturating_add(1));
    if let Some(class) = usize::try_from(collection.class.0)
        .ok()
        .and_then(|index| session.module.classes.get_mut(index))
    {
        class.fields.retain(|field| field.name.starts_with("$key"));
        for (index, leaf) in collection.canonical.iter().enumerate() {
            let Some(kind) = collection.leaves.get(*leaf) else {
                continue;
            };
            class.fields.push(crate::hir::HirField {
                id: crate::identities::FieldId(
                    first.saturating_add(u32::try_from(index).unwrap_or(u32::MAX)),
                ),
                name: format!("$leaf:{}", names.get(*leaf).map_or("value", String::as_str)),
                type_id: *kind,
                owner: collection.class,
                private: true,
                span: class.span,
            });
        }
    }
}
