use super::{ControlFrame, Machine};
use crate::load::LoadedFunction;
use pseudolearn_bytecode::{Register, SourceSpan};
use std::collections::BTreeMap;

pub(super) fn current(machine: &Machine<'_>) -> BTreeMap<Register, String> {
    select(
        &machine.current,
        (
            machine.cursor.program_counter.saturating_sub(1),
            machine.probed,
        ),
    )
}

pub(super) fn suspended(machine: &Machine<'_>, frame: &ControlFrame) -> BTreeMap<Register, String> {
    let mut position = frame
        .function
        .continuations
        .get(frame.return_point)
        .copied()
        .unwrap_or(0);
    if machine.probed {
        position = frame
            .function
            .fast_to_probed_returns
            .get(position)
            .copied()
            .unwrap_or(0);
    }
    select(
        &frame.function,
        (position.saturating_sub(1), machine.probed),
    )
}

fn select(function: &LoadedFunction, location: (usize, bool)) -> BTreeMap<Register, String> {
    let point = point(function, location);
    let mut selected = BTreeMap::<String, (Register, Option<SourceSpan>)>::new();
    for (register, name) in &function.names {
        let scope = function.visibility.get(register).copied();
        if scope.is_some_and(|scope| !point.is_some_and(|point| scope.contains_start(point))) {
            continue;
        }
        let replace = selected.get(name).is_none_or(|(_, previous)| {
            previous.map(|span| (span.start_line, span.start_column))
                <= scope.map(|span| (span.start_line, span.start_column))
        });
        if replace {
            selected.insert(name.clone(), (*register, scope));
        }
    }
    selected
        .into_iter()
        .map(|(name, (register, _))| (register, name))
        .collect()
}

fn point(function: &LoadedFunction, (position, probed): (usize, bool)) -> Option<SourceSpan> {
    let (spans, origins) = if probed {
        (&function.probed_spans, &function.probed_origins)
    } else {
        (&function.spans, &function.origins)
    };
    let mut span = spans.get(position).copied().flatten()?;
    if origins
        .get(position)
        .and_then(|origin| origin.first)
        .is_some_and(|opcode| opcode.as_name() == "stmt.exit")
    {
        span.start_line = span.end_line;
        span.start_column = span.end_column.saturating_sub(1);
    }
    Some(span)
}
