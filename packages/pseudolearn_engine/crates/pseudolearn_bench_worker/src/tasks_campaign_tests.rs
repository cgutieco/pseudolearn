use crate::tasks_agendas::generate;
use crate::tasks_campaign::{check_seed, collect, request};
use crate::tasks_subject::{TaskSubject, VirtualMachine};
use pseudolearn_api::{ExecuteRequest, ExecuteResponse};

#[test]
fn every_family_matches_its_derived_expectation_live_repeated_and_replayed() -> Result<(), String> {
    let mut subject = VirtualMachine;
    for seed in 0..16 {
        assert_eq!(
            check_seed(&mut subject, seed)?,
            Vec::<String>::new(),
            "seed {seed}"
        );
    }
    Ok(())
}

#[test]
fn the_request_carries_the_parameters_as_inputs() {
    let agenda = generate(9);
    let built = request(&agenda);
    assert_eq!(built.program, agenda.program);
    assert_eq!(built.inputs, agenda.inputs);
    assert!(!built.inputs.is_empty());
}

#[test]
fn collect_rejects_malformed_arguments() {
    assert!(collect(&[]).is_err());
    let bad = ["target/none".to_owned(), "x".to_owned(), "2".to_owned()];
    assert!(collect(&bad).is_err());
    let unknown = [
        "target/none".to_owned(),
        "0".to_owned(),
        "1".to_owned(),
        "jit".to_owned(),
    ];
    assert!(collect(&unknown).is_err());
}

struct Diverging;

impl TaskSubject for Diverging {
    fn name(&self) -> &'static str {
        "diverging"
    }

    fn execute(&mut self, request: &ExecuteRequest) -> Result<ExecuteResponse, String> {
        let mut response = VirtualMachine.execute(request)?;
        response.output.push_str("extra\n");
        Ok(response)
    }
}

#[test]
fn a_subject_whose_output_differs_from_the_derivation_is_reported() -> Result<(), String> {
    let found = check_seed(&mut Diverging, 1)?;
    assert!(
        found.contains(&"expected output differs".to_owned()),
        "{found:?}"
    );
    Ok(())
}
