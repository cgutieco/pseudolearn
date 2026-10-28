use super::{
    TaskAgenda, TaskAgendaError, TaskId, TaskScopeId, TaskState, TaskWaitReason, TaskWake,
};

impl TaskAgenda {
    pub fn take_ready(&mut self) -> Result<Option<TaskId>, TaskAgendaError> {
        while let Some(task) = self.ready.pop_front() {
            if self.state(task) == Some(TaskState::Ready) {
                self.transition(task, TaskState::Ready, TaskState::Running)?;
                return Ok(Some(task));
            }
        }
        Ok(None)
    }

    pub fn has_ready(&self) -> bool {
        self.ready
            .iter()
            .any(|task| self.state(*task) == Some(TaskState::Ready))
    }

    pub fn wake_completed_dependents(
        &mut self,
        completed: TaskId,
    ) -> Result<Vec<(TaskId, TaskWake)>, TaskAgendaError> {
        if !self.tasks.contains_key(&completed) {
            return Err(TaskAgendaError::UnknownTask);
        }
        let waiting = self
            .tasks
            .iter()
            .filter_map(|(task, entry)| {
                if entry.state != TaskState::Waiting {
                    return None;
                }
                match entry.waiting {
                    Some(TaskWaitReason::Task(awaited)) if awaited == completed => {
                        Some((*task, TaskWake::Task(completed)))
                    }
                    Some(TaskWaitReason::Scope(scope)) if self.scope_is_complete(scope) => {
                        Some((*task, TaskWake::Scope(scope)))
                    }
                    _ => None,
                }
            })
            .collect::<Vec<_>>();
        for (task, _) in &waiting {
            self.wake(*task)?;
            self.ready.push_back(*task);
        }
        Ok(waiting)
    }

    pub fn wake(&mut self, task: TaskId) -> Result<TaskWake, TaskAgendaError> {
        let entry = self
            .tasks
            .get_mut(&task)
            .ok_or(TaskAgendaError::UnknownTask)?;
        if entry.state != TaskState::Waiting {
            return Err(TaskAgendaError::InvalidTransition);
        }
        let waiting = entry
            .waiting
            .take()
            .ok_or(TaskAgendaError::InvalidTransition)?;
        entry.state = TaskState::Ready;
        match waiting {
            TaskWaitReason::Effect(sequence) => Ok(TaskWake::Effect(sequence)),
            TaskWaitReason::Channel(channel) => Ok(TaskWake::Channel(channel)),
            TaskWaitReason::Task(awaited) => Ok(TaskWake::Task(awaited)),
            TaskWaitReason::Scope(scope) => Ok(TaskWake::Scope(scope)),
        }
    }

    fn scope_is_complete(&self, scope: TaskScopeId) -> bool {
        self.scopes.get(&scope).is_some_and(|scope| {
            scope
                .children
                .iter()
                .all(|child| self.state(*child).is_some_and(TaskState::is_terminal))
        })
    }
}
