use see_model::{Block, contract::Vocabulary, field};
use serde_json::{Map, Value, json};

pub struct Selection<'case> {
    pub profile: &'case str,
    pub strictness: &'case str,
    pub expected: &'case Value,
}

pub fn build(
    case: &Block,
    selection: &Selection<'_>,
    vocabulary: &Vocabulary,
) -> Result<Value, String> {
    let strictness = if selection.strictness == "estricto" {
        "strict"
    } else {
        "flexible"
    };
    let mut request = json!({"profile": selection.profile, "strictness": strictness});
    let fields = request.as_object_mut().ok_or("Invalid request skeleton")?;
    match operation(case) {
        "ir" => ir(case, fields),
        "cli" => cli(case, fields),
        "analyze" => {
            fields.insert("kind".to_owned(), json!("analyze"));
            fields.insert(
                "program".to_owned(),
                json!(program(case, selection.profile, vocabulary)?),
            );
        }
        _ => execution(case, selection, vocabulary, fields)?,
    }
    Ok(request)
}

pub fn operation(case: &Block) -> &str {
    match field(case, "operacion") {
        "" => "execute",
        operation => operation,
    }
}

pub fn required_capabilities(case: &Block) -> Vec<&'static str> {
    match operation(case) {
        "analyze" => vec!["analyze"],
        "trace" => vec!["execute", "observe"],
        "ir" => vec!["ir"],
        "cli" => vec!["cli"],
        _ => vec!["execute"],
    }
}

fn program(case: &Block, profile: &str, vocabulary: &Vocabulary) -> Result<String, String> {
    let explicit = case
        .fields
        .get("programas")
        .and_then(|programs| programs.get(profile))
        .and_then(Value::as_str);
    let base = match field(case, "perfil_base") {
        "" => "es",
        base => base,
    };
    match explicit {
        Some(program) => Ok(program.to_owned()),
        None => see_translation::translate(field(case, "programa"), base, profile, vocabulary),
    }
}

fn execution(
    case: &Block,
    selection: &Selection<'_>,
    vocabulary: &Vocabulary,
    fields: &mut Map<String, Value>,
) -> Result<(), String> {
    let observed = operation(case) == "trace";
    fields.insert("kind".to_owned(), json!("execute"));
    fields.insert(
        "program".to_owned(),
        json!(program(case, selection.profile, vocabulary)?),
    );
    fields.insert("inputs".to_owned(), case_value(case, "entradas", json!([])));
    fields.insert("seed".to_owned(), case_value(case, "semilla", json!(42)));
    fields.insert(
        "observe".to_owned(),
        json!(if observed { "events" } else { "none" }),
    );
    fields.insert("limits".to_owned(), limits(case));
    if let Some(statement) = case.fields.get("cancelacion") {
        fields.insert("cancel_at_statement".to_owned(), statement.clone());
    }
    if let Some(event) = selection
        .expected
        .get("estado_en")
        .and_then(|query| query.get("evento"))
    {
        fields.insert("state_at".to_owned(), event.clone());
    }
    Ok(())
}

fn limits(case: &Block) -> Value {
    let mut limits = Map::from_iter([("micro_steps".to_owned(), json!(100_000))]);
    let declared = case.fields.get("limites").and_then(Value::as_object);
    for (name, wire) in [
        ("profundidad", "depth"),
        ("sentencias", "statements"),
        ("celdas", "cells"),
    ] {
        if let Some(value) = declared.and_then(|declared| declared.get(name)) {
            limits.insert(wire.to_owned(), value.clone());
        }
    }
    Value::Object(limits)
}

fn case_value(case: &Block, name: &str, default: Value) -> Value {
    case.fields.get(name).cloned().unwrap_or(default)
}

fn ir(case: &Block, fields: &mut Map<String, Value>) {
    fields.insert("kind".to_owned(), json!("ir"));
    fields.insert(
        "program_ir".to_owned(),
        case_value(case, "programa_ri", json!("")),
    );
}

fn cli(case: &Block, fields: &mut Map<String, Value>) {
    let invocation = case_value(case, "cli", json!({}));
    fields.insert("kind".to_owned(), json!("cli"));
    for (name, wire, default) in [
        ("argumentos", "arguments", json!([])),
        ("entorno", "environment", json!({})),
        ("entrada", "stdin", json!("")),
        ("archivos", "files", json!({})),
    ] {
        let value = invocation.get(name).cloned().unwrap_or(default);
        fields.insert(wire.to_owned(), value);
    }
}
