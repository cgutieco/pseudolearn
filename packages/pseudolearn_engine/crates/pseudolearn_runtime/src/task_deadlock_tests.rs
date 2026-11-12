use crate::{TaskAgenda, TaskAgendaError, TaskChannelId, TaskId, TaskProgress, task_progress};

#[test]
fn running_and_ready_tasks_prevent_deadlock() -> Result<(), TaskAgendaError> {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    assert_eq!(task_progress(&agenda), TaskProgress::Runnable);
    let scope = agenda.create_scope(root)?;
    agenda.spawn(scope)?;
    agenda.execution().waiting().for_scope(root, scope)?;
    assert_eq!(task_progress(&agenda), TaskProgress::Runnable);
    Ok(())
}

#[test]
fn root_waiting_on_an_open_channel_is_deadlocked() -> Result<(), TaskAgendaError> {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    agenda
        .execution()
        .waiting()
        .for_channel(root, TaskChannelId(1))?;
    let TaskProgress::Deadlocked(blocked) = task_progress(&agenda) else {
        return Err(TaskAgendaError::InvalidTransition);
    };
    assert_eq!(
        blocked
            .iter()
            .map(|blocked| blocked.task)
            .collect::<Vec<_>>(),
        vec![root]
    );
    Ok(())
}

#[test]
fn pending_effect_prevents_deadlock_but_abandoned_effect_does_not() -> Result<(), TaskAgendaError> {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let scope = agenda.create_scope(root)?;
    let child = agenda.spawn(scope)?;
    agenda
        .execution()
        .waiting()
        .for_channel(root, TaskChannelId(1))?;
    agenda.execution().begin(child)?;
    agenda.execution().waiting().for_effect(child, 9)?;
    assert_eq!(
        task_progress(&agenda),
        TaskProgress::AwaitingEffects(vec![(child, 9)])
    );
    agenda.cancellation().request(child)?;
    assert_eq!(task_progress(&agenda), TaskProgress::Runnable);
    agenda.cancellation().begin_cleanup(child)?;
    agenda.cancellation().finish(child)?;
    assert!(matches!(
        task_progress(&agenda),
        TaskProgress::Deadlocked(_)
    ));
    assert_eq!(agenda.cancellation().abandoned_effects(), &[(TaskId(1), 9)]);
    Ok(())
}

#[test]
fn completed_agenda_is_not_deadlocked() -> Result<(), TaskAgendaError> {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    agenda.execution().complete(root)?;
    assert_eq!(task_progress(&agenda), TaskProgress::Completed);
    Ok(())
}
