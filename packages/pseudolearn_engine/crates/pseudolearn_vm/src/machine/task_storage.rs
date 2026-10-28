use super::{Machine, TaskContext};
use crate::Fault;
use pseudolearn_runtime::{Handle, TaskId};

impl Machine<'_> {
    pub(super) fn allocate_task_storage(
        &mut self,
        (task, scope): (TaskId, u64),
        context: &TaskContext,
        roots: &[Handle],
    ) -> Result<(), Fault> {
        let mut retained = roots.to_vec();
        retained.extend(context.spills.iter().map(|frame| frame.handle));
        let storage = pseudolearn_runtime::task_storage::new_task_storage(
            &mut self.heap,
            pseudolearn_runtime::task_storage::TaskStorage {
                identity: task.0,
                parent: self.tasks.current.0,
                scope,
                continuation: context
                    .spills
                    .last()
                    .map_or(Handle(0), |frame| frame.handle),
            },
            &retained,
        )
        .map_err(super::memory::memory_fault)?;
        self.tasks.task_storage.insert(task, storage);
        Ok(())
    }

    pub(super) fn link_task_continuation(
        &mut self,
        task: TaskId,
        context: &TaskContext,
    ) -> Result<(), Fault> {
        if let Some(storage) = self.tasks.task_storage.get(&task).copied() {
            let continuation = context
                .spills
                .last()
                .map_or(Handle(0), |frame| frame.handle);
            pseudolearn_runtime::task_storage::set_task_continuation(
                &mut self.heap,
                storage,
                continuation,
            )
            .map_err(super::memory::memory_fault)?;
        }
        Ok(())
    }

    pub(super) fn clear_task_continuation(&mut self, task: TaskId) -> Result<(), Fault> {
        if let Some(storage) = self.tasks.task_storage.get(&task).copied() {
            pseudolearn_runtime::task_storage::set_task_continuation(
                &mut self.heap,
                storage,
                Handle(0),
            )
            .map_err(super::memory::memory_fault)?;
        }
        Ok(())
    }
}
