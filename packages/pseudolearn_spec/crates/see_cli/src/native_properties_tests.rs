use super::native_properties::contract;
use serde_json::json;

#[test]
fn native_diagnostic_arguments_and_ranges_are_contractual() {
    let expected = json!({"output":"1\n","termination":{"kind":"failed","code":"divisionByZero"},
        "diagnostics":[{"severity":"error","code":"divisionByZero","arguments":{"limit":1},"span":{"start":{"line":2,"column":3}}}]});
    let changed_arguments = json!({"output":"1\n","termination":{"kind":"failed","code":"divisionByZero"},
        "diagnostics":[{"severity":"error","code":"divisionByZero","arguments":{"limit":2},"span":{"start":{"line":2,"column":3}}}]});
    let changed_span = json!({"output":"1\n","termination":{"kind":"failed","code":"divisionByZero"},
        "diagnostics":[{"severity":"error","code":"divisionByZero","arguments":{"limit":1},"span":{"start":{"line":9,"column":3}}}]});
    assert_ne!(contract(&expected), contract(&changed_arguments));
    assert_ne!(contract(&expected), contract(&changed_span));
    assert_eq!(contract(&expected), contract(&expected));
}

#[test]
fn human_message_translation_does_not_change_native_equivalence() {
    let first = json!({"output":"","termination":{"kind":"completed"},"diagnostics":[{"severity":"warning","message":"one"}]});
    let second = json!({"output":"","termination":{"kind":"completed"},"diagnostics":[{"severity":"warning","message":"two"}]});
    assert_eq!(contract(&first), contract(&second));
}
