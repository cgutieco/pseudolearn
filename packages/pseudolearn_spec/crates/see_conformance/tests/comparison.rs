use serde_json::json;

#[test]
fn preserves_output_bytes_and_diagnostic_multiplicity() {
    let expected = json!({"salida":"1\n","diagnosticos":[{"codigo":"expectedExpression","severidad":"error"}]});
    let actual =
        json!({"output":"1\n","diagnostics":[{"code":"expectedExpression","severity":"error"}]});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let duplicate = json!({"output":"1\n","diagnostics":[{"code":"expectedExpression","severity":"error"},{"code":"expectedExpression","severity":"error"}]});
    assert!(!see_conformance::comparison::compare(&expected, &duplicate).is_empty());
    assert!(!see_conformance::comparison::compare(&json!({"salida":"1"}), &actual).is_empty());
}

#[test]
fn compares_spans_trees_termination_and_warning_severity() -> Result<(), String> {
    let span = json!({"start":{"line":2,"column":3},"end":{"line":2,"column":4}});
    let expected = json!({"arbol":"presente","fallo":{"codigo":"integerOverflow"},"diagnosticos":[{"codigo":"warning","severidad":"advertencia","tramo":span}]});
    let actual = json!({"tree":true,"termination":{"kind":"failed","code":"integerOverflow"},"diagnostics":[{"code":"warning","severity":"warning","span":span}]});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let mut wrong = actual.clone();
    *wrong.get_mut("tree").ok_or("Missing tree")? = json!(false);
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
    wrong = actual;
    *wrong
        .get_mut("diagnostics")
        .and_then(|value| value.get_mut(0))
        .and_then(|value| value.get_mut("span"))
        .and_then(|value| value.get_mut("start"))
        .and_then(|value| value.get_mut("column"))
        .ok_or("Missing span")? = json!(4);
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
    assert!(!see_conformance::comparison::compare(&json!({"unknown":true}), &wrong).is_empty());
    Ok(())
}

#[test]
fn observes_order_when_requested_without_changing_multiset_comparison() {
    let expected = json!([{"codigo":"first"},{"codigo":"second"}]);
    let actual = json!({"diagnostics":[{"code":"second"},{"code":"first"}]});
    assert!(
        see_conformance::comparison::compare(&json!({"diagnosticos":expected}), &actual).is_empty()
    );
    assert!(
        !see_conformance::comparison::compare(&json!({"diagnosticos_ordenados":expected}), &actual)
            .is_empty()
    );
    assert!(
        see_conformance::comparison::compare(
            &json!({"diagnosticos_ordenados":[]}),
            &json!({"diagnostics":[]})
        )
        .is_empty()
    );
}

#[test]
fn compares_application_results_and_program_view_subsets() {
    let expected = json!({
        "aplicacion": {"decoded_id": "9007199254740993", "source_equal": true},
        "vista_programa": {
            "units": [{"kind": "algorithm", "name": "P", "order": 0}],
            "node_kinds_include": ["statement", "expression"],
            "child_order": "source"
        }
    });
    let actual = json!({
        "app": {"decoded_id": "9007199254740993", "source_equal": true, "extra": true},
        "program_view": {
            "units": [{"kind": "algorithm", "name": "P", "order": 0, "node_id": "opaque"}],
            "nodes": [{"kind": "statement"}, {"kind": "expression"}, {"kind": "identifier"}],
            "child_order": "source"
        }
    });
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let wrong = json!({
        "app": {"decoded_id": "9007199254740992", "source_equal": true},
        "program_view": {"units": [], "nodes": [{"kind": "statement"}], "child_order": "source"}
    });
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
}

#[test]
fn source_event_expectations_reject_missing_or_mismatched_provenance() {
    let expected = json!({"eventos": [
        {"clase": "statement_entered", "linea": 2, "fuente": "nodo_programa"},
        {"clase": "output", "linea": 2, "fuente": "nodo_programa"}
    ]});
    let actual = json!({"events": [
        {"class": "statement_entered", "line": 2, "source": {"revision_id": "r1", "node_id": "n1", "span": {"start_byte": "0", "end_byte": "1"}}},
        {"class": "output", "line": 2, "source": {"revision_id": "r1", "node_id": "n1", "span": {"start_byte": "0", "end_byte": "1"}}}
    ]});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let wrong = json!({"events": [
        {"class": "statement_entered", "line": 2, "source": {"revision_id": "r1", "node_id": "n1", "span": {"start_byte": "0", "end_byte": "1"}}},
        {"class": "output", "line": 2, "source": {"revision_id": "r1", "node_id": "n2", "span": {"start_byte": "0", "end_byte": "1"}}}
    ]});
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
}

#[test]
fn compares_program_node_spans_without_requiring_private_node_ids() {
    let expected = json!({"vista_programa": {
        "nodes_include": [{
            "kind": "statement",
            "span": {"start_byte": "12", "end_byte": "28", "start": {"line": 2, "column": 1}, "end": {"line": 2, "column": 14}}
        }]
    }});
    let actual = json!({"program_view": {"nodes": [
        {"kind": "statement", "node_id": "opaque-a", "span": {"start_byte": "12", "end_byte": "28", "start": {"line": 2, "column": 1}, "end": {"line": 2, "column": 14}}},
        {"kind": "expression", "node_id": "opaque-b"}
    ]}});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let wrong = json!({"program_view": {"nodes": [
        {"kind": "statement", "node_id": "opaque-a", "span": {"start_byte": "12", "end_byte": "27", "start": {"line": 2, "column": 1}, "end": {"line": 2, "column": 14}}}
    ]}});
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
}

#[test]
fn checks_node_identity_and_references_within_one_program_revision() {
    let expected = json!({"vista_programa": {
        "node_ids_unique": true,
        "references_same_revision": true
    }});
    let actual = json!({"program_view": {
        "revision_id": "revision-a",
        "nodes": [
            {"node_id": "node-a", "child_node_ids": ["node-b"]},
            {"node_id": "node-b", "parent_node_id": "node-a", "child_node_ids": []}
        ]
    }});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let wrong = json!({"program_view": {
        "revision_id": "revision-a",
        "nodes": [
            {"node_id": "node-a", "child_node_ids": ["missing"]},
            {"node_id": "node-a", "parent_node_id": "node-a", "child_node_ids": []}
        ]
    }});
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
}
