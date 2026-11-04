use pseudolearn_api::{AnalyzeRequest, ApiSession, analysis_program_view};
use serde_json::{Value, json};

fn view_nodes(program: &str) -> Result<Vec<Value>, String> {
    let mut session = ApiSession::default();
    let document = session
        .call("create_document", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    session
        .call("program_view", &json!({"resource":document}))
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| "missing nodes".to_owned())
}

fn nodes_of_kind<'nodes>(nodes: &'nodes [Value], kind: &str) -> Vec<&'nodes Value> {
    nodes
        .iter()
        .filter(|node| node.get("syntax_kind") == Some(&json!(kind)))
        .collect()
}

fn first_of_kind<'nodes>(nodes: &'nodes [Value], kind: &str) -> Result<&'nodes Value, String> {
    nodes_of_kind(nodes, kind)
        .first()
        .copied()
        .ok_or_else(|| format!("missing {kind}"))
}

fn identity(node: &Value) -> Value {
    node.get("node_id").cloned().unwrap_or(Value::Null)
}

fn identities(nodes: &[&Value]) -> Vec<Value> {
    nodes.iter().map(|node| identity(node)).collect()
}

#[test]
fn break_targets_the_inner_loop_and_runs_only_the_abandoned_cleanups() -> Result<(), String> {
    let program = "Algoritmo Main\nDiferir\nEscribir 0;\nFinDiferir\nPara index <- 1 Hasta 3 Con Paso 1 Hacer\nDiferir\nEscribir index;\nFinDiferir\nSi index = 2 Entonces\nSalir;\nFinSi\nFinPara\nFinAlgoritmo\n";
    let nodes = view_nodes(program)?;
    let defers = nodes_of_kind(&nodes, "defer_statement");
    let loop_node = first_of_kind(&nodes, "for_loop")?;
    let exit = first_of_kind(&nodes, "break_statement")?;
    let inner_cleanup = defers.get(1).copied().ok_or("missing inner defer")?;
    assert_eq!(
        exit.get("control_exit"),
        Some(&json!({
            "kind": "break",
            "target_node_id": identity(loop_node),
            "cleanups": [identity(inner_cleanup)],
        }))
    );
    Ok(())
}

#[test]
fn return_and_propagation_leave_the_unit_after_inner_then_outer_cleanups() -> Result<(), String> {
    let program = "SubProceso First() Como Opcional<Entero>\nRetornar Nada;\nFinSubProceso\nSubProceso Second() Como Opcional<Cadena>\nDiferir\nEscribir 1;\nFinDiferir\nDiferir\nEscribir 2;\nFinDiferir\nMientras Verdadero Hacer\nDiferir\nEscribir 3;\nFinDiferir\nDefinir value Como Entero <- Propagar First();\nRetornar Algo(\"done\");\nFinMientras\nRetornar Nada;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let nodes = view_nodes(program)?;
    let units = nodes_of_kind(&nodes, "subroutine");
    let second = units.get(1).copied().ok_or("missing second")?;
    let defers = nodes_of_kind(&nodes, "defer_statement");
    let propagation = first_of_kind(&nodes, "propagation")?;
    let expected_order = identities(&[
        defers.get(2).copied().ok_or("missing loop defer")?,
        defers.get(1).copied().ok_or("missing second defer")?,
        defers.first().copied().ok_or("missing first defer")?,
    ]);
    assert_eq!(
        propagation.get("control_exit"),
        Some(
            &json!({"kind": "propagation", "target_node_id": identity(second), "cleanups": expected_order})
        )
    );
    let returns = nodes_of_kind(&nodes, "return_statement");
    let inner_return = returns.get(1).copied().ok_or("missing loop return")?;
    assert_eq!(
        inner_return.pointer("/control_exit/cleanups"),
        Some(&json!(expected_order))
    );
    let outer_return = returns.get(2).copied().ok_or("missing final return")?;
    assert_eq!(
        outer_return.pointer("/control_exit/cleanups"),
        Some(&json!(identities(&[
            defers.get(1).copied().ok_or("missing second defer")?,
            defers.first().copied().ok_or("missing first defer")?,
        ])))
    );
    Ok(())
}

#[test]
fn every_scope_with_cleanups_lists_its_normal_end_in_reverse_registration() -> Result<(), String> {
    let program = "Algoritmo Main\nDiferir\nEscribir 1;\nFinDiferir\nEscribir 0;\nDiferir\nEscribir 2;\nFinDiferir\nFinAlgoritmo\n";
    let nodes = view_nodes(program)?;
    let defers = nodes_of_kind(&nodes, "defer_statement");
    let scope = nodes
        .iter()
        .find(|node| node.get("normal_cleanups").is_some())
        .ok_or("missing scope")?;
    assert_eq!(
        scope.get("normal_cleanups"),
        Some(&json!(identities(&[
            defers.get(1).copied().ok_or("missing second defer")?,
            defers.first().copied().ok_or("missing first defer")?,
        ])))
    );
    assert!(
        defers
            .iter()
            .all(|defer| defer.get("cleanup_scope_node_id") == Some(&identity(scope)))
    );
    let bodies_with_cleanups = nodes
        .iter()
        .filter(|node| node.get("normal_cleanups").is_some())
        .count();
    assert_eq!(bodies_with_cleanups, 1);
    Ok(())
}

#[test]
fn a_return_inside_a_function_literal_targets_the_literal() -> Result<(), String> {
    let program = "SubProceso make() Como SubProceso() Como Entero\nDiferir\nEscribir 1;\nFinDiferir\nRetornar SubProceso() Como Entero\nRetornar 7;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let nodes = view_nodes(program)?;
    let literal = first_of_kind(&nodes, "function_literal")?;
    let returns = nodes_of_kind(&nodes, "return_statement");
    let inner = returns.get(1).copied().ok_or("missing inner return")?;
    assert_eq!(
        inner.get("control_exit"),
        Some(&json!({"kind": "return", "target_node_id": identity(literal), "cleanups": []}))
    );
    Ok(())
}

#[test]
fn programs_without_exits_or_cleanups_carry_no_exit_attributes() -> Result<(), String> {
    let nodes = view_nodes("Algoritmo Main\nFinAlgoritmo\n")?;
    assert!(nodes.iter().all(|node| node.get("control_exit").is_none()
        && node.get("normal_cleanups").is_none()
        && node.get("cleanup_scope_node_id").is_none()));
    Ok(())
}

fn invalid_view_nodes(program: &str) -> Result<Vec<Value>, String> {
    analysis_program_view(&AnalyzeRequest {
        program: program.to_owned(),
        profile: "es".to_owned().to_owned(),
        source: None,
    })
    .and_then(|view| view.get("nodes").and_then(Value::as_array).cloned())
    .ok_or_else(|| "missing view".to_owned())
}

#[test]
fn a_break_outside_a_loop_has_no_target_and_no_cleanups() -> Result<(), String> {
    let nodes = invalid_view_nodes(
        "Algoritmo Main\nDiferir\nEscribir 1;\nFinDiferir\nSalir;\nFinAlgoritmo\n",
    )?;
    let exit = first_of_kind(&nodes, "break_statement")?;
    assert_eq!(
        exit.get("control_exit"),
        Some(&json!({"kind": "break", "target_node_id": null, "cleanups": []}))
    );
    Ok(())
}

#[test]
fn an_exit_inside_a_deferred_body_has_no_target_and_no_cleanups() -> Result<(), String> {
    let nodes = invalid_view_nodes(
        "Algoritmo Main\nPara index <- 1 Hasta 2 Con Paso 1 Hacer\nDiferir\nSalir;\nFinDiferir\nFinPara\nFinAlgoritmo\n",
    )?;
    let exit = first_of_kind(&nodes, "break_statement")?;
    assert_eq!(
        exit.get("control_exit"),
        Some(&json!({"kind": "break", "target_node_id": null, "cleanups": []}))
    );
    Ok(())
}
