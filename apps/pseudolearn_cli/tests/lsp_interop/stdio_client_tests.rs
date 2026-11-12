use crate::comparator::compare;
use crate::sequence::load;
use crate::stdio_client::run;

#[test]
fn independent_stdio_client_is_deterministic_across_processes_and_roots() -> Result<(), String> {
    let first_root = "file:///interop/one/";
    let second_root = "file:///interop/two/";
    let first = run(first_root, &load(first_root)?)?;
    let second = run(second_root, &load(second_root)?)?;
    assert!(first.steps.len() > 1);
    assert_eq!(compare(&first, &second), Vec::new());
    Ok(())
}

#[test]
fn independent_stdio_client_records_every_request_and_published_diagnostics() -> Result<(), String>
{
    let root = "file:///interop/one/";
    let steps = load(root)?;
    let transcript = run(root, &steps)?;
    let requests = steps
        .iter()
        .filter(|step| step.kind == crate::sequence::StepKind::Request)
        .count();
    assert_eq!(transcript.steps.len(), requests);
    assert!(
        transcript
            .diagnostics
            .keys()
            .any(|uri| uri.ends_with("app/malo.pseudo"))
    );
    Ok(())
}
