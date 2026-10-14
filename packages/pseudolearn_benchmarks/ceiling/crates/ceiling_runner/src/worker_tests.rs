#[test]
fn rejects_incorrect_output_before_accepting_sample() {
    assert!(super::validate("42", "42").is_ok());
    assert!(super::validate("41", "42").is_err());
}

#[test]
fn invalid_kernel_does_not_produce_a_measurement() {
    let workload = crate::corpus::Workload {
        name: "unknown".to_owned(),
        family: "objects".to_owned(),
        size: 1,
        expected: "42".to_owned(),
    };
    assert!(super::measure(&workload, 1).is_err());
}

#[test]
fn recursive_v3_sample_records_a_real_checkpoint() -> Result<(), String> {
    for name in ["storage", "towers"] {
        let workload = crate::corpus::load("medicion")?
            .into_iter()
            .find(|workload| workload.name == name)
            .ok_or("Missing workload")?;
        let (_, _, checkpoints) = super::measure(&workload, 3)?;
        assert!(checkpoints > 0);
    }
    Ok(())
}
