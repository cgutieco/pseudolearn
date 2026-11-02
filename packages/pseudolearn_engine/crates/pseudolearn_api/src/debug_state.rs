use super::super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_vm::{Machine, machine_output};
use serde_json::{Value, json};

pub(super) fn capture(execution: &ExecutionResource, arguments: &Value) -> Result<Value, ApiError> {
    let debug = execution
        .debug
        .as_ref()
        .ok_or_else(|| usage("debugging not configured"))?;
    let requested_event = arguments
        .get("event")
        .map(|value| {
            value
                .as_u64()
                .and_then(|number| usize::try_from(number).ok())
                .ok_or_else(|| usage("invalid debug event"))
        })
        .transpose()?;
    let requested_task = arguments
        .get("task_id")
        .map(|value| value.as_u64().ok_or_else(|| usage("invalid debug task")))
        .transpose()?;
    let task = match (requested_event, requested_task) {
        (Some(_), None) => return Err(usage("historical debug state requires task_id")),
        (_, Some(task)) => task,
        (None, None) => debug.task,
    };
    let ended = requested_event.is_none()
        && debug.reason == "task_terminated"
        && arguments.get("task_id").is_none();
    let machine = match requested_event {
        Some(event) => execution.inspection_machine(event, Some(task))?,
        None => inspected_machine(execution, debug, task, ended)?,
    };
    let frames = if ended {
        Vec::new()
    } else {
        frames(execution, &machine, arguments)?
    };
    let total = if ended {
        0
    } else {
        machine.active_frames_count()
    };
    let event = requested_event.or(debug.cursor);
    let source = if requested_event.is_some() {
        Value::Null
    } else {
        debug
            .last
            .as_ref()
            .map(|event| execution.sources.event(event))
            .unwrap_or(Value::Null)
    };
    Ok(
        json!({"stop_generation":debug.generation,"event":event,"live_event":execution.delivered.checked_sub(1),
        "reason":debug.reason,"stopped":debug.stopped,"task_id":task,"threads":threads(&machine),"frames":frames,
        "total_frames":total,"sources":execution.sources.snapshot(),"source":source,
        "termination":execution.terminal.as_ref().map(crate::execution_wire::termination).unwrap_or(json!({"kind":"running"})),
        "output":machine_output(&execution.machine)}),
    )
}

fn inspected_machine<'execution>(
    execution: &'execution ExecutionResource,
    debug: &crate::debug_model::DebugSession,
    task: u64,
    ended: bool,
) -> Result<Machine<'execution>, ApiError> {
    if !ended {
        return execution.debug_machine(debug.cursor, task);
    }
    match debug
        .cursor
        .filter(|event| event.saturating_add(1) < execution.delivered)
    {
        Some(event) => execution.machine_at(event),
        None => execution
            .machine
            .task_inspection(execution.machine.current_task_id())
            .map_err(|_| usage("invalid task reference")),
    }
}

fn frames(
    execution: &ExecutionResource,
    machine: &Machine<'_>,
    arguments: &Value,
) -> Result<Vec<Value>, ApiError> {
    let (start, count) = super::frame_range(arguments)?;
    let total = machine.active_frames_count();
    Ok((start..start.saturating_add(count).min(total)).filter_map(|offset| {
        let position=total.checked_sub(offset.checked_add(1)?)?;
        let name=machine.frame_name(position)?;
        let span=machine.frame_location(position);
        let source=span.map_or(0,|span|span.source_id.value());
        Some(json!({"id":position,"frame":position,"name":name,"source_id":source,
            "revision":execution.sources.views.get(&source).map(|view|view.revision()),
            "line":span.map_or(1,|span|span.start_line),"column":span.map_or(1,|span|span.start_column)}))
    }).collect())
}

fn threads(machine: &Machine<'_>) -> Vec<Value> {
    let mut threads = machine
        .task_summaries()
        .iter()
        .map(|summary| {
            json!({"id":summary.task,
        "name":format!("Task {}",summary.task),"state":summary.state})
        })
        .collect::<Vec<_>>();
    if threads.is_empty() {
        threads.push(json!({"id":0,"name":"Root"}));
    }
    threads
}
