use crate::service::workspace_campaign::case::build;
use crate::service::workspace_campaign::comparison::{p95, within_threshold};
use crate::service::workspace_campaign::run::run_case;
use crate::service::workspace_campaign::scenario::Scenario;
use crate::service::workspace_campaign::test_support::{
    SteppingClock, TINY_LOAD, alternating_connect,
};

#[test]
fn equivalent_candidate_and_control_produce_paired_samples_from_the_injected_clock()
-> Result<(), String> {
    let case = build(&TINY_LOAD, Scenario::BodyEdit);
    let mut connect = alternating_connect("same", "same");
    let samples = run_case(&mut connect, &mut SteppingClock::new(2_000_000), &case, 4)?;
    assert_eq!(samples.candidate_millis, vec![2.0; 4]);
    assert_eq!(samples.control_millis.len(), 4);
    Ok(())
}

#[test]
fn a_candidate_that_changes_a_result_aborts_the_run() {
    let case = build(&TINY_LOAD, Scenario::BodyEdit);
    let mut connect = alternating_connect("candidate", "control");
    let result = run_case(&mut connect, &mut SteppingClock::new(1), &case, 1);
    assert!(result.is_err());
}

#[test]
fn a_slow_clock_exceeds_the_diagnostic_threshold() -> Result<(), String> {
    let case = build(&TINY_LOAD, Scenario::BodyEdit);
    let mut connect = alternating_connect("same", "same");
    let samples = run_case(&mut connect, &mut SteppingClock::new(150_000_000), &case, 3)?;
    let p95_millis = p95(&samples.candidate_millis).ok_or("no samples")?;
    assert_eq!(
        within_threshold(Scenario::BodyEdit, p95_millis),
        Some(false)
    );
    Ok(())
}

#[test]
fn zero_samples_are_an_empty_result_and_connect_failures_propagate() -> Result<(), String> {
    let case = build(&TINY_LOAD, Scenario::Rename);
    let mut connect = alternating_connect("same", "same");
    let empty = run_case(&mut connect, &mut SteppingClock::new(1), &case, 0)?;
    assert!(empty.candidate_millis.is_empty());
    let mut failing = || {
        Err::<crate::service::workspace_campaign::test_support::ScriptedTransport, _>(
            "no binary".to_owned(),
        )
    };
    assert!(run_case(&mut failing, &mut SteppingClock::new(1), &case, 1).is_err());
    Ok(())
}

#[test]
fn stale_revisions_and_boundary_projects_run_to_equivalence() -> Result<(), String> {
    for scenario in Scenario::CORRECTNESS {
        let mut connect = alternating_connect("same", "same");
        run_case(
            &mut connect,
            &mut SteppingClock::new(1),
            &build(&TINY_LOAD, scenario),
            1,
        )?;
    }
    Ok(())
}
