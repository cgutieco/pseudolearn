use pseudolearn_abi::effect_operation;

fn family_of(identity: &str) -> Option<&'static str> {
    effect_operation(identity).map(|operation| operation.capability_family())
}

#[test]
fn receiver_operations_map_to_their_capability_family() {
    assert_eq!(family_of("file_open"), Some("filesystem"));
    assert_eq!(family_of("file_read_text"), Some("filesystem"));
    assert_eq!(family_of("directory_close"), Some("filesystem"));
    assert_eq!(family_of("clock_now"), Some("clock"));
    assert_eq!(family_of("console_write"), Some("console"));
    assert_eq!(family_of("arguments_values"), Some("arguments"));
    assert_eq!(family_of("timer_wait"), Some("timer"));
}

#[test]
fn capability_requests_map_to_the_requested_family() {
    assert_eq!(family_of("request_directory"), Some("filesystem"));
    assert_eq!(family_of("request_clock"), Some("clock"));
    assert_eq!(family_of("request_console"), Some("console"));
    assert_eq!(family_of("request_arguments"), Some("arguments"));
    assert_eq!(family_of("request_timer"), Some("timer"));
}

#[test]
fn unknown_identity_has_no_operation() {
    assert_eq!(family_of("directory_open"), None);
}
