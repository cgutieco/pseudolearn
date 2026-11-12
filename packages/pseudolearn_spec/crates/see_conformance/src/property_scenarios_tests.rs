use super::{Scenario, runnable_by};
use serde_json::{Value, json};

fn scenario(request: Value) -> Scenario {
    Scenario {
        request,
        expected: None,
        traced: false,
    }
}

#[test]
fn a_scenario_with_a_host_double_runs_only_on_the_subject_that_ships_it() {
    let hosted = scenario(json!({"kind":"execute","host":{"http":{}}}));
    assert!(runnable_by(&hosted, &json!({"subject":"engine"})));
    assert!(!runnable_by(&hosted, &json!({"subject":"app"})));
    assert!(!runnable_by(&hosted, &json!({"subject":"cli"})));
}

#[test]
fn a_scenario_without_a_host_runs_on_every_subject() {
    let plain = scenario(json!({"kind":"execute"}));
    assert!(runnable_by(&plain, &json!({"subject":"app"})));
    assert!(runnable_by(&plain, &json!({})));
}

#[test]
fn observation_still_requires_the_observe_capability() {
    let observed = scenario(json!({"kind":"execute","observe":"events"}));
    assert!(!runnable_by(&observed, &json!({"subject":"app"})));
    assert!(runnable_by(
        &observed,
        &json!({"subject":"app","capabilities":["observe"]})
    ));
}
