use crate::hir::Passing;
use crate::identities::{FunctionId, LocalId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, local: LocalId, node: usize) -> LocalId {
    let Some(declaration) = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .cloned()
    else {
        return local;
    };
    if declaration.scope == session.current || session.closure_stack.is_empty() {
        return local;
    }
    if declaration.mutable || declaration.passing == Passing::Reference {
        let kind = session.module.types.get(declaration.type_id);
        let argument = crate::diagnostic_arguments::type_argument(session, &kind);
        session.named_report(
            DiagnosticCode::MutableClosureCapture,
            node,
            &declaration.name,
        );
        if let Some(diagnostic) = session.diagnostics.last_mut() {
            diagnostic.related.push(declaration.span);
            diagnostic.arguments.insert("type".to_owned(), argument);
        }
        return local;
    }
    session.reads.insert(local);
    let frames = session.closure_stack.clone();
    let start = frames
        .iter()
        .position(|frame| frame.function == declaration.scope)
        .map_or(0, |index| index.saturating_add(1));
    let mut captured = local;
    for frame in frames.into_iter().skip(start) {
        captured = capture(session, frame.function, captured);
    }
    captured
}

fn capture(session: &mut AnalysisSession<'_>, function: FunctionId, original: LocalId) -> LocalId {
    if let Some(proxy) = session.module.closures.get(&function).and_then(|closure| {
        closure
            .captures
            .iter()
            .find(|(source, _)| *source == original)
            .map(|(_, proxy)| *proxy)
    }) {
        return proxy;
    }
    let Some(local) = usize::try_from(original.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .cloned()
    else {
        return original;
    };
    let parent = std::mem::replace(&mut session.current, function);
    let proxy = crate::closure_locals::create(session, local.name, local.type_id, false);
    if let Some(captured) = usize::try_from(proxy.0)
        .ok()
        .and_then(|index| session.module.locals.get_mut(index))
    {
        captured.span = local.span;
    }
    session.current = parent;
    session.reads.insert(proxy);
    if let Some(closure) = session.module.closures.get_mut(&function) {
        closure.captures.push((original, proxy));
    }
    proxy
}
