mod support;
use see_conformance::requests::{Selection, build, required_capabilities};
use serde_json::json;

fn case(fields: serde_json::Value) -> Result<see_model::Block, String> {
    let mut case = support::specification()?
        .blocks
        .last()
        .cloned()
        .ok_or("Missing case")?;
    for (name, value) in fields.as_object().ok_or("Invalid fields")? {
        case.fields.insert(name.clone(), value.clone());
    }
    Ok(case)
}

fn request(
    fields: serde_json::Value,
    expected: serde_json::Value,
) -> Result<serde_json::Value, String> {
    let selection = Selection {
        profile: "es",
        strictness: "estricto",
        expected: &expected,
    };
    build(&case(fields)?, &selection, &Default::default())
}

#[test]
fn builds_observed_execution_with_limits_cancellation_and_state_query() -> Result<(), String> {
    let built = request(
        json!({"operacion": "trace", "limites": {"profundidad": 3, "celdas": 9}, "cancelacion": 4}),
        json!({"estado_en": {"evento": 2, "estado": {}}}),
    )?;
    assert_eq!(built.get("kind"), Some(&json!("execute")));
    assert_eq!(built.get("observe"), Some(&json!("events")));
    assert_eq!(built.get("strictness"), Some(&json!("strict")));
    assert_eq!(
        built.get("limits"),
        Some(&json!({"micro_steps": 100_000, "depth": 3, "cells": 9}))
    );
    assert_eq!(built.get("cancel_at_statement"), Some(&json!(4)));
    assert_eq!(built.get("state_at"), Some(&json!(2)));
    assert_eq!(built.get("seed"), Some(&json!(42)));
    Ok(())
}

#[test]
fn builds_tool_requests_and_declares_required_capabilities() -> Result<(), String> {
    let ir = request(
        json!({"operacion": "ir", "programa_ri": "module {}\n"}),
        json!({}),
    )?;
    assert_eq!(ir.get("program_ir"), Some(&json!("module {}\n")));
    let cli = request(
        json!({"operacion": "cli", "cli": {"argumentos": ["ejecutar"], "entrada": "4\n"}}),
        json!({}),
    )?;
    assert_eq!(cli.get("arguments"), Some(&json!(["ejecutar"])));
    assert_eq!(cli.get("environment"), Some(&json!({})));
    assert_eq!(cli.get("stdin"), Some(&json!("4\n")));
    let plain = request(json!({"operacion": "execute"}), json!({}))?;
    assert_eq!(plain.get("observe"), Some(&json!("none")));
    assert!(plain.get("cancel_at_statement").is_none());
    for (operation, capabilities) in [
        ("trace", vec!["execute", "observe"]),
        ("ir", vec!["ir"]),
        ("cli", vec!["cli"]),
        ("analyze", vec!["analyze"]),
        ("", vec!["execute"]),
    ] {
        assert_eq!(
            required_capabilities(&case(json!({"operacion": operation}))?),
            capabilities
        );
    }
    Ok(())
}

#[test]
fn rejects_programs_that_cannot_be_reprinted() -> Result<(), String> {
    let unclosed = request(
        json!({"programas": {}, "programa": "write \"open\n", "perfil_base": "en"}),
        json!({}),
    );
    assert!(unclosed.is_err());
    Ok(())
}
