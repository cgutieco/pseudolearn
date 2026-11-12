use crate::context::{AotRuntimeContext, STATUS_CONTINUE, STATUS_UNWIND};
use crate::guard::{Entry, with_entry};
use crate::task_baton::Turn;
use crate::task_state::{Landing, SuspendedFrames, Wakeup};
use crate::trap::Trap;
use pseudolearn_runtime::TaskId;

pub(crate) enum Resumed {
    Continue,
    Status(u32),
}

pub(crate) fn block_current(context: *mut AotRuntimeContext, site: u32) -> Resumed {
    let parked = with_entry(context, site, |entry| park(entry, site));
    let (baton, owner) = match parked {
        Some(Ok(parked)) => parked,
        Some(Err(status)) => return Resumed::Status(status),
        None => return Resumed::Status(crate::context::STATUS_FAILED),
    };
    if baton.wait_for(owner.0) == Turn::Exit {
        return Resumed::Status(STATUS_UNWIND);
    }
    match with_entry(context, site, resume_here) {
        Some(resumed) => resumed,
        None => Resumed::Status(crate::context::STATUS_FAILED),
    }
}

type Parked = (std::sync::Arc<crate::task_baton::Baton>, TaskId);

fn park(entry: &mut Entry<'_>, site: u32) -> Result<Parked, u32> {
    match switch_away(entry, site) {
        Ok(parked) => {
            entry.context.fault_status = STATUS_UNWIND;
            entry.context.unwind_depth = 0;
            Ok(parked)
        }
        Err(trap) => {
            restore_frames(entry);
            let status = entry.fail(trap);
            crate::task_scheduler::terminate(entry, status);
            Err(status)
        }
    }
}

fn switch_away(entry: &mut Entry<'_>, site: u32) -> Result<Parked, Trap> {
    let roots = std::mem::take(&mut entry.engine.roots);
    let cells = std::mem::take(&mut entry.engine.cells);
    let root_top = entry.context.root_top;
    let budget = entry.context.instruction_remaining;
    let tasks = entry.engine.tasks_mut()?;
    let owner = tasks.current;
    tasks.budget = budget;
    tasks.suspended.insert(
        owner,
        SuspendedFrames {
            roots,
            root_top,
            cells,
            site,
        },
    );
    let next = crate::task_scheduler::schedule_next(entry)?;
    crate::task_threads::hand_to(entry, next)?;
    let baton = std::sync::Arc::clone(&entry.engine.tasks_mut()?.baton);
    Ok((baton, owner))
}

fn restore_frames(entry: &mut Entry<'_>) {
    let Some(tasks) = entry.engine.tasks.as_deref_mut() else {
        return;
    };
    let owner = TaskId(u64::from(entry.context.task_identity));
    tasks.current = owner;
    if let Some(frames) = tasks.suspended.remove(&owner) {
        entry.engine.roots = frames.roots;
        entry.engine.cells = frames.cells;
    }
    entry.refresh();
}

fn resume_here(entry: &mut Entry<'_>) -> Resumed {
    let owner = TaskId(u64::from(entry.context.task_identity));
    let Some(tasks) = entry.engine.tasks.as_deref_mut() else {
        return Resumed::Status(crate::context::STATUS_FAILED);
    };
    let wakeup = tasks.wakeups.remove(&owner).unwrap_or(Wakeup::Continue);
    entry.context.instruction_remaining = tasks.budget;
    restore_frames(entry);
    entry.context.quantum_mass = 0;
    entry.context.fault_status = STATUS_CONTINUE;
    entry.context.unwind_depth = 0;
    match wakeup {
        Wakeup::Continue => Resumed::Continue,
        Wakeup::Land(landing) => request_landing(entry, landing),
        Wakeup::Terminate(status) => {
            entry.context.fault_status = status;
            Resumed::Status(status)
        }
    }
}

pub(crate) fn request_landing(entry: &mut Entry<'_>, landing: Landing) -> Resumed {
    if let Some(tasks) = entry.engine.tasks.as_deref_mut() {
        let owner = tasks.current;
        tasks.pending_landings.insert(owner, landing);
    }
    Resumed::Status(unwind_to(entry, landing.depth))
}

pub(crate) fn unwind_to(entry: &mut Entry<'_>, depth: u32) -> u32 {
    entry.context.fault_status = STATUS_UNWIND;
    entry.context.unwind_depth = depth;
    STATUS_UNWIND
}
