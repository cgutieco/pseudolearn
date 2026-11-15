use crate::guard::Entry;
use crate::trap::Trap;

pub(crate) fn deadlock(entry: &mut Entry<'_>) -> Trap {
    let mut trap = Trap::named("taskDeadlock");
    if let Some(tasks) = entry.engine.tasks.as_deref() {
        for (task, frames) in &tasks.suspended {
            if tasks.agenda.state(*task) == Some(pseudolearn_runtime::TaskState::Waiting) {
                trap.related.push(entry.engine.site_range(frames.site));
            }
        }
    }
    trap
}
