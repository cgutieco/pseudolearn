use crate::context::{AotRuntimeContext, STATUS_CONTINUE, STATUS_FAILED};
use crate::guard::{Entry, run_entry, with_entry};
use crate::task_state::Landing;
use crate::task_switch::{Resumed, request_landing, unwind_to};
use crate::trap::Trap;
use pseudolearn_runtime::{TaskScopeId, TaskState};

fn landing_here(entry: &Entry<'_>, index: u32) -> Landing {
    Landing {
        depth: entry.context.frame_depth,
        index,
        root_top: entry.context.root_top,
        cells: entry.engine.cells.len(),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_cancel_point(
    context: *mut AotRuntimeContext,
    site: u32,
    index: u32,
) -> u32 {
    run_entry(context, site, |entry| {
        let landing = landing_here(entry, index);
        let tasks = entry.engine.tasks_mut()?;
        let current = tasks.current;
        tasks
            .cancel_points
            .entry(current)
            .or_default()
            .insert(landing.depth, landing);
        Ok(0)
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_scope_boundary(
    context: *mut AotRuntimeContext,
    site: u32,
    scope: u64,
    index: u32,
) -> u32 {
    run_entry(context, site, |entry| {
        let landing = landing_here(entry, index);
        let tasks = entry.engine.tasks_mut()?;
        tasks.scope_resumes.insert(TaskScopeId(scope), landing);
        Ok(0)
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_land(context: *mut AotRuntimeContext, site: u32) -> u32 {
    run_entry(context, site, |entry| {
        let tasks = entry.engine.tasks_mut()?;
        let current = tasks.current;
        let landing = tasks
            .pending_landings
            .remove(&current)
            .ok_or_else(|| Trap::named("internalFault"))?;
        entry.context.frame_depth = landing.depth;
        entry.context.root_top = landing.root_top;
        entry.context.fault_status = STATUS_CONTINUE;
        entry.context.unwind_depth = 0;
        entry.engine.cells.truncate(landing.cells);
        Ok(u64::from(landing.index))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_return(
    context: *mut AotRuntimeContext,
    site: u32,
    depth: u32,
) -> u32 {
    with_entry(context, site, |entry| match cleanup_return(entry, depth) {
        Ok(Resumed::Continue) => STATUS_CONTINUE,
        Ok(Resumed::Status(status)) => status,
        Err(trap) => entry.fail(trap),
    })
    .unwrap_or(STATUS_FAILED)
}

fn cleanup_return(entry: &mut Entry<'_>, depth: u32) -> Result<Resumed, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    if tasks.agenda.state(current) != Some(TaskState::Cleaning)
        || tasks.cleanup_depths.get(&current).copied() != Some(depth)
    {
        return Ok(Resumed::Continue);
    }
    let point = tasks
        .cancel_points
        .get_mut(&current)
        .and_then(|points| points.pop_last())
        .map(|(_, point)| point);
    match point {
        Some(point) => {
            tasks.cleanup_depths.insert(current, point.depth);
            Ok(request_landing(entry, point))
        }
        None => Ok(Resumed::Status(unwind_to(entry, 0))),
    }
}
