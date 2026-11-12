use serde_json::json;

#[test]
fn rejects_unknown_properties_wrong_types_and_deep_inputs() {
    let schema = json!({"type":"object", "required":["count"], "properties":{"count":{"type":"integer","minimum":1}}, "additionalProperties":false});
    assert!(see_validation::schema_engine::check(&json!({"count":1}), &schema, &schema, 0).is_ok());
    for invalid in [
        json!({}),
        json!({"count":0}),
        json!({"count":true}),
        json!({"count":1,"extra":1}),
    ] {
        assert!(see_validation::schema_engine::check(&invalid, &schema, &schema, 0).is_err());
    }
    assert!(
        see_validation::schema_engine::check(&json!({"count":1}), &schema, &schema, 65).is_err()
    );
}

#[test]
fn checks_arrays_references_and_nullable_alternatives() {
    let schema = json!({"type":"array", "minItems":1, "uniqueItems":true, "items":{"$ref":"#/$defs/text"}, "$defs":{"text":{"anyOf":[{"type":"null"},{"type":"string","minLength":1}]}}});
    assert!(see_validation::schema_engine::check(&json!(["a", null]), &schema, &schema, 0).is_ok());
    for invalid in [json!([]), json!(["a", "a"]), json!([""]), json!([7])] {
        assert!(see_validation::schema_engine::check(&invalid, &schema, &schema, 0).is_err());
    }
}

#[test]
fn checks_upper_bounds_and_negated_shapes() {
    let schema = json!({
        "type":"object",
        "properties":{
            "status":{"type":"integer","minimum":100,"maximum":599},
            "headers":{"type":"array","maxItems":2,"items":{"type":"string"}},
            "body":{"type":"string"},
            "body_bytes":{"type":"array"}
        },
        "not":{"required":["body","body_bytes"]}
    });
    for valid in [
        json!({"status":100,"headers":[]}),
        json!({"status":599,"headers":["a","b"],"body":"text"}),
        json!({"status":200,"body_bytes":[0,255]}),
    ] {
        assert!(see_validation::schema_engine::check(&valid, &schema, &schema, 0).is_ok());
    }
    for invalid in [
        json!({"status":600}),
        json!({"status":99}),
        json!({"status":200,"headers":["a","b","c"]}),
        json!({"status":200,"body":"text","body_bytes":[0]}),
    ] {
        assert!(see_validation::schema_engine::check(&invalid, &schema, &schema, 0).is_err());
    }
}
