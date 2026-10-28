use crate::{
    TaskAgenda, TaskAgendaError, TaskChannelId, TaskId, TaskScopeId, TaskScopeJoin, TaskState,
    TaskWake,
};

#[test]
fn assigns_monotonic_ids_and_joins_completed_children_without_waiting() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    assert_eq!(root, TaskId(0));
    let Ok(scope) = agenda.create_scope(root) else {
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(agenda.state(TaskId(1)), Some(TaskState::Ready));
    assert_eq!(agenda.execution().begin(TaskId(1)), Ok(()));
    assert_eq!(agenda.execution().complete(TaskId(1)), Ok(()));
    assert_eq!(agenda.close_scope(scope), Ok(TaskScopeJoin::Joined));
}

#[test]
fn reports_children_that_still_need_to_be_joined() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let scope = agenda.create_scope(root);
    let Ok(scope) = scope else {
        assert_eq!(scope, Err(TaskAgendaError::UnknownTask));
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(
        agenda.close_scope(scope),
        Ok(TaskScopeJoin::Waiting(vec![TaskId(1)]))
    );
}

#[test]
fn orders_nested_cancellation_before_parent_and_abandons_waiting_effects() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let outer_scope = agenda.create_scope(root);
    let Ok(outer_scope) = outer_scope else {
        return;
    };
    assert_eq!(agenda.spawn(outer_scope), Ok(TaskId(1)));
    let nested_scope = agenda.create_scope(TaskId(1));
    let Ok(nested_scope) = nested_scope else {
        return;
    };
    assert_eq!(agenda.spawn(nested_scope), Ok(TaskId(2)));
    assert_eq!(agenda.execution().begin(TaskId(2)), Ok(()));
    assert_eq!(
        agenda.execution().waiting().for_effect(TaskId(2), 7),
        Ok(())
    );
    assert_eq!(
        agenda.cancellation().order(TaskId(1)),
        Ok(vec![TaskId(2), TaskId(1)])
    );
    assert_eq!(
        agenda.cancellation().request_subtree(TaskId(1)),
        Ok(vec![TaskId(2), TaskId(1)])
    );
    assert_eq!(agenda.cancellation().abandoned_effects(), &[(TaskId(2), 7)]);
    assert_eq!(
        agenda.cancellation().begin_cleanup(TaskId(1)),
        Err(TaskAgendaError::InvalidTransition)
    );
    assert_eq!(agenda.cancellation().begin_cleanup(TaskId(2)), Ok(()));
    assert_eq!(agenda.cancellation().finish(TaskId(2)), Ok(()));
    assert_eq!(agenda.cancellation().begin_cleanup(TaskId(1)), Ok(()));
    assert_eq!(agenda.cancellation().finish(TaskId(1)), Ok(()));
}

#[test]
fn refuses_to_cancel_a_running_task() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    assert_eq!(agenda.cancellation().request(root), Ok(false));
    assert_eq!(agenda.state(TaskId(0)), Some(TaskState::Running));
}

#[test]
fn sibling_failure_requests_cancellation_and_abandons_effects() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let scope = agenda.create_scope(root);
    let Ok(scope) = scope else {
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(agenda.spawn(scope), Ok(TaskId(2)));
    assert_eq!(agenda.execution().begin(TaskId(1)), Ok(()));
    assert_eq!(
        agenda.execution().waiting().for_effect(TaskId(1), 11),
        Ok(())
    );
    assert_eq!(agenda.execution().begin(TaskId(2)), Ok(()));
    assert_eq!(agenda.execution().fail(TaskId(2)), Ok(vec![TaskId(1)]));
    assert_eq!(agenda.state(TaskId(1)), Some(TaskState::CancelRequested));
    assert_eq!(agenda.state(TaskId(2)), Some(TaskState::Failed));
    assert_eq!(
        agenda.cancellation().abandoned_effects(),
        &[(TaskId(1), 11)]
    );
}

#[test]
fn resumes_channel_waits_with_their_channel_identity() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let scope = agenda.create_scope(root);
    let Ok(scope) = scope else {
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(agenda.execution().begin(TaskId(1)), Ok(()));
    assert_eq!(
        agenda
            .execution()
            .waiting()
            .for_channel(TaskId(1), TaskChannelId(4)),
        Ok(())
    );
    assert_eq!(
        agenda.execution().resume(TaskId(1)),
        Ok(TaskWake::Channel(TaskChannelId(4)))
    );
    assert_eq!(agenda.state(TaskId(1)), Some(TaskState::Ready));
}

#[test]
fn cancelling_a_channel_wait_does_not_abandon_an_effect() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let scope = agenda.create_scope(root);
    let Ok(scope) = scope else {
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(agenda.spawn(scope), Ok(TaskId(2)));
    assert_eq!(agenda.execution().begin(TaskId(1)), Ok(()));
    assert_eq!(
        agenda
            .execution()
            .waiting()
            .for_channel(TaskId(1), TaskChannelId(9)),
        Ok(())
    );
    assert_eq!(agenda.execution().begin(TaskId(2)), Ok(()));
    assert_eq!(agenda.execution().fail(TaskId(2)), Ok(vec![TaskId(1)]));
    assert_eq!(agenda.state(TaskId(1)), Some(TaskState::CancelRequested));
    assert!(agenda.cancellation().abandoned_effects().is_empty());
}

#[test]
fn schedules_ready_tasks_in_fifo_order_after_a_yield() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let Ok(scope) = agenda.create_scope(root) else {
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(agenda.spawn(scope), Ok(TaskId(2)));
    assert_eq!(agenda.execution().take_ready(), Ok(Some(TaskId(1))));
    assert_eq!(agenda.execution().yield_task(TaskId(1)), Ok(()));
    assert_eq!(agenda.execution().take_ready(), Ok(Some(TaskId(2))));
    assert_eq!(agenda.execution().take_ready(), Ok(Some(TaskId(1))));
}

#[test]
fn wakes_scope_join_only_after_every_child_completes() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let Ok(scope) = agenda.create_scope(root) else {
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(agenda.spawn(scope), Ok(TaskId(2)));
    assert_eq!(agenda.execution().waiting().for_scope(root, scope), Ok(()));
    assert_eq!(agenda.execution().take_ready(), Ok(Some(TaskId(1))));
    assert_eq!(agenda.execution().complete(TaskId(1)), Ok(()));
    assert_eq!(agenda.state(root), Some(TaskState::Waiting));
    assert_eq!(agenda.execution().take_ready(), Ok(Some(TaskId(2))));
    assert_eq!(agenda.execution().complete(TaskId(2)), Ok(()));
    assert_eq!(agenda.execution().take_ready(), Ok(Some(root)));
}

#[test]
fn wakes_task_await_when_its_child_completes() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    let Ok(scope) = agenda.create_scope(root) else {
        return;
    };
    assert_eq!(agenda.spawn(scope), Ok(TaskId(1)));
    assert_eq!(
        agenda.execution().waiting().for_task(root, TaskId(1)),
        Ok(())
    );
    assert_eq!(agenda.execution().take_ready(), Ok(Some(TaskId(1))));
    assert_eq!(agenda.execution().complete(TaskId(1)), Ok(()));
    assert_eq!(agenda.execution().take_ready(), Ok(Some(root)));
}

#[test]
fn rejects_waits_for_unknown_scopes_and_tasks() {
    let (mut agenda, root) = TaskAgenda::with_running_root();
    assert_eq!(
        agenda.execution().waiting().for_task(root, TaskId(4)),
        Err(TaskAgendaError::UnknownTask)
    );
    assert_eq!(
        agenda.execution().waiting().for_scope(root, TaskScopeId(4)),
        Err(TaskAgendaError::UnknownScope)
    );
}
