use crate::program_view::{ProgramView, SpanKey, span_json};
use crate::program_view_kind::ViewKind;
use pseudolearn_bytecode::SourceSpan;
use pseudolearn_vm::{TraceClass, TraceEvent};
use serde_json::{Value, json};

pub(crate) fn source_of(view: &ProgramView, event: &TraceEvent) -> Value {
    let Some(span) = event.span else {
        return Value::Null;
    };
    let Some(ordinal) = resolve(view, span, event.class) else {
        return Value::Null;
    };
    let Some(node) = view.node(ordinal) else {
        return Value::Null;
    };
    json!({
        "revision_id": view.revision(),
        "node_id": view.node_identifier(ordinal),
        "span": span_json(node),
    })
}

fn resolve(view: &ProgramView, span: SourceSpan, class: TraceClass) -> Option<usize> {
    let key: SpanKey = (
        (span.start_line, span.start_column),
        (span.end_line, span.end_column),
    );
    let preference = preference_for(class);
    let matches = view.exact_matches(&key);
    for kind in preference {
        let found = matches
            .iter()
            .copied()
            .find(|ordinal| view.node(*ordinal).is_some_and(|node| node.kind == kind));
        if found.is_some() {
            return found;
        }
    }
    matches
        .first()
        .copied()
        .or_else(|| innermost_containing(view, &key))
}

fn preference_for(class: TraceClass) -> [ViewKind; 3] {
    match class {
        TraceClass::Decision | TraceClass::Call | TraceClass::Return => [
            ViewKind::Expression,
            ViewKind::Statement,
            ViewKind::Declaration,
        ],
        _ => [
            ViewKind::Statement,
            ViewKind::Declaration,
            ViewKind::Expression,
        ],
    }
}

fn innermost_containing(view: &ProgramView, key: &SpanKey) -> Option<usize> {
    let mut best: Option<usize> = None;
    let mut ordinal = 0;
    while let Some(node) = view.node(ordinal) {
        if node.start <= key.0 && key.1 <= node.end {
            best = Some(ordinal);
        }
        ordinal = ordinal.saturating_add(1);
    }
    best
}
