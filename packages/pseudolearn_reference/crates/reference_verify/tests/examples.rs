use reference_model::{EngineDiagnostic, ExampleCheck, ExecutionReport, ProgramPromise};
use reference_verify::check_examples;

fn report(output: &str, codes: &[&str], termination: &str) -> ExecutionReport {
    ExecutionReport {
        output: output.to_owned(),
        termination: termination.to_owned(),
        diagnostics: codes
            .iter()
            .map(|code| EngineDiagnostic {
                code: (*code).to_owned(),
                ..EngineDiagnostic::default()
            })
            .collect(),
        trace: Vec::new(),
    }
}

fn check(promise: ProgramPromise, source: ExecutionReport, target: ExecutionReport) -> usize {
    check_examples(&[ExampleCheck {
        location: "x.md#uno".to_owned(),
        promise,
        source_report: source,
        target_report: target,
    }])
    .len()
}

fn promise(
    output: Option<&str>,
    codes: Option<&[&str]>,
    termination: Option<&str>,
) -> ProgramPromise {
    ProgramPromise {
        output: output.map(str::to_owned),
        diagnostics: codes.map(|codes| codes.iter().map(|code| (*code).to_owned()).collect()),
        termination: termination.map(str::to_owned),
    }
}

#[test]
fn accepts_a_kept_promise() {
    let ran = report("Hola\n", &[], "completed");
    assert_eq!(
        check(promise(Some("Hola"), None, None), ran.clone(), ran),
        0
    );
}

#[test]
fn rejects_a_false_output() {
    let ran = report("Hola\n", &[], "completed");
    assert_eq!(
        check(promise(Some("Adiós"), None, None), ran.clone(), ran),
        1
    );
}

#[test]
fn rejects_an_unpromised_output() {
    let ran = report("Hola\n", &[], "completed");
    assert_eq!(check(promise(None, None, None), ran.clone(), ran), 1);
}

#[test]
fn checks_diagnostics_and_termination() {
    let failed = report("", &["divisionByZero"], "failed");
    assert_eq!(
        check(
            promise(None, Some(&["divisionByZero"]), None),
            failed.clone(),
            failed.clone()
        ),
        0
    );
    assert_eq!(
        check(
            promise(None, Some(&["integerOverflow"]), None),
            failed.clone(),
            failed.clone()
        ),
        1
    );
    assert_eq!(
        check(
            promise(None, Some(&["divisionByZero"]), Some("completed")),
            failed.clone(),
            failed
        ),
        1
    );
}

#[test]
fn rejects_a_translation_that_behaves_differently() {
    let ran = report("1\n", &[], "completed");
    let other = report("1\n", &["integerOverflow"], "failed");
    assert_eq!(check(promise(Some("1"), None, None), ran, other), 1);
}
