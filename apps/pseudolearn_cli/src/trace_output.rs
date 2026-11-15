use serde_json::Value;

pub fn render(path: &str, source: &str, locale: &str, events: &[Value]) {
    for event in events {
        let line = event["line"].as_u64().unwrap_or(1);
        let source_line = usize::try_from(line.saturating_sub(1))
            .ok()
            .and_then(|index| source.lines().nth(index))
            .unwrap_or("")
            .trim();
        let class = event["class"].as_str().unwrap_or("");
        let key = match class {
            "statement_entered" => "traceStatementEntered",
            "statement_exited" => "traceStatementExited",
            "output" => "traceOutput",
            "call" => "traceCall",
            "return" => "traceReturn",
            "input_requested" => "traceInputRequested",
            "input_received" => "traceInputReceived",
            "failure" => "traceFailure",
            "decision" => decision_key(event),
            _ => continue,
        };
        render_event((path, source_line, locale), event, line, key);
    }
}

fn render_event(location: (&str, &str, &str), event: &Value, line: u64, key: &str) {
    let (path, source, locale) = location;
    let text = event
        .pointer("/data/texto")
        .and_then(Value::as_str)
        .unwrap_or("")
        .replace('\n', "\\n");
    let name = event
        .pointer("/data/nombre")
        .and_then(Value::as_str)
        .unwrap_or("");
    let code = event
        .pointer("/data/codigo")
        .and_then(Value::as_str)
        .unwrap_or("");
    let index = event
        .pointer("/data/indice")
        .map_or(String::new(), Value::to_string);
    eprint!(
        "{}",
        crate::messages::render(
            key,
            locale,
            &[
                ("path", path),
                ("line", &line.to_string()),
                ("source", source),
                ("text", &text),
                ("name", name),
                ("code", code),
                ("index", &index)
            ]
        )
    );
}

fn decision_key(event: &Value) -> &'static str {
    match event.pointer("/data/rama").and_then(Value::as_str) {
        Some("afirmativa") => "traceDecisionAffirmative",
        Some("negativa") => "traceDecisionNegative",
        Some("caso") => "traceDecisionCase",
        Some("defecto") => "traceDecisionDefault",
        _ => "traceDecisionNone",
    }
}
