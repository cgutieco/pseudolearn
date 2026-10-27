use crate::{properties::PropertySubject, property_scenarios::Scenario, property_traps};
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};

struct Subject {
    declaration: Value,
    requests: Vec<Value>,
    reply: Value,
}

impl PropertySubject for Subject {
    fn declaration(&self) -> &Value {
        &self.declaration
    }
    fn exchange(&mut self, request: &Value) -> Result<Value, String> {
        self.requests.push(request.clone());
        Ok(self.reply.clone())
    }
}

fn scenario() -> Scenario {
    Scenario {
        request: json!({"program": "source", "seed": 1}),
        expected: None,
        traced: false,
    }
}

fn subject(capabilities: Value, reply: Value) -> Subject {
    Subject {
        declaration: json!({"capabilities": capabilities}),
        requests: Vec::new(),
        reply,
    }
}

#[test]
fn generated_programs_initialize_every_binding() -> Result<(), String> {
    let mut recorder = subject(json!([]), json!({}));
    let _ = property_traps::check(PropertyExecutor::FirstTrap, &scenario(), &mut recorder)?;
    let program = recorder
        .requests
        .first()
        .and_then(|request| request.get("program"))
        .and_then(Value::as_str)
        .ok_or("missing program")?;
    assert!(program.contains("Definir r Como Entero <- "));
    assert!(!program.contains("Definir r Como Entero;"));
    Ok(())
}

#[test]
fn subject_without_observation_receives_only_the_unobserved_mode() -> Result<(), String> {
    let mut recorder = subject(json!([]), json!({}));
    let _ = property_traps::check(PropertyExecutor::FirstTrap, &scenario(), &mut recorder)?;
    let modes: Vec<&str> = recorder
        .requests
        .iter()
        .filter_map(|request| request.get("observe").and_then(Value::as_str))
        .collect();
    assert_eq!(modes, vec!["none"]);
    Ok(())
}

fn scenario_with_seed(seed: u64) -> Scenario {
    Scenario {
        request: json!({"program": "source", "seed": seed}),
        expected: None,
        traced: false,
    }
}

fn completed_expectation() -> Result<(u64, Value), String> {
    for seed in 0..256_u64 {
        let mut probe = subject(json!([]), json!({}));
        let difference =
            property_traps::check(PropertyExecutor::FirstTrap, &scenario_with_seed(seed), &mut probe)?;
        if let Some((expected, _)) = difference
            && expected.pointer("/termination/kind") == Some(&json!("completed"))
        {
            return Ok((seed, expected));
        }
    }
    Err("no completed expectation found".to_owned())
}

#[test]
fn subject_with_observation_receives_both_modes() -> Result<(), String> {
    let (seed, expected) = completed_expectation()?;
    let mut recorder = subject(json!(["observe"]), expected);
    let difference =
        property_traps::check(PropertyExecutor::FirstTrap, &scenario_with_seed(seed), &mut recorder)?;
    assert!(difference.is_none());
    let modes: Vec<&str> = recorder
        .requests
        .iter()
        .filter_map(|request| request.get("observe").and_then(Value::as_str))
        .collect();
    assert_eq!(modes, vec!["none", "events"]);
    Ok(())
}

#[test]
fn a_divergent_response_is_reported_as_a_difference() -> Result<(), String> {
    let mut recorder = subject(
        json!(["observe"]),
        json!({"termination": {"kind": "failed", "code": "analysisFailed"}, "output": ""}),
    );
    let difference =
        property_traps::check(PropertyExecutor::FirstTrap, &scenario(), &mut recorder)?;
    assert!(difference.is_some());
    Ok(())
}
