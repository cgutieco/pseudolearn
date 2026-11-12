use pseudolearn_runtime::{
    EffectSession, ExecutionIdentity, HostCapability, HostReply, HostValue, MemoryHostProvider,
    effect_operation, encode_effect_tape, perform_host_effect,
};
use serde_json::json;

fn session(host: &serde_json::Value) -> Result<EffectSession, String> {
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
    pseudolearn_runtime::configure_host_authority(&mut session, Some(host))
        .map_err(|error| format!("{error:?}"))?;
    Ok(session)
}

fn environment_capability(
    session: &mut EffectSession,
    provider: &mut MemoryHostProvider,
) -> Result<HostCapability, String> {
    let operation = effect_operation("request_environment").ok_or("missing operation")?;
    let reply = perform_host_effect(session, provider, operation, (None, Vec::new(), 0))
        .map_err(|error| format!("{error:?}"))?;
    match reply {
        HostReply::Committed(HostValue::Capability(capability)) => Ok(capability),
        other => Err(format!("{other:?}")),
    }
}

fn read(
    session: &mut EffectSession,
    provider: &mut MemoryHostProvider,
    name: &str,
) -> Result<HostReply, String> {
    let capability = environment_capability(session, provider)?;
    let operation = effect_operation("environment_get").ok_or("missing operation")?;
    perform_host_effect(
        session,
        provider,
        operation,
        (Some(capability), vec![HostValue::Text(name.to_owned())], 1),
    )
    .map_err(|error| format!("{error:?}"))
}

fn provider(host: &serde_json::Value) -> Result<MemoryHostProvider, String> {
    MemoryHostProvider::from_value(host).map_err(|error| error.code().to_owned())
}

#[test]
fn a_present_variable_is_returned_exactly_and_an_absent_one_is_none() -> Result<(), String> {
    let host = json!({"environment": {"PL_A": "hola", "PL_EMPTY": "", "PL_U": "ñandú ✓"}});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    let expectations = [
        ("PL_A", Some("hola")),
        ("PL_EMPTY", Some("")),
        ("PL_U", Some("ñandú ✓")),
        ("PL_MISSING", None),
    ];
    for (name, expected) in expectations {
        let reply = read(&mut session, &mut provider, name)?;
        let value = expected.map(str::to_owned);
        assert_eq!(
            reply,
            HostReply::Committed(HostValue::OptionalText(value)),
            "{name}"
        );
    }
    Ok(())
}

#[test]
fn names_are_case_sensitive_in_the_memory_host() -> Result<(), String> {
    let host = json!({"environment": {"PL_A": "x"}});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    let reply = read(&mut session, &mut provider, "pl_a")?;
    assert_eq!(reply, HostReply::Committed(HostValue::OptionalText(None)));
    Ok(())
}

#[test]
fn invalid_names_fail_without_consulting_the_environment() -> Result<(), String> {
    let host = json!({"environment": {"A": "1"}});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    for name in ["", "A=B", "A\0B"] {
        match read(&mut session, &mut provider, name)? {
            HostReply::Failed(error) => assert_eq!(error.code, "peticion_invalida", "{name:?}"),
            other => return Err(format!("{other:?}")),
        }
    }
    Ok(())
}

#[test]
fn an_ordinary_read_keeps_the_tape_reproducible() -> Result<(), String> {
    let host = json!({"environment": {"PL_A": "hola"}});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    read(&mut session, &mut provider, "PL_A")?;
    assert!(session.tape().is_reproducible());
    let entry = session.tape().entries().last().ok_or("missing entry")?;
    assert_eq!(entry.capability_kind, "environment");
    assert_eq!(entry.operation, "environment_get");
    assert_eq!(entry.secret_reference, None);
    Ok(())
}

#[test]
fn a_sensitive_name_redacts_value_and_name_from_the_serialized_tape() -> Result<(), String> {
    let host = json!({"environment": {"MY_API_KEY": "s3cr3t-value", "Db_Password": "p4ss-word"}});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    for name in ["MY_API_KEY", "Db_Password"] {
        read(&mut session, &mut provider, name)?;
    }
    assert!(!session.tape().is_reproducible());
    let reference = session
        .tape()
        .entries()
        .iter()
        .filter_map(|entry| entry.secret_reference.clone())
        .collect::<Vec<_>>();
    assert_eq!(reference.len(), 2);
    assert!(
        reference
            .iter()
            .all(|text| text.starts_with("secret:environment:"))
    );
    let encoded = String::from_utf8(
        encode_effect_tape(session.tape()).map_err(|error| format!("{error:?}"))?,
    )
    .map_err(|error| error.to_string())?;
    for forbidden in ["s3cr3t-value", "p4ss-word", "MY_API_KEY", "Db_Password"] {
        assert!(!encoded.contains(forbidden), "{forbidden}");
    }
    Ok(())
}

#[test]
fn the_reference_of_a_sensitive_read_does_not_depend_on_the_value() -> Result<(), String> {
    let reference = |value: &str| -> Result<String, String> {
        let host = json!({"environment": {"API_TOKEN": value}});
        let mut session = session(&host)?;
        let mut provider = provider(&host)?;
        read(&mut session, &mut provider, "API_TOKEN")?;
        session
            .tape()
            .entries()
            .iter()
            .find_map(|entry| entry.secret_reference.clone())
            .ok_or_else(|| "missing reference".to_owned())
    };
    assert_eq!(reference("one")?, reference("another")?);
    Ok(())
}

#[test]
fn only_the_documented_suffixes_make_a_name_sensitive() -> Result<(), String> {
    let host = json!({"environment": {"KEYBOARD": "a", "TOKEN_COUNT": "b", "PATH": "c"}});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    for name in ["KEYBOARD", "TOKEN_COUNT", "PATH"] {
        read(&mut session, &mut provider, name)?;
    }
    assert!(session.tape().is_reproducible());
    Ok(())
}

#[test]
fn a_local_clock_read_returns_the_declared_offset_with_the_clock_instant() -> Result<(), String> {
    let host = json!({"clock": [1700000000000000000u64], "offset_seconds": 19800});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    let clock = effect_operation("request_clock").ok_or("missing operation")?;
    let capability =
        match perform_host_effect(&mut session, &mut provider, clock, (None, Vec::new(), 0))
            .map_err(|error| format!("{error:?}"))?
        {
            HostReply::Committed(HostValue::Capability(capability)) => capability,
            other => return Err(format!("{other:?}")),
        };
    let local = effect_operation("clock_local_now").ok_or("missing operation")?;
    let reply = perform_host_effect(
        &mut session,
        &mut provider,
        local,
        (Some(capability), Vec::new(), 1),
    )
    .map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        reply,
        HostReply::Committed(HostValue::DateTime(pseudolearn_runtime::DateTimeValue {
            nanos: 1_700_000_000_000_000_000,
            offset_seconds: 19_800,
        }))
    );
    Ok(())
}

#[test]
fn a_local_clock_read_without_clock_readings_fails_with_end_of_file() -> Result<(), String> {
    let host = json!({"clock": []});
    let mut session = session(&host)?;
    let mut provider = provider(&host)?;
    let clock = effect_operation("request_clock").ok_or("missing operation")?;
    let capability =
        match perform_host_effect(&mut session, &mut provider, clock, (None, Vec::new(), 0))
            .map_err(|error| format!("{error:?}"))?
        {
            HostReply::Committed(HostValue::Capability(capability)) => capability,
            other => return Err(format!("{other:?}")),
        };
    let local = effect_operation("clock_local_now").ok_or("missing operation")?;
    match perform_host_effect(
        &mut session,
        &mut provider,
        local,
        (Some(capability), Vec::new(), 1),
    )
    .map_err(|error| format!("{error:?}"))?
    {
        HostReply::Failed(error) => assert_eq!(error.code, "fin_de_archivo"),
        other => return Err(format!("{other:?}")),
    }
    Ok(())
}
