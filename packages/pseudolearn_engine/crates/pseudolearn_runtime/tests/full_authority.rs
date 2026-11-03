use pseudolearn_runtime::{
    EffectSession, ExecutionIdentity, HostReply, HostValue, begin_host_effect,
    configure_host_authority, effect_operation, resolve_host_effect,
};

#[test]
fn root_capabilities_require_no_grants() -> Result<(), String> {
    for operation in [
        "request_clock",
        "request_timer",
        "request_network",
        "request_arguments",
    ] {
        let mut session = session();
        configure_host_authority(&mut session, None).map_err(|error| format!("{error:?}"))?;
        let operation = effect_operation(operation).ok_or("missing operation")?;
        let request = begin_host_effect(&mut session, operation, (None, vec![]), 0)
            .map_err(|error| format!("{error:?}"))?;
        let capability = request.result_capability.ok_or("missing root capability")?;
        let result = resolve_host_effect(
            &mut session,
            request.effect_seq,
            HostReply::Committed(HostValue::Capability(capability)),
        )
        .map_err(|error| format!("{error:?}"))?;
        assert!(matches!(result, HostReply::Committed(_)));
    }
    Ok(())
}

fn session() -> EffectSession {
    EffectSession::new(
        ExecutionIdentity {
            strictness: "strict".to_owned(),
            limits: Default::default(),
            source_digest: "source".to_owned(),
            package_graph_digest: "none".to_owned(),
            profile: "es".to_owned(),
            seed: 42,
            statement_limit: None,
        },
        65536,
    )
}
