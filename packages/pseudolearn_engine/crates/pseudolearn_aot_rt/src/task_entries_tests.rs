use super::{cedes_turn, quantum_spent};
use pseudolearn_runtime::TASK_QUANTUM;

fn mass(units: u64) -> i64 {
    i64::try_from(units).unwrap_or(i64::MAX)
}

#[test]
fn the_quantum_is_spent_exactly_at_its_size() {
    assert!(!quantum_spent(mass(TASK_QUANTUM.saturating_sub(1))));
    assert!(quantum_spent(mass(TASK_QUANTUM)));
    assert!(quantum_spent(mass(TASK_QUANTUM.saturating_mul(3))));
}

#[test]
fn no_mass_or_a_negative_mass_never_spends_the_quantum() {
    assert!(!quantum_spent(0));
    assert!(!quantum_spent(-1));
    assert!(!quantum_spent(i64::MIN));
}

#[test]
fn a_spent_quantum_cedes_only_when_another_task_is_ready() {
    assert!(cedes_turn(mass(TASK_QUANTUM), true));
    assert!(!cedes_turn(mass(TASK_QUANTUM), false));
    assert!(!cedes_turn(mass(TASK_QUANTUM.saturating_sub(1)), true));
}
