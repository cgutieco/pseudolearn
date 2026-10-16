use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn execution() -> Result<(ApiSession, Value), String> {
    let mut session = ApiSession::default();
    let analysis = session.call(
        "create_analysis",
        &json!({"program":
        "Algoritmo P\nDimension a[2] Como Entero;\na[0] <- 5;\na[1] <- 7;\nFinAlgoritmo\n"}),
    );
    let analysis = analysis
        .pointer("/value/resource")
        .ok_or("missing analysis")?;
    let started = session.call("start", &json!({"analysis":analysis}));
    let resource = started
        .pointer("/value/resource")
        .ok_or("missing execution")?
        .clone();
    Ok((session, resource))
}

#[test]
fn partial_queries_preserve_historical_values_and_validate_ranges() -> Result<(), String> {
    let (mut session, resource) = execution()?;
    let finished = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    assert_eq!(
        finished.pointer("/value/termination/kind"),
        Some(&json!("completed"))
    );
    let query = json!({"resource":resource,"event":3,"reference":1,"start":0,"length":2});
    assert_eq!(
        session.call("query_array_slice", &query),
        json!({"value":[{"valor":"5"},{"sin_valor":true}]})
    );
    let variables = session.call(
        "query_variables",
        &json!({"resource":resource,"event":3,"frame":0}),
    );
    assert_eq!(variables, json!({"value":{"a":{"ref":1}}}));
    for invalid in [
        json!({"reference":1,"start":2,"length":1}),
        json!({"reference":u64::MAX,"start":0,"length":0}),
        json!({"reference":1,"start":u64::MAX,"length":1}),
    ] {
        let mut arguments = invalid;
        let fields = arguments.as_object_mut().ok_or("invalid query")?;
        fields.insert("resource".to_owned(), resource.clone());
        fields.insert("event".to_owned(), json!(3));
        assert_eq!(
            session
                .call("query_array_slice", &arguments)
                .pointer("/failure/family"),
            Some(&json!("usage"))
        );
    }
    assert_eq!(
        session.call(
            "query_array_slice",
            &json!({"resource":resource,"event":3,"reference":1,"start":2,"length":0})
        ),
        json!({"value":[]})
    );
    Ok(())
}

#[test]
fn trimmed_history_rejects_discarded_events_and_cannot_resurrect_them() -> Result<(), String> {
    let (mut session, resource) = execution()?;
    assert_eq!(
        session.call("set_retention", &json!({"resource":resource,"events":1})),
        json!({"value":null})
    );
    session.call("advance", &json!({"resource":resource,"batch_size":4}));
    let expected = session.call("query_state", &json!({"resource":resource,"event":3}));
    assert!(expected.get("value").is_some(), "{expected}");
    assert_eq!(
        session.call("horizon", &json!({"resource":resource})),
        json!({"value":{"first":3,"last":3}})
    );
    assert_eq!(
        session
            .call("query_state", &json!({"resource":resource,"event":2}))
            .pointer("/failure/family"),
        Some(&json!("usage"))
    );
    session.call("set_retention", &json!({"resource":resource,"events":4096}));
    assert_eq!(
        session.call("query_state", &json!({"resource":resource,"event":3})),
        expected
    );
    let terminal = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    assert_eq!(
        terminal.pointer("/value/termination/kind"),
        Some(&json!("completed"))
    );
    assert_eq!(
        session
            .call("query_state", &json!({"resource":resource,"event":2}))
            .pointer("/failure/family"),
        Some(&json!("usage"))
    );
    assert_eq!(
        session.call("query_state", &json!({"resource":resource,"event":3})),
        expected
    );
    Ok(())
}
