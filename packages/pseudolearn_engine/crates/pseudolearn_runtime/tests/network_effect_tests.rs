use pseudolearn_runtime::{
    EffectSession, ExecutionIdentity, HostReply, HostValue, HttpMethod, HttpRequestValue,
    MemoryHostProvider, ReproducibilityStatus, configure_host_authority, effect_operation,
    perform_host_effect,
};
use serde_json::{Value, json};

fn identity() -> ExecutionIdentity {
    ExecutionIdentity {
        strictness: "strict".to_owned(),
        limits: Default::default(),
        source_digest: "source".to_owned(),
        package_graph_digest: "graph".to_owned(),
        profile: "es".to_owned(),
        seed: 1,
        statement_limit: None,
        permissions: vec!["red".to_owned()],
    }
}

fn host_configuration() -> Value {
    json!({
        "permissions": ["red"],
        "requested_permissions": ["red"],
        "http": {
            "GET https://fake.test/missing": {
                "estado": 404,
                "cabeceras": [["X-Test", "a"], ["x-test", "b"]],
                "cuerpo_bytes": [0, 255]
            }
        }
    })
}

fn make_host(configuration: &Value) -> Result<MemoryHostProvider, String> {
    MemoryHostProvider::from_value(configuration).map_err(|error| format!("{error:?}"))
}

fn network_capability(
    session: &mut EffectSession,
    host: &mut MemoryHostProvider,
) -> Result<pseudolearn_runtime::HostCapability, String> {
    let operation = effect_operation("request_network").ok_or("missing request operation")?;
    let reply = perform_host_effect(session, host, operation, (None, Vec::new(), 1))
        .map_err(|error| format!("{error:?}"))?;
    let HostReply::Committed(HostValue::Capability(capability)) = reply else {
        return Err(format!("unexpected response: {reply:?}"));
    };
    Ok(capability)
}

fn http_request() -> HostValue {
    HostValue::HttpRequest(HttpRequestValue {
        method: HttpMethod::Get,
        url: "https://fake.test/missing".to_owned(),
        headers: Vec::new(),
        body: None,
        response_limit: None,
        timeout_nanos: None,
    })
}

#[test]
fn rejects_missing_network_permission_before_calling_the_host() -> Result<(), String> {
    let configuration = json!({"permissions": [], "requested_permissions": ["red"]});
    let mut session = EffectSession::new(identity(), 100_000);
    configure_host_authority(&mut session, Some(&configuration))
        .map_err(|error| format!("{error:?}"))?;
    let mut host = make_host(&configuration)?;
    let operation = effect_operation("request_network").ok_or("missing request operation")?;
    let reply = perform_host_effect(&mut session, &mut host, operation, (None, Vec::new(), 1))
        .map_err(|error| format!("{error:?}"))?;
    let HostReply::Failed(failure) = reply else {
        return Err(format!("unexpected response: {reply:?}"));
    };
    assert_eq!(failure.code, "permiso_denegado");
    assert_eq!(host.calls, 0);
    Ok(())
}

#[test]
fn sends_allowed_requests_and_keeps_http_errors_as_committed_values() -> Result<(), String> {
    let configuration = host_configuration();
    let mut session = EffectSession::new(identity(), 100_000);
    configure_host_authority(&mut session, Some(&configuration))
        .map_err(|error| format!("{error:?}"))?;
    let mut host = make_host(&configuration)?;
    let capability = network_capability(&mut session, &mut host)?;
    let operation = effect_operation("network_send").ok_or("missing send operation")?;
    let reply = perform_host_effect(
        &mut session,
        &mut host,
        operation,
        (Some(capability), vec![http_request()], 2),
    )
    .map_err(|error| format!("{error:?}"))?;
    let HostReply::Committed(HostValue::HttpResponse(response)) = reply else {
        return Err(format!("unexpected response: {reply:?}"));
    };
    assert_eq!(response.status, 404);
    assert_eq!(response.body, [0, 255]);
    assert_eq!(host.calls, 2);
    Ok(())
}

#[test]
fn rejects_invalid_requests_without_calling_the_host() -> Result<(), String> {
    let configuration = host_configuration();
    let mut session = EffectSession::new(identity(), 100_000);
    configure_host_authority(&mut session, Some(&configuration))
        .map_err(|error| format!("{error:?}"))?;
    let mut host = make_host(&configuration)?;
    let capability = network_capability(&mut session, &mut host)?;
    let operation = effect_operation("network_send").ok_or("missing send operation")?;
    let invalid = HostValue::HttpRequest(HttpRequestValue {
        method: HttpMethod::Get,
        url: "ftp://fake.test/missing".to_owned(),
        headers: Vec::new(),
        body: None,
        response_limit: None,
        timeout_nanos: None,
    });
    let reply = perform_host_effect(
        &mut session,
        &mut host,
        operation,
        (Some(capability), vec![invalid], 2),
    )
    .map_err(|error| format!("{error:?}"))?;
    let HostReply::Failed(failure) = reply else {
        return Err(format!("unexpected response: {reply:?}"));
    };
    assert_eq!(failure.code, "url_invalida");
    assert_eq!(host.calls, 1);
    Ok(())
}

#[test]
fn replays_http_responses_without_calling_the_host() -> Result<(), String> {
    let configuration = host_configuration();
    let mut recording = EffectSession::new(identity(), 100_000);
    configure_host_authority(&mut recording, Some(&configuration))
        .map_err(|error| format!("{error:?}"))?;
    let mut live_host = make_host(&configuration)?;
    let capability = network_capability(&mut recording, &mut live_host)?;
    let operation = effect_operation("network_send").ok_or("missing send operation")?;
    let reply = perform_host_effect(
        &mut recording,
        &mut live_host,
        operation,
        (Some(capability), vec![http_request()], 2),
    )
    .map_err(|error| format!("{error:?}"))?;
    assert!(matches!(
        reply,
        HostReply::Committed(HostValue::HttpResponse(_))
    ));
    let tape = recording.tape().clone();
    let mut replay =
        EffectSession::from_tape(tape, &identity()).map_err(|error| format!("{error:?}"))?;
    configure_host_authority(&mut replay, Some(&configuration))
        .map_err(|error| format!("{error:?}"))?;
    let mut replay_host = make_host(&configuration)?;
    let capability = network_capability(&mut replay, &mut replay_host)?;
    let reply = perform_host_effect(
        &mut replay,
        &mut replay_host,
        operation,
        (Some(capability), vec![http_request()], 2),
    )
    .map_err(|error| format!("{error:?}"))?;
    assert!(matches!(
        reply,
        HostReply::Committed(HostValue::HttpResponse(_))
    ));
    assert_eq!(replay_host.calls, 0);
    assert_eq!(replay.finish(), Ok(()));
    Ok(())
}

#[test]
fn redacts_authorized_requests_from_the_recorded_tape() -> Result<(), String> {
    let mut configuration = host_configuration();
    let fields = configuration
        .as_object_mut()
        .ok_or("host configuration is not an object")?;
    fields.insert(
        "secrets".to_owned(),
        json!({"authorization": {"key_id": "key-one", "value": "Bearer local-secret"}}),
    );
    fields.insert("secret_keys".to_owned(), json!({"key-one": "local-key"}));
    let mut session = EffectSession::new(identity(), 100_000);
    configure_host_authority(&mut session, Some(&configuration))
        .map_err(|error| format!("{error:?}"))?;
    let mut host = make_host(&configuration)?;
    let capability = network_capability(&mut session, &mut host)?;
    let operation = effect_operation("network_send").ok_or("missing send operation")?;
    let mut request = match http_request() {
        HostValue::HttpRequest(request) => request,
        _ => return Err("missing request value".to_owned()),
    };
    request
        .headers
        .push(("authorization".to_owned(), "Bearer local-secret".to_owned()));
    let reply = perform_host_effect(
        &mut session,
        &mut host,
        operation,
        (Some(capability), vec![HostValue::HttpRequest(request)], 2),
    )
    .map_err(|error| format!("{error:?}"))?;
    assert!(matches!(
        reply,
        HostReply::Committed(HostValue::HttpResponse(_))
    ));
    let tape = serde_json::to_string(session.tape()).map_err(|error| error.to_string())?;
    assert!(!tape.contains("Bearer local-secret"));
    assert_eq!(
        session.tape().status,
        ReproducibilityStatus::NonReproducibleRedacted
    );
    Ok(())
}
