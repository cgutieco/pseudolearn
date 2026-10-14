mod adapter;
mod support;
use see_conformance::protocol::Session;
use std::time::Duration;

#[test]
fn executes_bilingual_cases_and_marks_unsupported_operations_inapplicable() -> Result<(), String> {
    let adapter = adapter::Adapter::create()?;
    let mut specification = support::specification()?;
    specification
        .blocks
        .last_mut()
        .ok_or("Missing case")?
        .fields
        .insert("programas".to_owned(), serde_json::json!({"es":"","en":""}));
    for (mode, expected) in [("normal", "cumple"), ("unsupported", "no aplicable")] {
        let mut session = Session::start(&mut adapter.command(mode), Duration::from_secs(2))?;
        let evidence = see_conformance::execution::execute(
            &vec![specification.clone()],
            &Default::default(),
            &mut session,
        )?;
        assert_eq!(evidence.observations.len(), 2);
        assert!(
            evidence
                .observations
                .iter()
                .all(|observation| observation.verdict == expected)
        );
        assert!(evidence.stderr.contains("fixture stderr"));
    }
    Ok(())
}
