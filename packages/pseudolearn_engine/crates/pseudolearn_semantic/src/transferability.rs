use crate::hir::HirModule;
use crate::identities::{RecordId, TypeId};
use crate::types::Type;
use std::collections::BTreeSet;

pub(crate) struct TransferFailure {
    pub(crate) kind: TypeId,
    pub(crate) path: String,
}

enum Frame {
    Enter(TypeId, String),
    Exit(TypeId),
}

pub(crate) fn violation(module: &HirModule, kind: TypeId) -> Option<TransferFailure> {
    rooted_violation(module, kind, root_name(module, kind))
}

fn rooted_violation(module: &HirModule, kind: TypeId, root: String) -> Option<TransferFailure> {
    let mut pending = vec![Frame::Enter(kind, root)];
    let mut active = BTreeSet::new();
    let mut checked = BTreeSet::new();
    let mut path = Vec::new();
    while let Some(frame) = pending.pop() {
        let Frame::Enter(kind, component) = frame else {
            if let Frame::Exit(kind) = frame {
                active.remove(&kind);
                checked.insert(kind);
                path.pop();
            }
            continue;
        };
        if checked.contains(&kind) {
            continue;
        }
        path.push(component);
        if !active.insert(kind) {
            return Some(TransferFailure {
                kind,
                path: joined(&path),
            });
        }
        let Ok(children) = children(module, kind) else {
            return Some(TransferFailure {
                kind,
                path: joined(&path),
            });
        };
        pending.push(Frame::Exit(kind));
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
        Type::Object(class) if module.opaque_types.contains_key(&class) => Ok(Vec::new()),
        Type::Record(record) => record_children(module, record),
        _ => Err(()),
    }
}

fn record_children(module: &HirModule, record: RecordId) -> Result<Vec<(TypeId, String)>, ()> {
    if module.function_types.contains_key(&record) {
        return Err(());
    }
    if let Some(variant) = module.variants.get(&record) {
        return Ok(variant
            .payloads
            .iter()
            .filter_map(|kind| Some(((*kind)?, String::new())))
            .collect());
    }
    if let Some(error) = module.task_failures.get(&record) {
        return Ok(vec![(*error, String::new())]);
    }
    if let Some(element) = module.channels.get(&record) {
        return Ok(vec![(*element, String::new())]);
    }
    ordinary_children(module, record)
}

fn ordinary_children(module: &HirModule, record: RecordId) -> Result<Vec<(TypeId, String)>, ()> {
    let model = module
        .records
        .get(usize::try_from(record.0).map_err(|_| ())?)
        .ok_or(())?;
    if !model.fields.is_empty() {
        return Ok(model
            .fields
            .iter()
            .map(|field| (field.type_id, field.name.clone()))
            .collect());
    }
    if model.leaf_types.is_empty() {
        return Err(());
    }
    Ok(model
        .leaf_types
        .iter()
        .enumerate()
        .map(|(index, kind)| {
            (
                *kind,
                model
                    .leaf_names
                    .get(index)
                    .cloned()
                    .unwrap_or_else(|| "field".to_owned()),
            )
        })
        .collect())
}

pub(crate) fn root_name(module: &HirModule, kind: TypeId) -> String {
    if let Type::Record(record) = module.types.get(kind)
        && !module.variants.contains_key(&record)
        && !module.function_types.contains_key(&record)
        && let Some(model) = usize::try_from(record.0)
            .ok()
            .and_then(|index| module.records.get(index))
        && !model.name.starts_with('$')
    {
        return model.name.clone();
    }
    String::new()
}

pub(crate) fn joined(path: &[String]) -> String {
    path.iter()
        .filter(|segment| !segment.is_empty())
        .cloned()
        .collect::<Vec<_>>()
        .join(".")
}

pub(crate) fn report(
    session: &mut crate::session::AnalysisSession<'_>,
    kind: TypeId,
    node: usize,
    code: pseudolearn_diagnostics::DiagnosticCode,
) {
    let failure = violation(&session.module, kind);
    report_failure(session, failure, node, code);
}

pub(crate) fn report_argument(
    session: &mut crate::session::AnalysisSession<'_>,
    (kind, argument): (TypeId, crate::identities::ExpressionId),
    node: usize,
    code: pseudolearn_diagnostics::DiagnosticCode,
) {
    let root = argument_text(session, argument);
    let failure = rooted_violation(&session.module, kind, root);
    report_failure(session, failure, node, code);
}

fn argument_text(
    session: &crate::session::AnalysisSession<'_>,
    argument: crate::identities::ExpressionId,
) -> String {
    usize::try_from(argument.0)
        .ok()
        .and_then(|index| session.module.expressions.spans.get(index))
        .and_then(|span| {
            let start = usize::try_from(span.start).ok()?;
            let ending = usize::try_from(span.ending).ok()?;
            session.source.as_str().get(start..ending)
        })
        .unwrap_or("")
        .to_owned()
}

fn report_failure(
    session: &mut crate::session::AnalysisSession<'_>,
    failure: Option<TransferFailure>,
    node: usize,
    code: pseudolearn_diagnostics::DiagnosticCode,
) {
    if let Some(failure) = failure {
        session.report(code, node);
        crate::diagnostic_arguments::last_type(session, failure.kind);
        if let Some(diagnostic) = session.diagnostics.last_mut() {
            diagnostic.arguments.insert(
                "path".to_owned(),
                pseudolearn_diagnostics::DiagnosticArgument::Lexeme(failure.path),
            );
        }
    }
}
