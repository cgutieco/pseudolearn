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
