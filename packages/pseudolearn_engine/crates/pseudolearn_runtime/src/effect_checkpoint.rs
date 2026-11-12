use crate::{EffectSession, EffectTape, ReplayError};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct EffectCheckpoint {
    sequence: u64,
    cursor: u64,
    reserved: std::collections::BTreeMap<u64, u64>,
    authority: crate::effect_authority::EffectAuthority,
}

pub fn capture_effect_checkpoint(session: &EffectSession) -> EffectCheckpoint {
    EffectCheckpoint {
        sequence: session.sequence,
        cursor: session.replay.as_ref().map_or_else(
            || u64::try_from(session.tape.entries.len()).unwrap_or(u64::MAX),
            |replay| u64::try_from(replay.cursor).unwrap_or(u64::MAX),
        ),
        reserved: session.reserved.clone(),
        authority: session.authority.clone(),
    }
}

pub fn replay_effect_checkpoint(
    tape: &EffectTape,
    checkpoint: &EffectCheckpoint,
) -> Result<EffectSession, ReplayError> {
    let replay = crate::TapeReplayProvider::history(tape.clone())?;
    let mut session = EffectSession {
        tape: tape.clone(),
        replay: Some(replay),
        sequence: 0,
        authority: Default::default(),
        pending: None,
        secrets: Default::default(),
        current_task: 0,
        reserved: Default::default(),
        active_reservation: None,
    };
    let cursor = usize::try_from(checkpoint.cursor).map_err(|_| ReplayError::Divergence)?;
    let provider = session.replay.as_mut().ok_or(ReplayError::Divergence)?;
    if cursor > tape.entries.len() {
        return Err(ReplayError::TruncatedTape);
    }
    provider.cursor = cursor;
    session.sequence = checkpoint.sequence;
    session.reserved.clone_from(&checkpoint.reserved);
    session.authority = checkpoint.authority.clone();
    Ok(session)
}
