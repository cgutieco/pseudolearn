use crate::{EffectSession, EffectTape, ReplayError};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct EffectCheckpoint {
    sequence: u64,
    authority: crate::effect_authority::EffectAuthority,
}

pub fn capture_effect_checkpoint(session: &EffectSession) -> EffectCheckpoint {
    EffectCheckpoint {
        sequence: session.sequence,
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
    };
    let cursor = usize::try_from(checkpoint.sequence).map_err(|_| ReplayError::Divergence)?;
    let provider = session.replay.as_mut().ok_or(ReplayError::Divergence)?;
    if cursor > tape.entries.len() {
        return Err(ReplayError::TruncatedTape);
    }
    provider.cursor = cursor;
    session.sequence = checkpoint.sequence;
    session.authority = checkpoint.authority.clone();
    Ok(session)
}
