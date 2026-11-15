use crate::{TaskFailures, TaskId};

#[test]
fn empty_scope_has_no_failure() {
    assert_eq!(TaskFailures::<String>::default().finish(), None);
}

#[test]
fn termination_order_precedes_task_identity() {
    let mut failures = TaskFailures::default();
    assert!(failures.record(TaskId(9), "first"));
    assert!(!failures.record(TaskId(1), "second"));
    assert!(failures.cancel(TaskId(3)));
    assert!(!failures.cancel(TaskId(3)));
    assert!(!failures.cancel(TaskId(9)));
    assert!(!failures.record(TaskId(3), "cancelled"));
    let failure = failures.finish();
    assert_eq!(
        failure.map(|failure| (failure.first, failure.associated, failure.cancelled)),
        Some(("first", vec!["second"], 1))
    );
}

#[test]
fn one_child_failure_has_no_associates_or_cancellations() {
    let mut failures = TaskFailures::default();
    assert!(failures.record(TaskId(1), 42));
    assert!(!failures.record(TaskId(1), 99));
    assert_eq!(
        failures
            .finish()
            .map(|failure| (failure.first, failure.associated, failure.cancelled)),
        Some((42, vec![], 0))
    );
}
