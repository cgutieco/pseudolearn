use crate::tasks_subject::subject_from;

#[test]
fn the_subject_defaults_to_the_virtual_machine() -> Result<(), String> {
    assert_eq!(subject_from(&[])?.name(), "vm");
    assert_eq!(subject_from(&["vm".to_owned()])?.name(), "vm");
    assert!(subject_from(&["aot".to_owned()]).is_err());
    Ok(())
}

#[test]
fn an_unlaunchable_native_adapter_is_reported() {
    let missing = ["aot".to_owned(), "/nonexistent/pseudo".to_owned()];
    assert!(subject_from(&missing).is_err());
}
