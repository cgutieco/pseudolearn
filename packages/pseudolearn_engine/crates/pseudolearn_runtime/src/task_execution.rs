use super::{
    TaskAgenda, TaskAgendaError, TaskChannelId, TaskId, TaskState, TaskWaitReason, TaskWake,
};

pub struct TaskExecution<'agenda> {
    pub(super) agenda: &'agenda mut TaskAgenda,
}

pub struct TaskWaiting<'agenda> {
    agenda: &'agenda mut TaskAgenda,
}

impl TaskExecution<'_> {
    pub fn take_ready(&mut self) -> Result<Option<TaskId>, TaskAgendaError> {
        self.agenda.take_ready()
    }

    pub fn begin(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda.ready.retain(|ready| *ready != task);
        self.agenda
            .transition(task, TaskState::Ready, TaskState::Running)
    }

    pub fn waiting(&mut self) -> TaskWaiting<'_> {
        TaskWaiting {
            agenda: self.agenda,
        }
    }

    pub fn resume(&mut self, task: TaskId) -> Result<TaskWake, TaskAgendaError> {
        let waiting = self.agenda.wake(task)?;
        self.agenda.ready.push_back(task);
        Ok(waiting)
    }

    pub fn complete(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda
            .transition(task, TaskState::Running, TaskState::Completed)?;
        self.agenda.wake_completed_dependents(task)?;
        Ok(())
    }

    pub fn yield_task(&mut self, task: TaskId) -> Result<(), TaskAgendaError> {
        self.agenda
            .transition(task, TaskState::Running, TaskState::Ready)?;
        self.agenda.ready.push_back(task);
        Ok(())
    }

    pub fn fail(&mut self, task: TaskId) -> Result<Vec<TaskId>, TaskAgendaError> {
        self.agenda.fail_task(task)
    }
}

impl TaskWaiting<'_> {
    pub fn for_effect(
        &mut self,
        task: TaskId,
        effect_sequence: u64,
    ) -> Result<(), TaskAgendaError> {
        self.wait(task, TaskWaitReason::Effect(effect_sequence))
    }

    pub fn for_channel(
        &mut self,
        task: TaskId,
        channel: TaskChannelId,
    ) -> Result<(), TaskAgendaError> {
        self.wait(task, TaskWaitReason::Channel(channel))
    }

    pub fn for_task(&mut self, task: TaskId, awaited: TaskId) -> Result<(), TaskAgendaError> {
        if self.agenda.state(awaited).is_none() {
            return Err(TaskAgendaError::UnknownTask);
        }
        self.wait(task, TaskWaitReason::Task(awaited))
    }

    pub fn for_scope(
        &mut self,
        task: TaskId,
        scope: super::TaskScopeId,
    ) -> Result<(), TaskAgendaError> {
        if !self.agenda.scopes.contains_key(&scope) {
            return Err(TaskAgendaError::UnknownScope);
        }
        self.wait(task, TaskWaitReason::Scope(scope))
    }

    fn wait(&mut self, task: TaskId, reason: TaskWaitReason) -> Result<(), TaskAgendaError> {
        let entry = self
            .agenda
            .tasks
            .get_mut(&task)
            .ok_or(TaskAgendaError::UnknownTask)?;
        if entry.state != TaskState::Running {
            return Err(TaskAgendaError::InvalidTransition);
        }
        entry.state = TaskState::Waiting;
        entry.waiting = Some(reason);
        Ok(())
    }
}
