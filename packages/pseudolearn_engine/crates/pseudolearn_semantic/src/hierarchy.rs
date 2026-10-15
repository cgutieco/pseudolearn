use crate::hir::HirField;
use crate::identities::{ClassId, FunctionId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use std::collections::BTreeSet;

pub(crate) fn check(session: &mut AnalysisSession<'_>) {
    let mut finished = BTreeSet::new();
    for index in 0..session.module.classes.len() {
        let mut path = Vec::new();
        let mut current = Some(ClassId(u32::try_from(index).unwrap_or(u32::MAX)));
        while let Some(class) = current {
            if finished.contains(&class) {
                break;
            }
            if path.contains(&class) {
                break_cycle(session, class);
                break;
            }
            path.push(class);
            current = class_model(session, class).and_then(|class| class.superclass);
        }
        for class in path.into_iter().rev() {
            check_members(session, class);
            finished.insert(class);
        }
    }
}

fn break_cycle(session: &mut AnalysisSession<'_>, class: ClassId) {
    let syntax = class_model(session, class).map(|class| class.syntax);
    if let Some(syntax) = syntax {
        session.report(DiagnosticCode::CircularInheritance, syntax);
    }
    if let Some(class) = usize::try_from(class.0)
        .ok()
        .and_then(|index| session.module.classes.get_mut(index))
    {
        class.superclass = None;
    }
}

fn check_members(session: &mut AnalysisSession<'_>, class: ClassId) {
    let Some(model) = class_model(session, class).cloned() else {
        return;
    };
    let mut names = BTreeSet::new();
    for field in &model.fields {
        names.insert(field.name.clone());
        if model
            .superclass
            .and_then(|parent| find_field(session, parent, &field.name))
            .is_some()
        {
            session.named_report(DiagnosticCode::DuplicateMember, model.syntax, &field.name);
        }
    }
    let mut virtuals = model
        .superclass
        .and_then(|parent| class_model(session, parent))
        .map(|parent| parent.virtual_slots.clone())
        .unwrap_or_default();
    for method in &model.methods {
        let Some(function) = function(session, *method).cloned() else {
            continue;
        };
        if !names.insert(function.name.clone()) {
            session.named_report(
                DiagnosticCode::DuplicateMember,
                function.syntax,
                &function.name,
            );
        }
        update_virtual(session, model.superclass, *method, &mut virtuals);
    }
    if let Some(model) = usize::try_from(class.0)
        .ok()
        .and_then(|index| session.module.classes.get_mut(index))
    {
        model.virtual_slots = virtuals;
    }
}

fn same_signature(session: &AnalysisSession<'_>, left: FunctionId, right: FunctionId) -> bool {
    let Some(left) = function(session, left) else {
        return false;
    };
    let Some(right) = function(session, right) else {
        return false;
    };
    if left.result != right.result || left.parameters.len() != right.parameters.len() {
        return false;
    }
    left.parameters
        .iter()
        .zip(&right.parameters)
        .all(|(left, right)| {
            let left = usize::try_from(left.0)
                .ok()
                .and_then(|index| session.module.locals.get(index));
            let right = usize::try_from(right.0)
                .ok()
                .and_then(|index| session.module.locals.get(index));
            left.zip(right).is_some_and(|(left, right)| {
                left.type_id == right.type_id && left.passing == right.passing
            })
        })
}

pub(crate) fn class_model<'session>(
    session: &'session AnalysisSession<'_>,
    class: ClassId,
) -> Option<&'session crate::hir::HirClass> {
    usize::try_from(class.0)
        .ok()
        .and_then(|index| session.module.classes.get(index))
}

pub(crate) fn function<'session>(
    session: &'session AnalysisSession<'_>,
    function: FunctionId,
) -> Option<&'session crate::hir::HirFunction> {
    usize::try_from(function.0)
        .ok()
        .and_then(|index| session.module.functions.get(index))
}

pub(crate) fn find_field(
    session: &AnalysisSession<'_>,
    class: ClassId,
    name: &str,
) -> Option<HirField> {
    let mut current = Some(class);
    for _ in 0..session.module.classes.len() {
        let model = class_model(session, current?)?;
        if let Some(field) = model.fields.iter().find(|field| field.name == name) {
            return Some(field.clone());
        }
        current = model.superclass;
    }
    None
}

pub(crate) fn find_method(
    session: &AnalysisSession<'_>,
    class: ClassId,
    name: &str,
) -> Option<FunctionId> {
    let mut current = Some(class);
    for _ in 0..session.module.classes.len() {
        let model = class_model(session, current?)?;
        if let Some(method) = model.methods.iter().find(|method| {
            function(session, **method).is_some_and(|function| function.name == name)
        }) {
            return Some(*method);
        }
        current = model.superclass;
    }
    None
}

fn update_virtual(
    session: &mut AnalysisSession<'_>,
    parent: Option<ClassId>,
    method: FunctionId,
    virtuals: &mut Vec<FunctionId>,
) {
    let Some(model) = function(session, method).cloned() else {
        return;
    };
    let previous = parent.and_then(|parent| find_method(session, parent, &model.name));
    let Some(previous) = previous else {
        virtuals.push(method);
        return;
    };
    if !same_signature(session, method, previous) {
        session.named_report(
            DiagnosticCode::IncompatibleMethodOverride,
            model.syntax,
            &model.name,
        );
    }
    for slot in virtuals.iter_mut().filter(|slot| **slot == previous) {
        *slot = method;
    }
}
