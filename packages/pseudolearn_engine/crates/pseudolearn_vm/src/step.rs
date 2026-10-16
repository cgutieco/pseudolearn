#![forbid(unsafe_code)]

use crate::events::{TraceClass, TraceEvent};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum StepAction {
    Into,
    Over,
    Out,
    ToLine(u32),
}

pub fn step_next(events: &[TraceEvent], from_index: usize) -> usize {
    from_index.saturating_add(1).min(events.len())
}

pub fn step_into(events: &[TraceEvent], from_index: usize) -> usize {
    let start = from_index.saturating_add(1);
    for (offset, event) in events.iter().enumerate().skip(start) {
        if event.class == TraceClass::StatementEntered {
            return offset;
        }
    }
    events.len()
}

pub fn step_over(events: &[TraceEvent], from_index: usize) -> usize {
    let current_depth = events.get(from_index).map(|event| event.depth).unwrap_or(0);
    let start = from_index.saturating_add(1);
    for (offset, event) in events.iter().enumerate().skip(start) {
        if event.class == TraceClass::StatementEntered && event.depth <= current_depth {
            return offset;
        }
    }
    events.len()
}

pub fn step_out(events: &[TraceEvent], from_index: usize) -> usize {
    let current_depth = events.get(from_index).map(|event| event.depth).unwrap_or(0);
    let start = from_index.saturating_add(1);
    for (offset, event) in events.iter().enumerate().skip(start) {
        if event.class == TraceClass::Return && event.depth == current_depth {
            return offset;
        }
    }
    events.len()
}

pub fn step_to_line(events: &[TraceEvent], from_index: usize, target_line: u32) -> usize {
    let start = from_index.saturating_add(1);
    for (offset, event) in events.iter().enumerate().skip(start) {
        if event.class == TraceClass::StatementEntered && event.line == target_line {
            return offset;
        }
    }
    events.len()
}

pub fn advance_step(events: &[TraceEvent], from_index: usize, action: StepAction) -> usize {
    match action {
        StepAction::Into => step_into(events, from_index),
        StepAction::Over => step_over(events, from_index),
        StepAction::Out => step_out(events, from_index),
        StepAction::ToLine(target_line) => step_to_line(events, from_index, target_line),
    }
}
