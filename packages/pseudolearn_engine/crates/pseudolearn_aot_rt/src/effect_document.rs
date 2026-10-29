use crate::effect_channel::EffectChannel;
use pseudolearn_runtime::{
    EffectSession, EffectTape, ExecutionIdentity, MemoryHostProvider, NetworkLimits,
    configure_host_authority, configure_network_limits,
};
use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
pub struct EffectInput {
    host: Option<Value>,
    identity: ExecutionIdentity,
    max_tape_bytes: Option<usize>,
    tape: Option<EffectTape>,
}

impl EffectInput {
    pub fn parse(bytes: &[u8]) -> Option<Self> {
        serde_json::from_slice(bytes).ok()
    }

    pub fn into_channel(self) -> Result<EffectChannel, String> {
        let Self {
            host,
            identity,
            max_tape_bytes,
            tape,
        } = self;
        let maximum =
            max_tape_bytes.unwrap_or(pseudolearn_runtime::tape_privacy::DEFAULT_MAX_TAPE_BYTES);
        let replaying = tape.is_some();
        let mut session = match tape {
            Some(tape) => EffectSession::from_tape(tape, &identity)
                .map_err(|error| error.code().to_owned())?,
            None => EffectSession::new(identity, maximum),
        };
        configure_host_authority(&mut session, host.as_ref())
            .map_err(|error| error.code().to_owned())?;
        let limits = network_limits(&session);
        configure_network_limits(&mut session, limits);
        let cancel_on_effect = host
            .as_ref()
            .and_then(|host| host.get("cancel_on_awaiting_effect"))
            .and_then(Value::as_u64);
        let provider = match host.as_ref().filter(|_| !replaying) {
            Some(host) => {
                MemoryHostProvider::from_value(host).map_err(|error| error.code().to_owned())?
            }
            None => MemoryHostProvider::new(),
        };
        let mut channel = EffectChannel::new(session, provider);
        channel.cancel_on_effect = cancel_on_effect;
        Ok(channel)
    }
}

fn network_limits(session: &EffectSession) -> NetworkLimits {
    let defaults = NetworkLimits::default();
    let configured = &session.tape().identity.limits;
    NetworkLimits {
        body_bytes: configured
            .get("max_http_body_bytes")
            .copied()
            .unwrap_or(defaults.body_bytes),
        wire_bytes: configured
            .get("max_http_wire_bytes")
            .copied()
            .unwrap_or(defaults.wire_bytes),
        header_bytes: configured
            .get("max_http_header_bytes")
            .copied()
            .unwrap_or(defaults.header_bytes),
        headers: configured
            .get("max_http_headers")
            .copied()
            .unwrap_or(defaults.headers),
        pending: configured
            .get("max_pending_network")
            .copied()
            .unwrap_or(defaults.pending),
        timeout_nanos: configured
            .get("max_http_timeout_nanos")
            .copied()
            .unwrap_or(defaults.timeout_nanos),
    }
}

#[derive(Serialize)]
pub struct EffectOutput {
    tape: EffectTape,
    host_calls: u64,
    open_resources: usize,
    replay_error: Option<String>,
    #[serde(skip_serializing_if = "std::ops::Not::not")]
    cancelled: bool,
}

impl EffectOutput {
    pub fn rejected(code: String) -> Self {
        Self {
            tape: EffectChannel::standalone().session().tape().clone(),
            host_calls: 0,
            open_resources: 0,
            replay_error: Some(code),
            cancelled: false,
        }
    }

    pub fn from_channel(channel: &EffectChannel) -> Self {
        let (host_calls, open_resources) = channel.host_observation();
        Self {
            tape: channel.session().tape().clone(),
            host_calls,
            open_resources,
            replay_error: channel.failure().map(|error| error.code().to_owned()),
            cancelled: channel.cancelled,
        }
    }

    pub fn render(&self) -> Option<Vec<u8>> {
        serde_json::to_vec(self).ok()
    }
}
