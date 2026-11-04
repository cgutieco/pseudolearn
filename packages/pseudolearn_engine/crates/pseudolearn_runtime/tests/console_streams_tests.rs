use pseudolearn_runtime::{
    EffectSession, ExecutionIdentity, HostCapability, HostReply, HostValue, MemoryHostProvider,
    effect_operation, perform_host_effect,
};

fn session() -> Result<EffectSession, String> {
    let mut session = EffectSession::new(
        ExecutionIdentity {
            limits: Default::default(),
            source_digest: "source".to_owned(),
            package_graph_digest: "none".to_owned(),
            profile: "es".to_owned(),
            seed: 42,
            statement_limit: None,
        },
        1 << 20,
    );
    pseudolearn_runtime::configure_host_authority(&mut session, Some(&serde_json::json!({})))
        .map_err(|error| format!("{error:?}"))?;
    Ok(session)
}

fn console(
    session: &mut EffectSession,
    provider: &mut MemoryHostProvider,
) -> Result<HostCapability, String> {
    let operation = effect_operation("request_console").ok_or("missing operation")?;
    match perform_host_effect(session, provider, operation, (None, Vec::new(), 0))
        .map_err(|error| format!("{error:?}"))?
    {
        HostReply::Committed(HostValue::Capability(capability)) => Ok(capability),
        other => Err(format!("{other:?}")),
    }
}

fn call(
    identity: &str,
    argument: HostValue,
    provider: &mut MemoryHostProvider,
) -> Result<HostReply, String> {
    let mut session = session()?;
    let capability = console(&mut session, provider)?;
    let operation = effect_operation(identity).ok_or("missing operation")?;
    perform_host_effect(
        &mut session,
        provider,
        operation,
        (Some(capability), vec![argument], 1),
    )
    .map_err(|error| format!("{error:?}"))
}

#[test]
fn error_text_goes_to_the_error_buffer_and_never_to_the_output() -> Result<(), String> {
    let mut provider = MemoryHostProvider::new();
    let reply = call(
        "console_write_error",
        HostValue::Text("é\n".to_owned()),
        &mut provider,
    )?;
    assert!(matches!(reply, HostReply::Committed(HostValue::Integer(3))));
    assert_eq!(provider.error_output, "é\n");
    assert_eq!(provider.output, "");
    Ok(())
}

#[test]
fn empty_error_text_writes_zero_bytes() -> Result<(), String> {
    let mut provider = MemoryHostProvider::new();
    let reply = call(
        "console_write_error",
        HostValue::Text(String::new()),
        &mut provider,
    )?;
    assert!(matches!(reply, HostReply::Committed(HostValue::Integer(0))));
    Ok(())
}

#[test]
fn exit_codes_inside_the_range_are_committed() -> Result<(), String> {
    for code in [0_i64, 1, 7, 255] {
        let mut provider = MemoryHostProvider::new();
        let reply = call("console_set_exit_code", HostValue::Integer(code), &mut provider)?;
        assert!(
            matches!(reply, HostReply::Committed(HostValue::Integer(value)) if value == code),
            "{code}"
        );
    }
    Ok(())
}

#[test]
fn exit_codes_outside_the_range_are_rejected() -> Result<(), String> {
    for code in [-1_i64, 256, i64::MAX, i64::MIN] {
        let mut provider = MemoryHostProvider::new();
        let reply = call("console_set_exit_code", HostValue::Integer(code), &mut provider)?;
        assert!(matches!(reply, HostReply::Failed(_)), "{code}: {reply:?}");
    }
    Ok(())
}
