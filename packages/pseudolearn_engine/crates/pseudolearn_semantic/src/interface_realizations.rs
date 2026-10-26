use crate::identities::ClassId;
use crate::interface_model::InterfaceId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn satisfies(
    session: &AnalysisSession<'_>,
    mut class: ClassId,
    interface: InterfaceId,
) -> bool {
    for _ in 0..session.module.classes.len() {
        if session
            .module
            .realizations
            .get(&class)
            .is_some_and(|interfaces| interfaces.contains(&interface))
        {
            return true;
        }
        let Some(parent) = superclass(session, class) else {
            return false;
        };
        class = parent;
    }
    false
}

fn superclass(session: &AnalysisSession<'_>, class: ClassId) -> Option<ClassId> {
    let model = crate::hierarchy::class_model(session, class)?;
    model.superclass.or_else(|| {
        let parent = session
            .children(model.syntax)
            .into_iter()
            .filter(|node| session.kind(*node) == pseudolearn_syntax::NodeKind::Identifier)
            .nth(1)?;
        session.classes.get(&session.name(parent)).copied()
    })
}

pub(crate) fn check(session: &mut AnalysisSession<'_>) {
    for index in 0..session.module.classes.len() {
        let class = ClassId(u32::try_from(index).unwrap_or(u32::MAX));
        session.enter_class_id(class);
        for interface_index in 0..session.module.interfaces.len() {
            let interface = InterfaceId(u32::try_from(interface_index).unwrap_or(u32::MAX));
            if satisfies(session, class, interface) {
                check_methods(session, class, interface);
            }
        }
    }
}

fn check_methods(session: &mut AnalysisSession<'_>, class: ClassId, interface: InterfaceId) {
    let Some(model) = session
        .module
        .interfaces
        .get(usize::try_from(interface.0).unwrap_or(usize::MAX))
        .cloned()
    else {
        return;
    };
    let syntax = crate::hierarchy::class_model(session, class).map_or(0, |model| model.syntax);
    for expected in model.methods {
        let Some(function) = crate::hierarchy::find_method(session, class, &expected.name) else {
            report(
                session,
                DiagnosticCode::InterfaceMethodMissing,
                syntax,
                &expected,
            );
            continue;
        };
        let Some(method) = crate::hierarchy::function(session, function).cloned() else {
            continue;
        };
        validate_signature(session, &expected, function, &method);
    }
}

fn report(
    session: &mut AnalysisSession<'_>,
    code: DiagnosticCode,
    node: usize,
    expected: &crate::interface_model::InterfaceMethod,
) {
    session.named_report(code, node, &expected.name);
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.related.push(expected.span);
    }
}

fn validate_signature(
    session: &mut AnalysisSession<'_>,
    expected: &crate::interface_model::InterfaceMethod,
    function: crate::FunctionId,
    method: &crate::HirFunction,
) {
    if method.private {
        report(
            session,
            DiagnosticCode::InterfaceMethodNotPublic,
            method.syntax,
            expected,
        );
    } else if !crate::interface_signatures::matches(session, &expected.signature, function) {
        let existing = session.diagnostics.iter().any(|diagnostic| {
            diagnostic.code == DiagnosticCode::IncompatibleMethodOverride
                && diagnostic.span == method.span
        });
        if !existing {
            report(
                session,
                DiagnosticCode::InterfaceMethodSignatureMismatch,
                method.syntax,
                expected,
            );
        }
    }
}
