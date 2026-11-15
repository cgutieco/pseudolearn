use crate::service::thresholds::threshold;

#[test]
fn reads_limits_from_the_specification_export() {
    assert_eq!(threshold("TOOL.SERVICE.COMPLETION", "M1"), Ok(50.0));
    assert_eq!(threshold("TOOL.SERVICE.COMPLETION", "M2"), Ok(85.0));
    assert_eq!(threshold("TOOL.SERVICE.INCREMENTAL", "M1"), Ok(16.0));
}

#[test]
fn unknown_measurements_are_reported() {
    assert!(threshold("TOOL.SERVICE.COMPLETION", "M99").is_err());
    assert!(threshold("TOOL.DOES.NOT-EXIST", "M1").is_err());
}
