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
            "syntax_kinds_include": ["conditional"],
            "child_order": "source"
        }
    });
    let actual = json!({
        "app": {"decoded_id": "9007199254740993", "source_equal": true, "extra": true},
        "program_view": {
            "units": [{"kind": "algorithm", "name": "P", "order": 0, "node_id": "opaque"}],
            "nodes": [{"kind": "statement", "syntax_kind": "conditional"}, {"kind": "expression"}, {"kind": "identifier"}],
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
fn treats_opaque_page_cursors_as_values_and_rejects_wrong_projection() {
    let expected = json!({"aplicacion": {"first_page": {
        "indices": [0, 1],
        "truncated": true,
        "next_cursor": "opaque"
    }}});
    let actual = json!({"app": {"first_page": {
        "indices": [0, 1],
        "truncated": true,
        "next_cursor": "9a3c.2"
    }}});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());

    let wrong = json!({"app": {"first_page": {
        "indices": [0],
        "truncated": false,
        "next_cursor": ""
    }}});
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
}

#[test]
fn compares_public_syntax_kinds_without_requiring_private_node_details() {
    let expected = json!({"vista_programa": {
        "syntax_kinds_include": ["conditional", "while_loop"],
        "child_roles_include": [
            {"syntax_kind":"conditional","role":"else_body"}
        ]
    }});
    let actual = json!({"program_view": {"nodes": [
        {"kind": "statement", "syntax_kind": "conditional", "child_roles":[{"node_id":"n2","role":"else_body"}]},
        {"kind": "statement", "syntax_kind": "while_loop"}
    ]}});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let wrong = json!({"program_view": {"nodes": [
        {"kind": "statement", "syntax_kind": "conditional", "child_roles":[{"node_id":"n2","role":"then_body"}]},
        {"kind": "statement", "syntax_kind": "for_loop"}
    ]}});
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
}

#[test]
fn compares_lexical_tokens_and_rejects_missing_or_misaligned_tokens() {
    let expected = json!({"tokens_include": [
        {"kind":"keyword","keyword":"algorithm"},
        {"kind":"comment","span":{"start":{"line":2,"column":1},"end":{"line":2,"column":5}}}
    ]});
    let actual = json!({"tokens":[
        {"kind":"keyword","keyword":"algorithm"},
        {"kind":"comment","span":{"start":{"line":2,"column":1},"end":{"line":2,"column":5}}},
        {"kind":"whitespace"}
    ]});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());

    let wrong = json!({"tokens":[
        {"kind":"keyword","keyword":"algorithm"},
        {"kind":"comment","span":{"start":{"line":2,"column":2},"end":{"line":2,"column":5}}}
    ]});
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

#[test]
fn units_and_members_must_resolve_to_nodes_of_the_same_view() {
    let expected = json!({"vista_programa": {"references_same_revision": true}});
    let resolved = json!({"program_view": {
        "revision_id": "revision-a",
        "nodes": [{"node_id": "node-a", "child_node_ids": []}],
        "units": [{"node_id": "node-a"}],
        "members": [{"node_id": "node-a"}]
    }});
    let dangling = json!({"program_view": {
        "revision_id": "revision-a",
        "nodes": [{"node_id": "node-a", "child_node_ids": []}],
        "units": [{"node_id": "node-a"}],
        "members": [{"node_id": "elsewhere"}]
    }});
    assert!(see_conformance::comparison::compare(&expected, &resolved).is_empty());
    assert!(!see_conformance::comparison::compare(&expected, &dangling).is_empty());
}

#[test]
fn page_cursor_marker_preserves_element_and_exact_snapshot_checks() {
    let expected = serde_json::json!({"estado_en":{"estado":{"elements":[{"sin_valor":true}],"truncated":true,"next_cursor":"opaque"}}});
    let actual = serde_json::json!({"state_at":{"elements":[{"sin_valor":true}],"truncated":true,"next_cursor":"scope.1","total":2}});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    for changed in [
        serde_json::json!({"state_at":{"elements":[0],"truncated":true,"next_cursor":"scope.1"}}),
        serde_json::json!({"state_at":{"elements":[{"sin_valor":true}],"truncated":true,"next_cursor":""}}),
    ] {
        assert!(!see_conformance::comparison::compare(&expected, &changed).is_empty());
    }
    assert!(
        !see_conformance::comparison::compare(
            &serde_json::json!({"estado_en":{"estado":{"marcos":[]}}}),
            &serde_json::json!({"state_at":{"marcos":[],"extra":true}})
        )
        .is_empty()
    );
}

#[test]
fn compares_pending_effect_tape_status_and_effect_entries_in_both_paths() {
    let expected = json!({
        "terminacion": "awaiting_effect",
        "efecto_pendiente": {"effect_seq": 1, "capability_kind": "clock", "operation": "request_clock"},
        "anfitrion_observado": {
            "llamadas": 0, "recursos_abiertos": 0, "estado_cinta": "non_reproducible_redacted",
            "efectos": [{"effect_seq": 1, "capability_kind": "filesystem", "operation": "file_read_text", "outcome": "committed", "secret_key_id": "k1"}]
        }
    });
    let actual = json!({
        "termination": {"kind": "awaiting_effect", "effect_seq": 1, "capability_kind": "clock", "operation": "request_clock", "arguments_summary": "()"},
        "host_observation": {"calls": 0, "open_resources": 0},
        "effect_tape": {
            "status": "non_reproducible_redacted",
            "entries": [
                {"effect_seq": 1, "capability_kind": "filesystem", "operation": "file_read_text", "outcome": "committed", "secret_reference": "secret:k1:abcdef", "payload_bytes": []},
                {"effect_seq": 2, "capability_kind": "console", "operation": "write", "outcome": "committed", "payload_bytes": [49]}
            ]
        }
    });
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let mut leaked_payload = actual;
    if let Some(payload) = leaked_payload.pointer_mut("/effect_tape/entries/0/payload_bytes") {
        *payload = json!([1]);
    }
    assert!(!see_conformance::comparison::compare(&expected, &leaked_payload).is_empty());
}
