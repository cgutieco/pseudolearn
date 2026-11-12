use pseudolearn_abi::{
    CapabilityKind, DATE_TIME_PREFIX, DATE_TIME_TOTAL_BYTES, EffectValueKind, effect_operation,
};

#[test]
fn the_environment_capability_has_the_next_tag_and_round_trips() {
    assert_eq!(CapabilityKind::Environment.to_tag(), 7);
    assert_eq!(
        CapabilityKind::from_tag(7),
        Some(CapabilityKind::Environment)
    );
    assert_eq!(CapabilityKind::from_tag(8), None);
    assert_eq!(CapabilityKind::Environment.as_str(), "environment");
}

#[test]
fn the_date_time_layout_is_prefix_instant_and_offset() {
    assert_eq!(DATE_TIME_PREFIX, *b"PLDT");
    assert_eq!(DATE_TIME_TOTAL_BYTES, 16);
}

#[test]
fn environment_operations_use_the_environment_capability_family() {
    for identity in ["request_environment", "environment_get"] {
        let operation = effect_operation(identity);
        assert_eq!(
            operation.map(|found| found.capability_family()),
            Some("environment")
        );
    }
}

#[test]
fn a_fallible_optional_text_uses_three_cells_and_an_infallible_one_uses_one() {
    let get = effect_operation("environment_get");
    assert_eq!(
        get.map(|found| found.result),
        Some(EffectValueKind::OptionalText)
    );
    assert_eq!(get.map(|found| found.result_cell_count()), Some(3));
    let parse = effect_operation("date_time_parse");
    assert_eq!(parse.map(|found| found.result_cell_count()), Some(1));
}

#[test]
fn the_calendar_operations_are_pure_and_the_local_clock_is_an_effect() {
    let pure = [
        "date_time_utc",
        "date_time_of",
        "date_time_year",
        "date_time_iso_format",
    ];
    for identity in pure {
        assert_eq!(
            effect_operation(identity).map(|found| found.effect),
            Some(false),
            "{identity}"
        );
    }
    let local = effect_operation("clock_local_now");
    assert_eq!(
        local.map(|found| (found.effect, found.fallible)),
        Some((true, true))
    );
    assert_eq!(
        effect_operation("date_time_of").map(|found| found.parameters.len()),
        Some(8)
    );
}
