use pseudolearn_api::fake_host::FakeHostProvider;
use pseudolearn_api::tape_wire::{tape_from_value, tape_to_value};
use pseudolearn_api::{ApiSession, compile_source_to_ir};
use pseudolearn_runtime::{
    EffectTape, HostEffectProvider, HostEffectRequest, HostReply, HostValue, HttpMethod,
    HttpRequestValue,
};
use serde_json::{Value, json};

fn request(method: HttpMethod, url: &str) -> HostEffectRequest {
    HostEffectRequest {
        effect_seq: 1,
        operation: "network_send".to_owned(),
        receiver: None,
        arguments: vec![HostValue::HttpRequest(HttpRequestValue {
            method,
            url: url.to_owned(),
            headers: Vec::new(),
            body: None,
            response_limit: None,
            timeout_nanos: None,
            effective_response_limit: None,
            effective_timeout_nanos: None,
            wire_limit: None,
            header_bytes_limit: None,
            headers_limit: None,
        })],
        result_capability: None,
        source_node_id: 1,
    }
}

#[test]
fn returns_http_error_status_as_a_response() -> Result<(), String> {
    let configuration = json!({
        "permissions": ["red"],
        "requested_permissions": ["red"],
        "http": {
            "GET https://fake.test/missing": {
                "estado": 404,
                "cuerpo": "missing"
            }
        }
    });
    let mut host =
        FakeHostProvider::from_value(&configuration).map_err(|error| format!("{error:?}"))?;
    let reply = host.perform(&request(HttpMethod::Get, "https://fake.test/missing"));
    let HostReply::Committed(HostValue::HttpResponse(response)) = reply else {
        return Err(format!("unexpected response: {reply:?}"));
    };
    assert_eq!(response.status, 404);
    assert_eq!(response.body, b"missing");
    Ok(())
}

#[test]
fn preserves_uncertain_outcomes_for_mutating_methods() -> Result<(), String> {
    let configuration = json!({
        "permissions": ["red"],
        "requested_permissions": ["red"],
        "http": {
            "POST https://fake.test/write": {
                "fallo": "conexion_fallida",
                "incierto": true
            }
        }
    });
    let mut host =
        FakeHostProvider::from_value(&configuration).map_err(|error| format!("{error:?}"))?;
    let reply = host.perform(&request(HttpMethod::Post, "https://fake.test/write"));
    let HostReply::Uncertain(failure) = reply else {
        return Err(format!("unexpected response: {reply:?}"));
    };
    assert!(failure.uncertain);
    assert_eq!(failure.code, "conexion_fallida");
    Ok(())
}

#[test]
fn reports_missing_http_scripts_without_network_access() -> Result<(), String> {
    let configuration = json!({
        "permissions": ["red"],
        "requested_permissions": ["red"]
    });
    let mut host =
        FakeHostProvider::from_value(&configuration).map_err(|error| format!("{error:?}"))?;
    let reply = host.perform(&request(HttpMethod::Get, "https://fake.test/missing"));
    let HostReply::Failed(failure) = reply else {
        return Err(format!("unexpected response: {reply:?}"));
    };
    assert_eq!(failure.code, "conexion_fallida");
    Ok(())
}

#[test]
fn records_and_replays_http_error_responses_without_the_host() -> Result<(), String> {
    let corpus = include_str!("../../../../pseudolearn_spec/specifications/lib/lib.http.md");
    let case = corpus
        .split("```caso\n")
        .skip(1)
        .filter_map(|block| block.split("\n```").next())
        .filter_map(|block| serde_json::from_str::<serde_json::Value>(block).ok())
        .find(|case| case.get("id").and_then(serde_json::Value::as_str) == Some("C4"))
        .ok_or("missing HTTP error status case")?;
    let program = case
        .pointer("/programas/es")
        .and_then(serde_json::Value::as_str)
        .ok_or("missing Spanish HTTP program")?;
    let host = case
        .get("anfitrion")
        .cloned()
        .ok_or("missing HTTP fake host")?;
    let request = json!({
        "program": program,
        "profile": "es",
        "strictness": "strict",
        "host": host
    });
    compile_source_to_ir(program, "es", "strict")
        .map_err(|diagnostics| format!("HTTP lowering failed: {diagnostics:?}"))?;
    let mut api = ApiSession::default();
    let recording = api.call(
        "record",
        &json!({"request": request, "options": {"capture_states": false}}),
    );
    let value = recording
        .get("value")
        .ok_or_else(|| format!("HTTP recording failed: {recording}"))?;
    assert_eq!(
        value.pointer("/termination/kind"),
        Some(&json!("completed"))
    );
    let mut replay_request = request;
    let fields = replay_request
        .as_object_mut()
        .ok_or("HTTP request is not an object")?;
    fields.insert("execution_mode".to_owned(), json!("replay_from_tape"));
    fields.insert(
        "effect_tape".to_owned(),
        value
            .get("effect_tape")
            .cloned()
            .ok_or("missing HTTP effect tape")?,
    );
    let replay = api.call(
        "record",
        &json!({"request": replay_request, "options": {"capture_states": false}}),
    );
    assert_eq!(replay.pointer("/value/output"), value.get("output"));
    assert_eq!(
        replay.pointer("/value/host_observation/calls"),
        Some(&json!(0))
    );
    Ok(())
}

#[test]
fn replays_concurrent_http_deliveries_with_an_identity_only_host() -> Result<(), String> {
    let corpus = include_str!("../../../../pseudolearn_spec/specifications/lib/lib.http.md");
    let case = corpus
        .split("```caso\n")
        .skip(1)
        .filter_map(|block| block.split("\n```").next())
        .filter_map(|block| serde_json::from_str::<serde_json::Value>(block).ok())
        .find(|case| case.get("id").and_then(serde_json::Value::as_str) == Some("C10"))
        .ok_or("missing concurrent HTTP case")?;
    let program = case
        .pointer("/programas/es")
        .and_then(serde_json::Value::as_str)
        .ok_or("missing Spanish HTTP program")?;
    let host = case
        .get("anfitrion")
        .cloned()
        .ok_or("missing HTTP fake host")?;
    let mut api = ApiSession::default();
    let recording = api.call(
        "record",
        &json!({"request": {"program": program, "profile": "es", "strictness": "strict", "host": host},
            "options": {"capture_states": false}}),
    );
    let value = recording
        .get("value")
        .ok_or_else(|| format!("HTTP recording failed: {recording}"))?;
    let identity_host = json!({"permissions": ["red"], "requested_permissions": ["red"]});
    let replay = api.call(
        "record",
        &json!({"request": {"program": program, "profile": "es", "strictness": "strict",
            "host": identity_host, "execution_mode": "replay_from_tape",
            "effect_tape": value.get("effect_tape").cloned().ok_or("missing HTTP effect tape")?},
            "options": {"capture_states": false}}),
    );
    assert_eq!(
        replay.pointer("/value/output"),
        value.get("output"),
        "{replay}"
    );
    assert_eq!(
        replay.pointer("/value/host_observation/calls"),
        Some(&json!(0))
    );
    Ok(())
}

#[test]
fn executes_http_corpus_cases_with_the_memory_host() -> Result<(), String> {
    for (corpus, only_rule) in [
        (
            include_str!("../../../../pseudolearn_spec/specifications/lib/lib.http.md"),
            None,
        ),
        (
            include_str!("../../../../pseudolearn_spec/specifications/eng/eng.limits.md"),
            Some("R13"),
        ),
    ] {
        for block in corpus.split("```caso\n").skip(1) {
            let body = block.split("\n```").next().ok_or("missing case body")?;
            let case: serde_json::Value =
                serde_json::from_str(body).map_err(|error| error.to_string())?;
            verify_http_corpus_case(&case, only_rule)?;
        }
    }
    Ok(())
}

fn verify_http_corpus_case(case: &Value, only_rule: Option<&str>) -> Result<(), String> {
    if only_rule.is_some_and(|rule| case.get("regla").and_then(Value::as_str) != Some(rule))
        || case.get("anfitrion").is_none()
    {
        return Ok(());
    }
    let case_id = case
        .get("id")
        .and_then(Value::as_str)
        .ok_or("missing HTTP case identity")?;
    for profile in ["es", "en"] {
        let value = execute_http_case(case, case_id, profile)?;
        let expected = expected_http_output(case, profile)?;
        assert_eq!(
            value.get("output"),
            Some(&json!(expected)),
            "{case_id} {profile}: {value}"
        );
        assert_eq!(
            value.pointer("/termination/kind"),
            Some(&json!("completed"))
        );
        assert_http_observation(case, case_id, &value)?;
    }
    Ok(())
}

fn execute_http_case(case: &Value, case_id: &str, profile: &str) -> Result<Value, String> {
    let program = case
        .pointer(&format!("/programas/{profile}"))
        .and_then(Value::as_str)
        .ok_or("missing HTTP program")?;
    compile_source_to_ir(program, profile, "strict")
        .map_err(|diagnostics| format!("case {case_id} lowering failed: {diagnostics:?}"))?;
    let host = case.get("anfitrion").cloned().ok_or("missing HTTP host")?;
    let mut api = ApiSession::default();
    let result = api.call(
        "record",
        &json!({
            "request": {
                "program": program,
                "profile": profile,
                "strictness": "strict",
                "limits": case.get("limites").cloned().unwrap_or_else(|| json!({})),
                "host": host
            },
            "options": {"capture_states": false}
        }),
    );
    result
        .get("value")
        .cloned()
        .ok_or_else(|| format!("case {case_id} failed: {result}"))
}

fn expected_http_output(case: &Value, profile: &str) -> Result<String, String> {
    let (false_lexeme, true_lexeme) = if profile == "es" {
        ("Falso", "Verdadero")
    } else {
        ("false", "true")
    };
    case.pointer("/espera/salida")
        .and_then(Value::as_str)
        .map(|output| {
            output
                .replace("{{lexema:booleanFalse}}", false_lexeme)
                .replace("{{lexema:booleanTrue}}", true_lexeme)
        })
        .ok_or_else(|| "missing expected output".to_owned())
}

fn assert_http_observation(case: &Value, case_id: &str, value: &Value) -> Result<(), String> {
    if let Some(expected_calls) = case.pointer("/espera/anfitrion_observado/llamadas") {
        assert_eq!(
            value.pointer("/host_observation/calls"),
            Some(expected_calls)
        );
    }
    if ["C10", "C12"].contains(&case_id) {
        let expected_effects = case
            .pointer("/espera/anfitrion_observado/efectos")
            .and_then(Value::as_array)
            .ok_or("missing concurrent HTTP effects")?;
        assert_http_effects(expected_effects, value)?;
    }
    Ok(())
}

fn assert_http_effects(expected: &[Value], execution: &Value) -> Result<(), String> {
    let network_effects: Vec<_> = execution
        .pointer("/effect_tape/entries")
        .and_then(Value::as_array)
        .ok_or("missing HTTP effect tape")?
        .iter()
        .filter(|entry| entry.get("capability_kind").and_then(Value::as_str) == Some("network"))
        .collect();
    assert_eq!(network_effects.len(), expected.len());
    for (expected_entry, actual_entry) in expected.iter().zip(network_effects) {
        for field in [
            "effect_seq",
            "task_id",
            "delivery_seq",
            "capability_kind",
            "operation",
            "outcome",
        ] {
            if let Some(expected_value) = expected_entry.get(field) {
                assert_eq!(actual_entry.get(field), Some(expected_value));
            }
        }
    }
    Ok(())
}

#[test]
fn rejects_http_request_digest_divergence_with_no_scripted_response() -> Result<(), String> {
    let program = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n";
    let host = json!({
        "permissions": ["red"],
        "requested_permissions": ["red"],
        "http": {"GET https://fake.test/a": {"estado": 200}}
    });
    compile_source_to_ir(program, "es", "strict")
        .map_err(|diagnostics| format!("HTTP lowering failed: {diagnostics:?}"))?;
    let mut api = ApiSession::default();
    let recording = api.call(
        "record",
        &json!({"request":{"program":program,"profile":"es","strictness":"strict","host":host},"options":{"capture_states":false}}),
    );
    let tape_value = recording
        .pointer("/value/effect_tape")
        .ok_or_else(|| format!("HTTP recording failed: {recording}"))?;
    let changed_tape = altered_http_request_tape(tape_value)?;
    let replay_host = json!({"permissions":["red"],"requested_permissions":["red"]});
    assert_eq!(
        replay_http_tape(program, &replay_host, &changed_tape)?.pointer("/failure/detail"),
        Some(&json!("Invalid protocol: replay_divergence"))
    );
    Ok(())
}

fn replay_http_tape(
    program: &str,
    host: &serde_json::Value,
    effect_tape: &serde_json::Value,
) -> Result<serde_json::Value, String> {
    let mut api = ApiSession::default();
    let analysis = api.call("create_analysis", &json!({"program":program}));
    let started = api.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":program,"profile":"es",
            "strictness":"strict","seed":42,"host":host,"execution_mode":"replay_from_tape",
            "effect_tape":effect_tape}),
    );
    if started.get("failure").is_some() {
        return Ok(started);
    }
    Ok(api.call(
        "advance",
        &json!({"resource":started.pointer("/value/resource"),"batch_size":1000}),
    ))
}

fn altered_http_request_tape(tape_value: &serde_json::Value) -> Result<serde_json::Value, String> {
    let original = tape_from_value(tape_value).map_err(|failure| format!("{failure:?}"))?;
    let mut changed = EffectTape::new(original.identity.clone());
    let mut altered_requests = 0_usize;
    for mut entry in original.entries().iter().cloned() {
        if entry.operation == "network_send" {
            entry.request_digest.push_str("-altered");
            altered_requests = altered_requests.saturating_add(1);
        }
        changed.append(entry);
    }
    if altered_requests == 0 {
        return Err("missing network_send tape entry".to_owned());
    }
    Ok(tape_to_value(&changed))
}
