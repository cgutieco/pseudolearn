use crate::error::CliError;
use crate::physical_network::NetworkPolicy;
use serde_json::Value;
use std::sync::{Arc, mpsc};

const MAX_PENDING_NETWORK: usize = 8;

pub(crate) fn perform(
    effects: &[Value],
    policy: &Arc<NetworkPolicy>,
) -> Result<Vec<(u64, Value)>, CliError> {
    let mut completed = Vec::new();
    for group in effects.chunks(MAX_PENDING_NETWORK) {
        completed.extend(perform_group(group, policy)?);
    }
    Ok(completed)
}

fn perform_group(
    effects: &[Value],
    policy: &Arc<NetworkPolicy>,
) -> Result<Vec<(u64, Value)>, CliError> {
    std::thread::scope(|scope| {
        let (sender, receiver) = mpsc::channel();
        for effect in effects {
            let sender = sender.clone();
            let effect = effect.clone();
            let policy = Arc::clone(policy);
            scope.spawn(move || {
                let sequence = effect
                    .get("effect_seq")
                    .and_then(Value::as_u64)
                    .unwrap_or(0);
                let reply = crate::physical_network_send::perform_with_policy(&effect, &policy);
                let _sent = sender.send((sequence, reply));
            });
        }
        drop(sender);
        let mut completed = Vec::new();
        for _ in effects {
            completed.push(
                receiver
                    .recv()
                    .map_err(|_| CliError::Operational("network worker terminated".to_owned()))?,
            );
        }
        Ok(completed)
    })
}
