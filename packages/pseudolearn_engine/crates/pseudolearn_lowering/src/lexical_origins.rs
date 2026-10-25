use crate::spans::resolve_span;
use pseudolearn_ir::OriginEntry;
use pseudolearn_semantic::{HirModule, LocalId};
use pseudolearn_source::SourceText;

pub(crate) fn annotate(
    origins: &mut [OriginEntry],
    start: usize,
    module: &HirModule,
    source: &SourceText,
) {
    for origin in origins.iter_mut().skip(start) {
        let local = LocalId(origin.variable.0);
        let Some(mut span) = module.local_visibility.get(&local).copied() else {
            continue;
        };
        if let Some(declaration) = usize::try_from(local.0)
            .ok()
            .and_then(|index| module.locals.get(index))
        {
            span.start = span.start.max(declaration.span.start);
        }
        origin.visibility = resolve_span(span, source);
    }
}
