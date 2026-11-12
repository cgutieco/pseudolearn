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
    fn exchange(&mut self, _request: &Value) -> Result<Value, String> {
        self.responses
            .pop_front()
            .map(|result| json!({"result":result}))
            .ok_or("exhausted responses".to_owned())
    }
}

fn responses() -> Vec<Value> {
    let view = json!({"value":{"nodes":[{"node_id":"rev2.n0"}]}});
    let old = json!({"value":{"nodes":[{"node_id":"rev1.n0"}]}});
    let replacement = json!({"value":{"nodes":[{"node_id":"rev3.n0"}]}});
    let usage = json!({"failure":{"family":"usage"}});
    vec![
        json!({"value":{"resource":1}}),
        json!({"value":{"resource":2}}),
        view.clone(),
        usage.clone(),
        old.clone(),
        json!({"value":{"node":{}}}),
        usage.clone(),
        old,
        json!({"value":{"resource":3}}),
        usage.clone(),
        usage.clone(),
        replacement,
        json!({"value":{"node":{}}}),
        usage.clone(),
        json!({"value":null}),
        usage,
        view,
        json!({"value":null}),
    ]
}

#[test]
fn checks_foreign_released_and_unrelated_document_invariants() -> Result<(), String> {
    let scenario = Scenario {
        request: json!({"profile":"es"}),
        expected: None,
        traced: false,
    };
    for mutation in [
        None,
        Some(3),
        Some(6),
        Some(9),
        Some(10),
        Some(15),
        Some(16),
    ] {
        let mut replies = responses();
        if let Some(index) = mutation {
            *replies.get_mut(index).ok_or("missing response")? = json!({"value":{"node":{}}});
        }
        let mut subject = Subject {
            declaration: json!({}),
            responses: replies.into(),
        };
        let result = super::property_revision::check(&scenario, &mut subject)?;
        assert_eq!(result.is_some(), mutation.is_some());
        assert!(subject.responses.is_empty());
    }
    Ok(())
}
