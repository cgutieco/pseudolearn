use super::{ExecutionResource, usage};
use crate::ApiError;
use crate::debug_model::DebugSession;
use pseudolearn_vm::machine_event_count;
use serde_json::{Value, json};

#[path = "debug_state.rs"]
mod debug_state;

impl ExecutionResource {
    pub(crate) fn debug_operation(
        &mut self,
        operation: &str,
        arguments: &Value,
    ) -> Result<Value, ApiError> {
        match operation {
            "debug_configure" => self.debug_configure(arguments),
            "debug_control" => self.debug_control(arguments),
            "debug_state" => self.debug_state(arguments),
            "inspect_expression" => self.inspect_expression(arguments),
            _ => self.history_events(arguments),
        }
    }

    fn debug_configure(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        let requested = arguments
            .get("breakpoints")
            .and_then(Value::as_array)
            .ok_or_else(|| usage("missing breakpoints"))?;
        if requested.len() > 4096 {
            return Err(usage("too many breakpoints"));
        }
        let breakpoints = requested
            .iter()
            .map(|entry| self.sources.breakpoint(&self.program, entry))
            .collect::<Result<Vec<_>, _>>()?;
        let entry = arguments
            .get("stop_on_entry")
            .and_then(Value::as_bool)
            .unwrap_or(false);
        let configured = DebugSession::new(entry, &breakpoints)?;
        if let Some(debug) = &mut self.debug {
            debug.breakpoints = configured.breakpoints;
        } else {
            self.debug = Some(configured);
        }
        Ok(
            json!({"breakpoints":breakpoints,"stop_generation":self.debug.as_ref().map_or(0,|debug| debug.generation)}),
        )
    }

    fn debug_control(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        let command = arguments
            .get("command")
            .and_then(Value::as_str)
            .ok_or_else(|| usage("missing debug command"))?;
        let task = arguments.get("task_id").and_then(Value::as_u64);
        let selected = task.unwrap_or_else(|| self.default_task());
        let event = self.debug.as_ref().and_then(|debug| debug.cursor);
        let machine = self.debug_machine(event, selected)?;
        let depth = u32::try_from(machine.active_frames_count())
            .map_err(|_| usage("frame depth overflow"))?;
        drop(machine);
        let debug = self
            .debug
            .as_mut()
            .ok_or_else(|| usage("debugging not configured"))?;
        if let Some(generation) = arguments.get("stop_generation").and_then(Value::as_u64)
            && generation != debug.generation
        {
            return Err(usage("obsolete debug stop"));
        }
        if command == "pause" {
            debug.history_direction = None;
            debug.stop("pause", task.unwrap_or(debug.task));
        } else {
            configure_control(
                debug,
                (command, Some(selected)),
                (
                    self.delivered,
                    self.retained_start.max(self.store.stats().horizon),
                ),
            )?;
            debug.depth = depth;
        }
        self.debug_state(arguments)
    }

    fn default_task(&self) -> u64 {
        self.debug.as_ref().map_or(0, |debug| {
            if debug.reason == "task_terminated" {
                self.machine.current_task_id()
            } else {
                debug.task
            }
        })
    }

    pub(crate) fn debug_state(&self, arguments: &Value) -> Result<Value, ApiError> {
        debug_state::capture(self, arguments)
    }

    pub(super) fn capture_debug_response(&mut self, response: &mut Value) -> Result<(), ApiError> {
        if self.debug.is_some() {
            self.delivered = machine_event_count(&self.machine);
            let state = self.debug_state(&json!({}))?;
            if let Some(fields) = response.as_object_mut() {
                fields.insert("debug".to_owned(), state);
            }
        }
        Ok(())
    }

    pub(super) fn observe_debug_events(&mut self, before: usize, task: u64) -> bool {
        let Some(debug) = &mut self.debug else {
            return false;
        };
        let events = pseudolearn_vm::machine_events(&self.machine);
        let dropped = machine_event_count(&self.machine).saturating_sub(events.len());
        for (offset, event) in events
            .iter()
            .enumerate()
            .skip(before.saturating_sub(dropped))
        {
            debug.observe(event, task, dropped.saturating_add(offset));
            if debug.stopped {
                break;
            }
        }
        debug.stopped
    }
}

fn configure_control(
    debug: &mut DebugSession,
    request: (&str, Option<u64>),
    window: (usize, usize),
) -> Result<(), ApiError> {
    let ((command, task), (delivered, first)) = (request, window);
    if !debug.stopped && debug.control_active {
        return Err(usage("debug control already active"));
    }
    if command == "step_back" {
        let cursor = debug.cursor.ok_or_else(|| usage("no retained event"))?;
        if cursor <= first {
            return Err(usage("event outside retained horizon"));
        }
        debug.history_direction = Some(true);
    } else {
        debug.command = crate::debug_model::command(command)?;
        debug.history_direction = debug
            .cursor
            .filter(|cursor| cursor.saturating_add(1) < delivered)
            .map(|_| false);
    }
    debug.task = task.unwrap_or(debug.task);
    debug.depth = debug.last.as_ref().map_or(1, |event| event.depth);
    debug.origin = debug.cursor;
    debug.stopped = false;
    debug.control_active = true;
    debug.generation = debug.generation.saturating_add(1);
    Ok(())
}

fn frame_range(arguments: &Value) -> Result<(usize, usize), ApiError> {
    let parse = |name: &str, default| match arguments.get(name) {
        None => Ok(default),
        Some(value) => value
            .as_u64()
            .and_then(|number| usize::try_from(number).ok())
            .ok_or_else(|| usage("invalid frame range")),
    };
    let start = parse("start_frame", 0)?;
    let count = parse("frame_count", 4096)?;
    if count > 4096 {
        return Err(usage("frame range exceeds limit"));
    }
    Ok((start, count))
}
