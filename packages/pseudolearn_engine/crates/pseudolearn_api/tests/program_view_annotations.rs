use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn nodes_of(program: &str, profile: &str) -> Result<Vec<Value>, String> {
    let mut session = ApiSession::default();
    let document = session
        .call(
            "create_document",
            &json!({"program": program, "profile": profile}),
        )
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    session
        .call("program_view", &json!({"resource": document}))
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| "missing nodes".to_owned())
}

fn with_syntax<'view>(nodes: &'view [Value], syntax_kind: &str) -> Vec<&'view Value> {
    nodes
        .iter()
        .filter(|node| node.get("syntax_kind").and_then(Value::as_str) == Some(syntax_kind))
        .collect()
}

const ARITHMETIC: &str = "Proceso P\nDefinir x Como Real <- -(2 + 3) * 4 MOD 2 ^ 2;\nEscribir x, \"t\" Sin Saltar;\nFinProceso\n";

#[test]
fn operators_follow_the_tokens_between_operands() -> Result<(), String> {
    let nodes = nodes_of(ARITHMETIC, "es")?;
    let operators: Vec<Value> = nodes
        .iter()
        .filter_map(|node| node.get("operators").cloned())
        .collect();
    for expected in [
        json!(["add"]),
        json!(["multiply"]),
        json!(["modulo"]),
        json!(["power"]),
    ] {
        assert!(operators.contains(&expected), "missing {expected}");
    }
    let unary = with_syntax(&nodes, "unary");
    assert_eq!(
        unary.first().and_then(|node| node.get("operator")),
        Some(&json!("negate"))
    );
    Ok(())
}

#[test]
fn literals_declare_type_and_value_independent_of_the_profile() -> Result<(), String> {
    let program = "Algorithm P\nDefine flag As Boolean <- True;\nEndAlgorithm\n";
    let spanish = nodes_of("Proceso P\nDefinir a Como Entero <- 7;\nFinProceso\n", "es")?;
    let english = nodes_of(program, "en")?;
    let integer = with_syntax(&spanish, "literal");
    assert_eq!(
        integer.first().and_then(|node| node.get("literal")),
        Some(&json!({"type":"integer","value":"7"}))
    );
    let boolean = with_syntax(&english, "literal");
    assert_eq!(
        boolean.first().and_then(|node| node.get("literal")),
        Some(&json!({"type":"boolean","value":"true"}))
    );
    Ok(())
}

#[test]
fn output_marks_the_missing_line_break_and_types_name_their_primitive() -> Result<(), String> {
    let nodes = nodes_of(ARITHMETIC, "es")?;
    let outputs = with_syntax(&nodes, "output");
    assert_eq!(
        outputs.first().and_then(|node| node.get("without_newline")),
        Some(&json!(true))
    );
    let types = with_syntax(&nodes, "type");
    assert_eq!(
        types.first().and_then(|node| node.get("primitive")),
        Some(&json!("real"))
    );
    Ok(())
}

#[test]
fn builtin_calls_are_resolved_and_shadowing_functions_are_not() -> Result<(), String> {
    let builtin = "Proceso P\nDefinir x Como Real <- Raiz(4);\nFinProceso\n";
    let shadowed = "Funcion Raiz(a Como Real) Como Real\nRetornar a;\nFinFuncion\nProceso P\nDefinir x Como Real <- Raiz(4);\nFinProceso\n";
    let resolved = nodes_of(builtin, "es")?;
    let hidden = nodes_of(shadowed, "es")?;
    let names = |nodes: &[Value]| -> Vec<Value> {
        nodes
            .iter()
            .filter_map(|node| node.get("builtin").cloned())
            .collect()
    };
    assert_eq!(names(&resolved), vec![json!("squareRoot")]);
    assert!(names(&hidden).is_empty());
    Ok(())
}

#[test]
fn super_receiver_is_declared_on_the_postfix() -> Result<(), String> {
    let program = "Clase Base\nMetodo Constructor(e Como Entero)\nFinMetodo\nFinClase\nClase Hija Hereda De Base\nMetodo Constructor(e Como Entero)\nSuper.Constructor(e);\nFinMetodo\nFinClase\nProceso P\nFinProceso\n";
    let nodes = nodes_of(program, "es")?;
    let receivers: Vec<Value> = nodes
        .iter()
        .filter_map(|node| node.get("receiver").cloned())
        .collect();
    assert_eq!(receivers, vec![json!("super")]);
    let constructors: Vec<Value> = nodes
        .iter()
        .filter_map(|node| node.get("super_constructor").cloned())
        .collect();
    assert_eq!(constructors, vec![json!(true)]);
    Ok(())
}

#[test]
fn unanalyzable_documents_have_no_view() {
    let mut session = ApiSession::default();
    let document = session
        .call("create_document", &json!({"program": "Proceso P\n"}))
        .pointer("/value/resource")
        .cloned()
        .unwrap_or(Value::Null);
    let view = session.call("program_view", &json!({"resource": document}));
    assert!(view.pointer("/value/nodes").is_none());
}

#[test]
fn every_array_of_a_dimension_declaration_is_its_own_node() -> Result<(), String> {
    let program = "Proceso P\nDimension a[3], b[2, 4] Como Entero;\nFinProceso\n";
    let nodes = nodes_of(program, "es")?;
    assert_eq!(with_syntax(&nodes, "dimensioned").len(), 2);
    Ok(())
}

#[test]
fn subprograms_declare_signature_and_body_roles() -> Result<(), String> {
    let program =
        "Funcion f(a Como Entero) Como Entero\nRetornar a;\nFinFuncion\nProceso P\nFinProceso\n";
    let nodes = nodes_of(program, "es")?;
    let subroutine = with_syntax(&nodes, "subroutine");
    let roles: Vec<Value> = subroutine
        .first()
        .and_then(|node| node.get("child_roles"))
        .and_then(Value::as_array)
        .map(|entries| {
            entries
                .iter()
                .filter_map(|entry| entry.get("role").cloned())
                .collect()
        })
        .unwrap_or_default();
    assert!(roles.contains(&json!("body")));
    assert!(roles.contains(&json!("signature")));
    Ok(())
}

#[test]
fn variants_expose_context_and_binding_attributes() -> Result<(), String> {
    let nodes = nodes_of(
        "algorithm Main\ndefine outcome as result<integer, string> <- success(2);\ndiscard outcome;\nendAlgorithm\n",
        "en",
    )?;
    for expected in [
        json!({"type_constructor":"result"}),
        json!({"variant":"success"}),
        json!({"initialized":true,"mutable":false}),
        json!({"discard":true}),
    ] {
        let object = expected.as_object().ok_or("expected attributes")?;
        assert!(
            nodes.iter().any(|node| object
                .iter()
                .all(|(key, value)| node.get(key) == Some(value))),
            "missing {expected}"
        );
    }
    Ok(())
}
