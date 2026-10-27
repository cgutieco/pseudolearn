use pseudolearn_runtime::{
    EffectSession, ExecutionIdentity, HostReply, HostValue, ReplayError, begin_host_effect,
    configure_host_authority, effect_operation, resolve_host_effect,
};

#[test]
fn effect_protocol_requires_one_matching_resolution() -> Result<(), String> {
    let identity = ExecutionIdentity {
        strictness: "strict".to_owned(),
        limits: Default::default(),
        source_digest: "source".to_owned(),
        package_graph_digest: "none".to_owned(),
        profile: "es".to_owned(),
        seed: 42,
        statement_limit: None,
        permissions: vec!["reloj".to_owned()],
    };
    let mut session = EffectSession::new(identity, 10000);
    configure_host_authority(
        &mut session,
        Some(&serde_json::json!({"permissions":["reloj"]})),
    )
    .map_err(|error| format!("{error:?}"))?;
    let reply = HostReply::Committed(HostValue::Integer(1));
    assert_eq!(
        resolve_host_effect(&mut session, 1, reply.clone()),
        Err(ReplayError::Divergence)
    );
    let operation = effect_operation("request_clock").ok_or("missing operation")?;
    let request = begin_host_effect(&mut session, operation, (None, Vec::new()), 1)
        .map_err(|error| format!("{error:?}"))?;
    assert!(!session.tape().is_reproducible());
    assert_eq!(
        session
            .tape()
            .entries()
            .last()
            .map(|entry| entry.outcome.as_str()),
        Some("requested")
    );
    assert!(begin_host_effect(&mut session, operation, (None, Vec::new()), 1).is_err());
    assert!(resolve_host_effect(&mut session, 2, reply.clone()).is_err());
    let capability = request
        .result_capability
        .ok_or("missing result capability")?;
    let reply = HostReply::Committed(HostValue::Capability(capability));
    assert!(resolve_host_effect(&mut session, 1, reply.clone()).is_ok());
    assert!(session.tape().is_reproducible());
    assert_eq!(session.tape().entries().len(), 1);
    assert!(resolve_host_effect(&mut session, 1, reply).is_err());
    Ok(())
}
