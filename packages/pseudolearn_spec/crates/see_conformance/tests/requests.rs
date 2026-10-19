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
fn requests_program_views_only_when_the_expected_observation_needs_them() -> Result<(), String> {
    let fields = json!({"operacion": "analyze", "programa": "Algoritmo P\nFinAlgoritmo\n"});
    let analyze_case = case(fields)?;
    let built = request(
        json!({"operacion": "analyze", "programa": "Algoritmo P\nFinAlgoritmo\n"}),
        json!({"vista_programa": {"unidades": []}}),
    )?;
    assert_eq!(built.get("include_program_view"), Some(&json!(true)));
    assert_eq!(required_capabilities(&analyze_case), ["analyze"]);
    let mut view_case = analyze_case;
    view_case
        .fields
        .insert("espera".to_owned(), json!({"vista_programa": {}}));
    assert_eq!(
        required_capabilities(&view_case),
        ["analyze", "program_view"]
    );
    let traced = case(json!({"operacion": "trace"}))?;
    let mut sourced_trace = traced;
    sourced_trace.fields.insert(
        "espera".to_owned(),
        json!({"eventos": [{"clase": "statement_entered", "linea": 2, "fuente": "nodo_programa"}]}),
    );
    assert_eq!(
        required_capabilities(&sourced_trace),
        ["execute", "observe", "program_view"]
    );
    Ok(())
}

#[test]
fn passes_state_page_parameters_to_the_execution_subject() -> Result<(), String> {
    let built = request(
        json!({
            "operacion": "trace",
            "paginacion": {"query": "array_cells", "event": 2, "page_size": 2, "cursor": null}
        }),
        json!({"estado_en": {"evento": 2, "estado": {}}}),
    )?;
    assert_eq!(
        built.get("state_page"),
        Some(&json!({"query": "array_cells", "event": 2, "page_size": 2, "cursor": null}))
    );
    assert_eq!(
        required_capabilities(&case(json!({"operacion": "trace", "paginacion": {}}))?),
        ["execute", "observe", "state_pages"]
    );
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
        ("app", vec!["app"]),
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
fn builds_application_case_requests_without_treating_inputs_as_programs() -> Result<(), String> {
    let built = request(
        json!({
            "operacion": "app",
            "aplicacion": {
                "scenario": "pace",
                "input": {"pace": "nextStatement", "program": "Algoritmo P\nFinAlgoritmo\n"}
            }
        }),
        json!({"aplicacion": {"settled": true}}),
    )?;
    assert_eq!(built.get("kind"), Some(&json!("app")));
    assert_eq!(built.get("scenario"), Some(&json!("pace")));
    assert_eq!(
        built.get("input"),
        Some(&json!({"pace": "nextStatement", "program": "Algoritmo P\nFinAlgoritmo\n"}))
    );
    assert_eq!(
        required_capabilities(&case(json!({"operacion": "app"}))?),
        ["app"]
    );
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

#[test]
fn transmits_loop_poll_cancellation_independently_of_statement_cancellation() -> Result<(), String>
{
    let built = request(
        json!({"operacion": "execute", "cancelacion_prueba": 0}),
        json!({}),
    )?;
    assert_eq!(built.get("cancel_at_poll"), Some(&json!(0)));
    assert!(built.get("cancel_at_statement").is_none());
    assert!(
        request(json!({"operacion": "execute"}), json!({}))?
            .get("cancel_at_poll")
            .is_none()
    );
    Ok(())
}
