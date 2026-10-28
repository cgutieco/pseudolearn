use super::{TaskAgenda, TaskAgendaError, TaskId};

pub struct TaskCancellation<'agenda> {
    pub(super) agenda: &'agenda mut TaskAgenda,
}

impl TaskCancellation<'_> {
    pub fn request(&mut self, task: TaskId) -> Result<bool, TaskAgendaError> {
        self.agenda.request_cancel(task)
    }

    pub fn begin_cleanup(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda.begin_cleanup(task)
    }

    pub fn finish(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda.transition(
            task,
            super::TaskState::Cleaning,
            super::TaskState::Cancelled,
        )?;
        self.agenda.wake_completed_dependents(task)?;
        Ok(())
    }

    pub fn order(&self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        self.agenda.cancellation_order(task)
    }

    pub fn request_subtree(&mut self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        let order = self.agenda.cancellation_order(task)?;
        let mut requested = Vec::new();
        for child in order {
            if self.agenda.request_cancel(child)? {
                requested.push(child);
            }
        }
        Ok(requested)
    }

    pub fn abandoned_effects(&self) -> &[(TaskId, u64)] {
        &self.agenda.abandoned_effects
    }
}

pub fn task_scope(agenda: &TaskAgenda, task: TaskId) -> Option<super::TaskScopeId> {
    agenda.tasks.get(&task)?.scope
}

pub fn scope_owner(agenda: &TaskAgenda, scope: super::TaskScopeId) -> Option<TaskId> {
    Some(agenda.scopes.get(&scope)?.owner)
}

impl TaskCancellation<'_> {
    pub fn take_cleanup(&mut self) -> Result<Option<TaskId>, TaskAgendaError> {
        let candidate = self.agenda.tasks.iter().find_map(|(task, entry)| {
            (entry.state == super::TaskState::CancelRequested
                && entry.children.iter().all(|child| {
                    self.agenda
                        .state(*child)
                        .is_some_and(super::TaskState::is_terminal)
                }))
            .then_some(*task)
        });
        if let Some(task) = candidate {
            self.agenda.begin_cleanup(task)?;
        }
        Ok(candidate)
    }
}

pub fn task_wait(agenda: &TaskAgenda, task: TaskId) -> Option<super::TaskWaitReason> {
    agenda.tasks.get(&task)?.waiting
}

pub fn interrupt_owner(
    agenda: &mut TaskAgenda,
    task: TaskId,
) -> Result<super::TaskWake, TaskAgendaError> {
    if let Some(super::TaskWaitReason::Effect(sequence)) =
        agenda.tasks.get(&task).and_then(|entry| entry.waiting)
    {
        agenda.abandoned_effects.push((task, sequence));
    }
    let wake = agenda.wake(task)?;
    agenda.ready.push_back(task);
    Ok(wake)
}

pub fn scope_children(agenda: &TaskAgenda, scope: super::TaskScopeId) -> Vec<TaskId> {
    agenda
        .scopes
        .get(&scope)
        .map(|scope| scope.children.clone())
        .unwrap_or_default()
}
