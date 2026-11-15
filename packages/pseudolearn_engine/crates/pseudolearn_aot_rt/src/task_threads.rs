use crate::context::{AotRuntimeContext, STATUS_CONTINUE, STATUS_UNWIND};
use crate::engine::AotEngine;
use crate::guard::{Entry, with_entry};
use crate::task_baton::{Baton, Turn};
use crate::task_state::TaskDispatcher;
use crate::task_values::TaskValue;
use crate::trap::Trap;
use pseudolearn_runtime::TaskId;
use std::sync::Arc;

const TASK_STACK_BYTES: usize = 64 << 20;

struct TaskStart {
    baton: Arc<Baton>,
    task: TaskId,
    engine: usize,
    frame_limit: u32,
    root_capacity: u32,
    dispatcher: TaskDispatcher,
    function: u32,
    arguments: Vec<TaskValue>,
}

pub(crate) fn hand_to(entry: &mut Entry<'_>, next: TaskId) -> Result<(), Trap> {
    let frame_limit = entry.context.frame_limit;
    let root_capacity = entry.context.root_capacity;
    let engine = std::ptr::from_mut::<AotEngine>(entry.engine).expose_provenance();
    let tasks = entry.engine.tasks_mut()?;
    let start = tasks.pending_starts.remove(&next);
    tasks.baton.hand_to(next.0);
    let Some(start) = start else {
        return Ok(());
    };
    let begin = TaskStart {
        baton: Arc::clone(&tasks.baton),
        task: next,
        engine,
        frame_limit,
        root_capacity,
        dispatcher: tasks
            .dispatcher
            .ok_or_else(|| Trap::named("internalFault"))?,
        function: start.function,
        arguments: start.arguments,
    };
    std::thread::Builder::new()
        .stack_size(TASK_STACK_BYTES)
        .spawn(move || run_task(begin))
        .map(|_| ())
        .map_err(|_| Trap::named("resourceLimit"))
}

fn run_task(start: TaskStart) {
    if start.baton.wait_for(start.task.0) == Turn::Exit {
        return;
    }
    let mut roots = vec![0_u32; usize::try_from(start.root_capacity).unwrap_or(0)];
    let mut context = Box::new(new_context(&start, roots.as_mut_ptr()));
    let pointer = std::ptr::from_mut::<AotRuntimeContext>(&mut context);
    let words: Vec<u64> = start.arguments.iter().map(|value| value.word()).collect();
    let installed = with_entry(pointer, 0, |entry| install(entry, roots, &start.arguments));
    if !matches!(installed, Some(Ok(()))) {
        return;
    }
    (start.dispatcher)(pointer, start.function, words.as_ptr());
    let status = context.fault_status;
    if crate::task_scheduler::already_terminated() {
        return;
    }
    let _finished = with_entry(pointer, 0, |entry| {
        if status == STATUS_CONTINUE || status == STATUS_UNWIND {
            crate::task_completion::finish_task(entry)
        } else {
            crate::task_scheduler::terminate(entry, status);
        }
    });
}

fn new_context(start: &TaskStart, roots: *mut u32) -> AotRuntimeContext {
    AotRuntimeContext {
        heap_words_pointer: std::ptr::null_mut(),
        instruction_remaining: 0,
        frame_depth: 0,
        frame_limit: start.frame_limit,
        root_top: 0,
        root_capacity: start.root_capacity,
        roots_pointer: roots,
        fault_site: 0,
        fault_status: 0,
        result_word: 0,
        engine_state: std::ptr::with_exposed_provenance_mut(start.engine),
        cells_pointer: std::ptr::null(),
        cells_length: 0,
        heap_used: 0,
        heap_limit: 0,
        heap_ordinal: 0,
        room_cells: 0,
        room_threshold: 0,
        free_size_mask: 0,
        pending_pointer: std::ptr::null_mut(),
        pending_length: 0,
        pending_capacity: 0,
        quantum_mass: 0,
        unwind_depth: 0,
        task_identity: u32::try_from(start.task.0).unwrap_or(u32::MAX),
        caller_site: crate::context::NO_CALLER_SITE,
    }
}

fn install(entry: &mut Entry<'_>, roots: Vec<u32>, arguments: &[TaskValue]) -> Result<(), Trap> {
    entry.engine.roots = roots;
    entry.engine.cells = Vec::new();
    for (slot, handle) in entry
        .engine
        .roots
        .iter_mut()
        .zip(arguments.iter().filter_map(|value| value.root()))
    {
        *slot = handle.0;
        entry.context.root_top = entry.context.root_top.saturating_add(1);
    }
    let tasks = entry.engine.tasks_mut()?;
    entry.context.instruction_remaining = tasks.budget;
    entry.refresh();
    Ok(())
}
