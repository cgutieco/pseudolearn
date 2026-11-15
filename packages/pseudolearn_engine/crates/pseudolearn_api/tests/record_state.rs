use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const POINT: &str = "record Point\ndefine x, y as integer;\nendRecord\n";

fn final_state(program: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let analysis = session
        .call(
            "create_analysis",
            &json!({"program":program,"profile":"en"}),
        )
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis")?;
    let execution = session
        .call("start", &json!({"analysis":analysis}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing execution")?;
    session.call("advance", &json!({"resource":execution,"batch_size":4096}));
    let last = session
        .call("horizon", &json!({"resource":execution}))
        .pointer("/value/last")
        .and_then(Value::as_u64)
        .ok_or("missing horizon")?;
    Ok(session.call("query_state", &json!({"resource":execution,"event":last})))
}

#[test]
fn a_class_field_record_is_listed_by_leaf_names_inside_the_object() -> Result<(), String> {
    let program = format!(
        "{POINT}class Holder\npublic define p as Point;\nmethod constructor()\nthis.p <- Point(1, 2);\nendMethod\nendClass\nalgorithm P\ndefine h as Holder <- new Holder();\nwrite h.p.x;\nendAlgorithm\n"
    );
    let state = final_state(&program)?;
    assert_eq!(
        state.pointer("/value/objetos/1/clase"),
        Some(&json!("Holder"))
    );
    assert_eq!(
        state.pointer("/value/objetos/1/campos/p.x/valor"),
        Some(&json!("1"))
    );
    assert_eq!(
        state.pointer("/value/objetos/1/campos/p.y/valor"),
        Some(&json!("2"))
    );
    Ok(())
}

#[test]
fn a_record_array_is_listed_as_one_array_per_leaf_named_after_the_leaf() -> Result<(), String> {
    let program = format!(
        "{POINT}algorithm P\ndimension a[2] as Point;\na[0] <- Point(1, 2);\na[1] <- Point(3, 4);\ndefine q as Point <- a[1];\nwrite q.x;\nendAlgorithm\n"
    );
    let state = final_state(&program)?;
    let variables = state
        .pointer("/value/marcos/0/variables")
        .ok_or("missing variables")?;
    assert_eq!(variables.pointer("/q.x/valor"), Some(&json!("3")));
    assert_eq!(variables.pointer("/q.y/valor"), Some(&json!("4")));
    for (leaf, cells) in [("a.x", json!(["1", "3"])), ("a.y", json!(["2", "4"]))] {
        let reference = variables
            .pointer(&format!("/{leaf}/ref"))
            .and_then(Value::as_u64)
            .ok_or_else(|| format!("missing reference for {leaf}"))?;
        let observed: Vec<Value> = state
            .pointer(&format!("/value/objetos/{reference}/arreglo/celdas"))
            .and_then(Value::as_array)
            .ok_or("missing cells")?
            .iter()
            .filter_map(|cell| cell.get("valor").cloned())
            .collect();
        assert_eq!(Value::Array(observed), cells, "{leaf}");
    }
    Ok(())
}

#[test]
fn an_unset_leaf_cell_has_no_value_in_the_state() -> Result<(), String> {
    let program = format!(
        "{POINT}algorithm P\ndimension a[2] as Point;\na[0].x <- 1;\nwrite a[0].x;\nendAlgorithm\n"
    );
    let state = final_state(&program)?;
    let reference = state
        .pointer("/value/marcos/0/variables/a.y/ref")
        .and_then(Value::as_u64)
        .ok_or("missing reference")?;
    let cells = state
        .pointer(&format!("/value/objetos/{reference}/arreglo/celdas"))
        .and_then(Value::as_array)
        .ok_or("missing cells")?;
    assert!(
        cells.iter().all(|cell| cell.get("valor").is_none()),
        "{cells:?}"
    );
    Ok(())
}
