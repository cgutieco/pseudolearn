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
        "service" => service(case, fields),
        "api" => api_request(case, selection.profile, vocabulary, fields)?,
        "app" => app(case, fields)?,
        "analyze" => {
            fields.insert("kind".to_owned(), json!("analyze"));
            fields.insert(
                "program".to_owned(),
                json!(program(case, selection.profile, vocabulary)?),
            );
        }
        _ => execution(case, selection, vocabulary, fields)?,
    }
    if expects_program_view(selection.expected) {
        fields.insert("include_program_view".to_owned(), json!(true));
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
    let mut capabilities = match operation(case) {
        "analyze" => vec!["analyze"],
        "trace" => vec!["execute", "observe"],
        "ir" => vec!["ir"],
        "cli" => vec!["cli"],
        "service" => vec!["service"],
        "api" => vec!["api"],
        "app" => vec!["app"],
        _ => vec!["execute"],
    };
    if requires_service_help(case) {
        capabilities.push("service_help");
    }
    let expects_program_view = case.fields.get("espera").is_some_and(expects_program_view)
        || case
            .fields
            .get("esperas")
            .and_then(Value::as_object)
            .is_some_and(|expected| expected.values().any(expects_program_view));
    if expects_program_view {
        capabilities.push("program_view");
    }
    if case
        .fields
        .get("aplicacion")
        .and_then(|application| application.pointer("/input/transport"))
        .and_then(Value::as_str)
        == Some("wasm")
    {
        capabilities.push("wasm");
    }
    if case.fields.contains_key("paginacion") {
        capabilities.push("state_pages");
    }
    capabilities
}

fn requires_service_help(case: &Block) -> bool {
    operation(case) == "api"
        && case
            .fields
            .get("api")
            .and_then(|value| value.get("calls"))
            .and_then(Value::as_array)
            .is_some_and(|calls| calls.iter().any(is_help_query))
}

fn is_help_query(call: &Value) -> bool {
    call.get("operation").and_then(Value::as_str) == Some("help_query")
}

fn expects_program_view(expected: &Value) -> bool {
    expected.get("vista_programa").is_some()
        || expected
            .get("eventos")
            .and_then(Value::as_array)
            .is_some_and(|events| events.iter().any(|event| event.get("fuente").is_some()))
}

fn app(case: &Block, fields: &mut Map<String, Value>) -> Result<(), String> {
    let application = case
        .fields
        .get("aplicacion")
        .and_then(Value::as_object)
        .ok_or("Missing application case input")?;
    fields.insert("kind".to_owned(), json!("app"));
    for name in ["scenario", "input"] {
        let value = application
            .get(name)
            .ok_or("Incomplete application case input")?;
        fields.insert(name.to_owned(), value.clone());
    }
    Ok(())
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
    if let Some(host) = case.fields.get("anfitrion") {
        fields.insert("host".to_owned(), host.clone());
    }
    if let Some(page) = case.fields.get("paginacion") {
        fields.insert("state_page".to_owned(), page.clone());
    }
    observation_options(case, selection, fields);
    Ok(())
}

fn observation_options(case: &Block, selection: &Selection<'_>, fields: &mut Map<String, Value>) {
    if let Some(statement) = case.fields.get("cancelacion") {
        fields.insert("cancel_at_statement".to_owned(), statement.clone());
    }
    if let Some(poll) = case.fields.get("cancelacion_prueba") {
        fields.insert("cancel_at_poll".to_owned(), poll.clone());
    }
    if let Some(event) = selection
        .expected
        .get("estado_en")
        .and_then(|query| query.get("evento"))
    {
        fields.insert("state_at".to_owned(), event.clone());
    }
}

fn limits(case: &Block) -> Value {
    let mut limits = Map::from_iter([
        ("micro_steps".to_owned(), json!(100_000)),
        ("depth".to_owned(), json!(1000)),
    ]);
    let declared = case.fields.get("limites").and_then(Value::as_object);
    for (name, wire) in [
        ("profundidad", "depth"),
        ("sentencias", "statements"),
        ("celdas", "cells"),
        ("tareas", "tasks"),
        ("capacidad_canal", "channel_capacity"),
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

fn service(case: &Block, fields: &mut Map<String, Value>) {
    let invocation = case_value(case, "servicio", json!({}));
    fields.insert("kind".to_owned(), json!("service"));
    if let Some(map) = invocation.as_object() {
        for (key, value) in map {
            fields.insert(key.clone(), value.clone());
        }
    }
}

fn api_request(
    case: &Block,
    profile: &str,
    vocabulary: &Vocabulary,
    fields: &mut Map<String, Value>,
) -> Result<(), String> {
    let invocation = case
        .fields
        .get("api")
        .and_then(Value::as_object)
        .ok_or("Missing API case input")?;
    let calls = invocation
        .get("calls")
        .and_then(Value::as_array)
        .filter(|calls| !calls.is_empty())
        .ok_or("Missing API calls")?;
    fields.insert("kind".to_owned(), json!("api"));
    if case.fields.contains_key("programa") || case.fields.contains_key("programas") {
        fields.insert(
            "program".to_owned(),
            json!(program(case, profile, vocabulary)?),
        );
    }
    fields.insert("calls".to_owned(), json!(calls));
    Ok(())
}

pub fn applies_to(case: &Block, subject: &str) -> bool {
    !case.fields.contains_key("sujetos")
        || see_model::strings(case.fields.get("sujetos")).contains(&subject)
}
