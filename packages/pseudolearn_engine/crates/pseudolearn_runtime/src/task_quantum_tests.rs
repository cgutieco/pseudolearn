use crate::{TaskId, TaskQuantum};

#[test]
fn accumulates_small_blocks_until_the_exact_quantum() {
    let mut quantum = TaskQuantum::default();
    for _ in 0..1023 {
        quantum.charge(TaskId(0), 1);
        assert!(!quantum.at_backedge(TaskId(0), true));
    }
    quantum.charge(TaskId(0), 1);
    assert!(quantum.at_backedge(TaskId(0), true));
    assert!(!quantum.at_backedge(TaskId(0), true));
}

#[test]
fn empty_queue_resets_a_consumed_quantum_without_suspending() {
    let mut quantum = TaskQuantum::default();
    quantum.charge(TaskId(0), 1024);
    assert!(!quantum.at_backedge(TaskId(0), false));
    assert!(!quantum.at_backedge(TaskId(0), true));
}

#[test]
fn separates_tasks_resets_on_resume_and_handles_overflow() {
    let mut quantum = TaskQuantum::default();
    quantum.charge(TaskId(1), u64::MAX);
    quantum.charge(TaskId(1), 1);
    assert!(!quantum.at_backedge(TaskId(0), true));
    assert!(quantum.at_backedge(TaskId(1), true));
    quantum.charge(TaskId(1), 1024);
    quantum.resumed(TaskId(1));
    assert!(!quantum.at_backedge(TaskId(1), true));
}
