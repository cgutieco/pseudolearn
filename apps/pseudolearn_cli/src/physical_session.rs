use crate::error::CliError;
use crate::execution_options::ExecutionArguments;
use crate::physical_host::PhysicalHost;
use crate::physical_request::{READ, WRITE};
use cap_std::ambient_authority;
use cap_std::fs::Dir;
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

pub(crate) const PERMISSION_VOCABULARY: [&str; 8] = [
    "consola",
    "argumentos",
    "archivos_lectura",
    "archivos_escritura",
    "reloj",
    "temporizador",
    "network",
    "red",
];

pub(crate) fn host_document(execution: &ExecutionArguments) -> Option<Value> {
    if execution.grants.is_empty() {
        return None;
    }
    let origins: Vec<&String> = execution
        .origins
        .iter()
        .chain(&execution.local_origins)
        .collect();
    Some(json!({
        "permissions":execution.grants,
        "network_origins":origins,
        "detached":true
    }))
}

pub(crate) fn open_host(execution: &ExecutionArguments) -> Result<Option<PhysicalHost>, CliError> {
    if execution.grants.is_empty() || execution.replay_tape.is_some() {
        return Ok(None);
    }
    let rights = granted_rights(&execution.grants);
    let root = match (&execution.files_root, rights) {
        (Some(path), granted) if granted != 0 => {
            let directory = Dir::open_ambient_dir(path, ambient_authority())
                .map_err(|error| CliError::Operational(error.to_string()))?;
            Some((directory, granted))
        }
        _ => None,
    };
    let policy = crate::physical_network::NetworkPolicy::from_execution(execution)
        .map_err(|error| CliError::Operational(error.code.to_owned()))?;
    let mut host = PhysicalHost::new(root);
    host.set_network_policy(policy);
    Ok(Some(host))
}

pub(crate) fn declare_network_capabilities(session: &mut ApiSession) -> Result<(), CliError> {
    let answer = session.call(
        "negotiate",
        &json!({"network_capabilities":crate::physical_network::NetworkCapabilities::value()}),
    );
    if answer.get("value").is_some() {
        Ok(())
    } else {
        Err(CliError::Operational(answer.to_string()))
    }
}

fn granted_rights(grants: &[String]) -> u8 {
    let has = |name: &str| grants.iter().any(|grant| grant == name);
    (if has("archivos_lectura") { READ } else { 0 })
        | (if has("archivos_escritura") { WRITE } else { 0 })
}

pub(crate) fn resolve_effect(
    session: &mut ApiSession,
    resource: &Value,
    response: &Value,
    host: &mut PhysicalHost,
) -> Result<(), CliError> {
    if let Some(effects) = response
        .get("pending_effects")
        .and_then(Value::as_array)
        .filter(|effects| {
            effects.len() > 1
                && effects.iter().all(|effect| {
                    effect.get("operation").and_then(Value::as_str) == Some("network_send")
                })
        })
    {
        return resolve_network_batch(session, resource, effects, host);
    }
    let pending = response
        .get("pending_effect")
        .ok_or_else(|| CliError::Operational("missing pending effect".to_owned()))?;
    let reply = host.perform(pending);
    submit_effect_result(session, resource, pending, &reply)
}

fn resolve_network_batch(
    session: &mut ApiSession,
    resource: &Value,
    effects: &[Value],
    host: &PhysicalHost,
) -> Result<(), CliError> {
    let completed = crate::physical_network_batch::perform(effects, host.network_policy())?;
    if completed.len() != effects.len() {
        return Err(CliError::Operational(
            "network batch was incomplete".to_owned(),
        ));
    }
    for (sequence, reply) in completed {
        let effect = json!({"effect_seq":sequence});
        submit_effect_result(session, resource, &effect, &reply)?;
    }
    Ok(())
}

fn submit_effect_result(
    session: &mut ApiSession,
    resource: &Value,
    pending: &Value,
    reply: &Value,
) -> Result<(), CliError> {
    let sequence = pending.get("effect_seq").cloned().unwrap_or(Value::Null);
    let answer = session.call(
        "effect_result",
        &json!({"resource":resource,"effect_seq":sequence,"result":reply}),
    );
    if answer.get("value").is_some() {
        Ok(())
    } else {
        Err(CliError::Operational(answer.to_string()))
    }
}
