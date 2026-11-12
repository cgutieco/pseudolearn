use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use std::collections::BTreeSet;

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    selector: (&Type, &BTreeSet<String>),
    branch: (usize, bool),
) {
    let (Type::Enum(identifier), seen) = selector else {
        return;
    };
    if branch.1 {
        return;
    }
    let Some(model) = usize::try_from(identifier.0)
        .ok()
        .and_then(|index| session.module.enums.get(index))
    else {
        return;
    };
    let missing: Vec<_> = model
        .members
        .iter()
        .enumerate()
        .filter_map(|(index, name)| {
            let ordinal = i64::try_from(index).ok()?;
            (!seen.contains(&format!("Integer({ordinal})")))
                .then(|| format!("{}.{name}", model.name))
        })
        .collect();
    if !missing.is_empty() {
        session.named_report(
            DiagnosticCode::NonExhaustiveSwitch,
            branch.0,
            &missing.join(", "),
        );
    }
}
