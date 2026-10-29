use pseudolearn_runtime::{
    EffectSession, EffectTape, ExecutionIdentity, HostEffectProvider, HostEffectRequest, HostReply,
    HostValue, IoError, ReplayError, TapeEntry, configure_host_authority, effect_operation,
    perform_host_effect,
};

struct CountingHost {
    calls: usize,
}

impl HostEffectProvider for CountingHost {
    fn perform(&mut self, request: &HostEffectRequest) -> HostReply {
        self.calls = self.calls.saturating_add(1);
        match &request.result_capability {
            Some(capability) => HostReply::Committed(HostValue::Capability(capability.clone())),
            None => HostReply::failure(IoError::permission_denied()),
        }
    }

    fn close_all(&mut self) {}
}

fn identity() -> ExecutionIdentity {
    ExecutionIdentity {
        strictness: "strict".to_owned(),
        limits: Default::default(),
        source_digest: "source".to_owned(),
        package_graph_digest: "graph".to_owned(),
        profile: "es".to_owned(),
        seed: 42,
        statement_limit: None,
        permissions: vec!["reloj".to_owned()],
    }
}

fn authorize(session: &mut EffectSession) -> Result<(), String> {
    configure_host_authority(session, Some(&serde_json::json!({"permissions":["reloj"]})))
        .map_err(|error| format!("{error:?}"))
}

fn request_clock(
    session: &mut EffectSession,
    host: &mut CountingHost,
    operation: &str,
) -> Result<HostReply, ReplayError> {
    let operation = effect_operation(operation).ok_or(ReplayError::Divergence)?;
    perform_host_effect(session, host, operation, (None, Vec::new(), 1))
}

fn recorded_tape() -> Result<EffectTape, String> {
    let mut session = EffectSession::new(identity(), 100_000);
    authorize(&mut session)?;
    let mut live = CountingHost { calls: 0 };
    request_clock(&mut session, &mut live, "request_clock")
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(live.calls, 1);
    Ok(session.tape().clone())
}

fn rebuilt(tape: &EffectTape, change: impl Fn(&mut TapeEntry)) -> EffectTape {
    let mut copy = EffectTape::new(tape.identity.clone());
    for entry in tape.entries() {
        let mut changed = entry.clone();
        change(&mut changed);
        copy.append(changed);
    }
    copy
}

fn replay_session(tape: EffectTape) -> Result<EffectSession, ReplayError> {
    let mut session = EffectSession::from_tape(tape, &identity())?;
    configure_host_authority(
        &mut session,
        Some(&serde_json::json!({"permissions":["reloj"]})),
    )
    .map_err(|_| ReplayError::Divergence)?;
    Ok(session)
}

#[test]
fn intact_tape_replays_the_recorded_reply_without_the_host() -> Result<(), String> {
    let tape = recorded_tape()?;
    let mut session = replay_session(tape).map_err(|error| format!("{error:?}"))?;
    let mut host = CountingHost { calls: 0 };
    let reply = request_clock(&mut session, &mut host, "request_clock");
    assert!(reply.is_ok(), "{reply:?}");
    assert_eq!(host.calls, 0);
    assert_eq!(session.finish(), Ok(()));
    Ok(())
}

#[test]
fn identity_mismatch_is_rejected_before_any_effect() -> Result<(), String> {
    let tape = recorded_tape()?;
    let mut other = identity();
    other.seed = 7;
    let rejected = EffectSession::from_tape(tape, &other);
    assert_eq!(rejected.err(), Some(ReplayError::IdentityMismatch));
    Ok(())
}

#[test]
fn divergent_operation_is_rejected_without_the_host() -> Result<(), String> {
    let tape = recorded_tape()?;
    let mut session = replay_session(tape).map_err(|error| format!("{error:?}"))?;
    let mut host = CountingHost { calls: 0 };
    let reply = request_clock(&mut session, &mut host, "request_timer");
    assert_eq!(reply.err(), Some(ReplayError::Divergence));
    assert_eq!(host.calls, 0);
    Ok(())
}

#[test]
fn divergent_request_digest_is_rejected_without_the_host() -> Result<(), String> {
    let tape = recorded_tape()?;
    let altered = rebuilt(&tape, |entry| entry.request_digest.push_str("-altered"));
    let mut session = replay_session(altered).map_err(|error| format!("{error:?}"))?;
    let mut host = CountingHost { calls: 0 };
    let reply = request_clock(&mut session, &mut host, "request_clock");
    assert_eq!(reply.err(), Some(ReplayError::Divergence));
    assert_eq!(host.calls, 0);
    Ok(())
}

#[test]
fn exhausted_tape_is_rejected_without_the_host() -> Result<(), String> {
    let tape = recorded_tape()?;
    let mut session = replay_session(EffectTape::new(tape.identity.clone()))
        .map_err(|error| format!("{error:?}"))?;
    let mut host = CountingHost { calls: 0 };
    let reply = request_clock(&mut session, &mut host, "request_clock");
    assert_eq!(reply.err(), Some(ReplayError::TruncatedTape));
    assert_eq!(host.calls, 0);
    Ok(())
}

#[test]
fn unconsumed_entries_reject_the_end_of_the_replay() -> Result<(), String> {
    let tape = recorded_tape()?;
    let session = replay_session(tape).map_err(|error| format!("{error:?}"))?;
    assert_eq!(session.finish(), Err(ReplayError::Divergence));
    Ok(())
}

#[test]
fn altered_hash_payload_or_sequence_is_rejected_as_corrupted() -> Result<(), String> {
    let tape = recorded_tape()?;
    let mut hash = tape.clone();
    let mut payload = tape.clone();
    let mut sequence = tape.clone();
    for (copy, change) in [(&mut hash, 0), (&mut payload, 1), (&mut sequence, 2)] {
        let entry = copy.entries.first_mut().ok_or("missing entry")?;
        match change {
            0 => entry.entry_hash.push('0'),
            1 => entry.payload_bytes.push(1),
            _ => entry.effect_seq = 9,
        }
        assert_eq!(
            EffectSession::from_tape(copy.clone(), &identity()).err(),
            Some(ReplayError::CorruptedTape)
        );
    }
    Ok(())
}

#[test]
fn incomplete_tape_is_rejected_as_non_reproducible() -> Result<(), String> {
    let mut tape = recorded_tape()?;
    tape.mark_incomplete();
    assert_eq!(
        EffectSession::from_tape(tape, &identity()).err(),
        Some(ReplayError::NonReproducible)
    );
    Ok(())
}
