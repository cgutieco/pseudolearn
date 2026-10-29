use pseudolearn_abi::{
    CapabilityKind, HTTP_REQUEST_PREFIX, HTTP_RESPONSE_PREFIX, IoErrorKind, effect_operation,
};

#[test]
fn network_capability_uses_a_stable_new_tag() {
    assert_eq!(CapabilityKind::Network.to_tag(), 6);
    assert_eq!(CapabilityKind::from_tag(6), Some(CapabilityKind::Network));
    assert_eq!(CapabilityKind::ALL.len(), 7);
}

#[test]
fn http_errors_round_trip_without_reusing_existing_tags() {
    for kind in &IoErrorKind::ALL {
        assert_eq!(IoErrorKind::from_tag(kind.to_tag()), Some(*kind));
    }
    assert_eq!(IoErrorKind::InvalidUrl.to_tag(), 9);
    assert_eq!(IoErrorKind::InvalidResponse.to_tag(), 14);
    assert_eq!(IoErrorKind::LimitExceeded.to_tag(), 15);
    assert_eq!(IoErrorKind::ALL.len(), 16);
}

#[test]
fn request_and_response_wire_values_have_distinct_prefixes() {
    assert_eq!(&HTTP_REQUEST_PREFIX, b"PLHR");
    assert_eq!(&HTTP_RESPONSE_PREFIX, b"PLHS");
    assert_ne!(HTTP_REQUEST_PREFIX, HTTP_RESPONSE_PREFIX);
}

#[test]
fn generated_http_operations_are_network_effects() -> Result<(), String> {
    for identity in [
        "request_network",
        "network_restrict",
        "network_send",
        "network_close",
    ] {
        let operation = effect_operation(identity).ok_or_else(|| identity.to_owned())?;
        assert_eq!(operation.capability_family(), "network");
    }
    Ok(())
}
