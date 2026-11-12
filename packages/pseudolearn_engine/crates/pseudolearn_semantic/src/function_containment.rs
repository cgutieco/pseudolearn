use crate::session::AnalysisSession;
use crate::types::Type;
use std::collections::BTreeSet;

pub(crate) fn contains(session: &AnalysisSession<'_>, kind: Type) -> bool {
    let mut pending = vec![kind];
    let mut visited = BTreeSet::new();
    while let Some(kind) = pending.pop() {
        let Type::Record(record) = kind else {
            continue;
        };
        if !visited.insert(record) {
            continue;
        }
        if session.module.function_types.contains_key(&record)
            || session.generic.opaque_records.contains(&record)
        {
            return true;
        }
        let Some(model) = usize::try_from(record.0)
            .ok()
            .and_then(|index| session.module.records.get(index))
        else {
            continue;
        };
        pending.extend(
            model
                .fields
                .iter()
                .map(|field| session.module.types.get(field.type_id)),
        );
    }
    false
}
