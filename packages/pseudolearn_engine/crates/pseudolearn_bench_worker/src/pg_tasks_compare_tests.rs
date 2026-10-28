use crate::pg_tasks_agendas::generate;
use crate::pg_tasks_compare::{Observation, against_expected, differences};

fn observation(output: &str, kind: &str) -> Observation {
    Observation {
        output: output.to_owned(),
        kind: kind.to_owned(),
        code: None,
        tape: None,
    }
}

#[test]
fn identical_observations_have_no_differences() {
    let same = observation("a\n", "completed");
    assert!(differences("pair", &same, &same.clone()).is_empty());
}

#[test]
fn each_kind_of_divergence_is_reported() {
    let base = observation("a\n", "completed");
    assert_eq!(
        differences("pair", &base, &observation("b\n", "completed")).len(),
        1
    );
    assert_eq!(
        differences("pair", &base, &observation("a\n", "failed")).len(),
        1
    );
    let mut taped = base.clone();
    taped.tape = Some(serde_json::json!({}));
    assert_eq!(differences("pair", &base, &taped).len(), 1);
}

#[test]
fn expectations_check_output_and_termination_code() {
    let agenda = generate(5);
    let mut deadlocked = observation("", "failed");
    deadlocked.code = Some("taskDeadlock".to_owned());
    assert!(against_expected(&agenda, &deadlocked).is_empty());
    assert_eq!(
        against_expected(&agenda, &observation("x", "completed")).len(),
        2
    );
}
