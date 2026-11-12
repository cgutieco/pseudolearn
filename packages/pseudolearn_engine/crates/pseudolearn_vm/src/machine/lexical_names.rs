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

pub(super) fn current_window(
    machine: &Machine<'_>,
    range: (usize, usize),
) -> (BTreeMap<Register, String>, usize) {
    select_window(
        &machine.current,
        (
            machine.cursor.program_counter.saturating_sub(1),
            machine.probed,
        ),
        range,
    )
}

pub(super) fn suspended_window(
    machine: &Machine<'_>,
    frame: &ControlFrame,
    range: (usize, usize),
) -> (BTreeMap<Register, String>, usize) {
    let mut counter = frame
        .function
        .continuations
        .get(frame.return_point)
        .copied()
        .unwrap_or(0);
    if machine.probed {
        counter = frame
            .function
            .fast_to_probed_returns
            .get(counter)
            .copied()
            .unwrap_or(0);
    }
    select_window(
        &frame.function,
        (counter.saturating_sub(1), machine.probed),
        range,
    )
}

fn select_window(
    function: &LoadedFunction,
    location: (usize, bool),
    range: (usize, usize),
) -> (BTreeMap<Register, String>, usize) {
    let point = point(function, location);
    let selected = |register: Register, name: &str| winner(function, point, name) == Some(register);
    let total = function
        .names
        .iter()
        .filter(|(register, name)| selected(**register, name))
        .count();
    let end = range.0.saturating_add(range.1);
    let mut names = BTreeMap::new();
    for (register, name) in &function.names {
        if !selected(*register, name) {
            continue;
        }
        let rank = function
            .names
            .iter()
            .filter(|(candidate, text)| {
                text.as_str() < name.as_str() && selected(**candidate, text)
            })
            .count();
        if rank >= range.0 && rank < end {
            names.insert(*register, name.clone());
        }
    }
    (names, total)
}

fn winner(function: &LoadedFunction, point: Option<SourceSpan>, name: &str) -> Option<Register> {
    function
        .names
        .iter()
        .filter(|(register, text)| {
            text.as_str() == name
                && function
                    .visibility
                    .get(register)
                    .is_none_or(|scope| point.is_some_and(|point| scope.contains_start(point)))
        })
        .max_by_key(|(register, _)| {
            (
                function
                    .visibility
                    .get(register)
                    .map(|span| (span.start_line, span.start_column)),
                **register,
            )
        })
        .map(|(register, _)| *register)
}
