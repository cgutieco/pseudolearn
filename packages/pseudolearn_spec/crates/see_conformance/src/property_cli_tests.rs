use crate::{properties::PropertySubject, property_scenarios::Scenario};
use serde_json::{Value, json};
use std::collections::VecDeque;

struct Subject {
    declaration: Value,
    responses: VecDeque<Value>,
}

impl PropertySubject for Subject {
    fn declaration(&self) -> &Value {
        &self.declaration
    }
    fn exchange(&mut self, request: &Value) -> Result<Value, String> {
        assert!(matches!(
            request.get("kind").and_then(Value::as_str),
            Some("ir" | "cli")
        ));
        self.responses.pop_front().ok_or("missing reply".to_owned())
    }
}

#[test]
fn requires_successful_emission_verified_identical_reprint_and_valid_domain() -> Result<(), String>
{
    let scenario = Scenario {
        request: json!({"program":"source","profile":"es","strictness":"strict"}),
        expected: None,
        traced: false,
    };
    for (emitted, verified, valid) in [
        (
            json!({"exit_code":0,"output":"canonical"}),
            json!({"ir":{"accepted":true,"reprint":"canonical"}}),
            true,
        ),
        (json!({"exit_code":1}), json!({}), false),
        (
            json!({"exit_code":0,"output":"canonical"}),
            json!({"ir":{"accepted":false}}),
            false,
        ),
        (
            json!({"exit_code":0,"output":"canonical"}),
            json!({"ir":{"accepted":true,"reprint":"changed"}}),
            false,
        ),
    ] {
        let mut subject = Subject {
            declaration: json!({}),
            responses: VecDeque::from([json!({"ir":{"accepted":true}}), emitted, verified]),
        };
        assert_eq!(
            super::property_cli::check(&scenario, &mut subject)?.is_none(),
            valid
        );
    }
    let mut subject = Subject {
        declaration: json!({}),
        responses: VecDeque::from([json!({"ir":{"accepted":false}})]),
    };
    assert!(super::property_cli::check(&scenario, &mut subject)?.is_none());
    assert!(subject.responses.is_empty());
    Ok(())
}
