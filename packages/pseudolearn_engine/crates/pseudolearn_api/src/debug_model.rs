use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_vm::{TraceClass, TraceEvent};
use serde_json::Value;

#[derive(Clone, Copy, PartialEq)]
pub(crate) enum DebugCommand {
    Continue,
    Next,
    StepIn,
    StepOut,
}

pub(crate) struct DebugSession {
    pub(crate) breakpoints: Vec<(u32, u32, u32)>,
    pub(crate) command: DebugCommand,
    pub(crate) entry: bool,
    pub(crate) stopped: bool,
    pub(crate) reason: &'static str,
    pub(crate) generation: u64,
    pub(crate) cursor: Option<usize>,
    pub(crate) task: u64,
    pub(crate) depth: u32,
    pub(crate) origin: Option<usize>,
    pub(crate) last: Option<TraceEvent>,
    pub(crate) history_direction: Option<bool>,
    pub(crate) control_active: bool,
}

impl DebugSession {
    pub(crate) fn new(entry: bool, breakpoints: &[Value]) -> Result<Self, ApiError> {
        let mut locations = Vec::new();
        for breakpoint in breakpoints
            .iter()
            .filter(|value| value.get("verified") == Some(&Value::Bool(true)))
        {
            let coordinate = |key: &str| {
                breakpoint
                    .get(key)
                    .and_then(Value::as_u64)
                    .and_then(|number| u32::try_from(number).ok())
                    .ok_or_else(|| usage("invalid breakpoint coordinate"))
            };
            locations.push((
                coordinate("source_id")?,
                coordinate("line")?,
                coordinate("column")?,
            ));
        }
        Ok(Self {
            breakpoints: locations,
            command: DebugCommand::Continue,
            entry,
            stopped: false,
            reason: "entry",
            generation: 0,
            cursor: None,
            task: 0,
            depth: 1,
            origin: None,
            last: None,
            history_direction: None,
            control_active: false,
        })
    }

    pub(crate) fn observe(&mut self, event: &TraceEvent, task: u64, index: usize) {
        self.last = Some(event.clone());
        self.cursor = Some(index);
        if let Some((reason, stopped_task)) = self.stop_reason(event, task, index) {
            self.stop(reason, stopped_task);
        }
    }

    fn stop_reason(
        &mut self,
        event: &TraceEvent,
        task: u64,
        index: usize,
    ) -> Option<(&'static str, u64)> {
        let statement = event.class == TraceClass::StatementEntered;
        let breakpoint = event.span.is_some_and(|span| {
            self.breakpoints
                .contains(&(span.source_id.value(), span.start_line, span.start_column))
        });
        if self.command != DebugCommand::Continue && completed_task(event) == Some(self.task) {
            return Some(("task_terminated", self.task));
        }
        if statement && self.entry {
            self.entry = false;
            return Some(("entry", task));
        }
        if statement && breakpoint {
            return Some(("breakpoint", task));
        }
        self.stepping(event, task, index).then_some(("step", task))
    }

    fn stepping(&self, event: &TraceEvent, task: u64, index: usize) -> bool {
        if task != self.task || self.origin == Some(index) {
            return false;
        }
        let statement = event.class == TraceClass::StatementEntered;
        match self.command {
            DebugCommand::Continue => false,
            DebugCommand::Next => statement && event.depth <= self.depth,
            DebugCommand::StepIn => statement,
            DebugCommand::StepOut => {
                self.depth > task_floor(task)
                    && event.class == TraceClass::Return
                    && event.depth < self.depth
            }
        }
    }

    pub(crate) fn stop(&mut self, reason: &'static str, task: u64) {
        self.control_active = false;
        self.stopped = true;
        self.reason = reason;
        self.task = task;
        self.generation = self.generation.saturating_add(1);
    }
}

pub(crate) fn command(text: &str) -> Result<DebugCommand, ApiError> {
    match text {
        "continue" => Ok(DebugCommand::Continue),
        "next" => Ok(DebugCommand::Next),
        "step_in" => Ok(DebugCommand::StepIn),
        "step_out" => Ok(DebugCommand::StepOut),
        _ => Err(usage("invalid debug control")),
    }
}

fn task_floor(task: u64) -> u32 {
    if task == 0 { 1 } else { 2 }
}

fn completed_task(event: &TraceEvent) -> Option<u64> {
    if event.class != TraceClass::TaskCompleted {
        return None;
    }
    let pseudolearn_vm::EventPayload::Fields(fields) = event.payload.as_ref()? else {
        return None;
    };
    fields
        .iter()
        .find_map(|(name, value)| match (*name, value) {
            ("task", pseudolearn_vm::EventField::Number(task)) => Some(*task),
            _ => None,
        })
}
