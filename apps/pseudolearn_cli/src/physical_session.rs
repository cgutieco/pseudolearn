use crate::error::CliError;
use crate::execution_options::ExecutionArguments;
use crate::physical_host::PhysicalHost;
use crate::physical_request::{READ, WRITE};
use cap_std::ambient_authority;
use cap_std::fs::Dir;
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

pub(crate) const PERMISSION_VOCABULARY: [&str; 6] = [
    "consola",
    "argumentos",
    "archivos_lectura",
    "archivos_escritura",
    "reloj",
    "temporizador",
];

pub(crate) fn host_document(execution: &ExecutionArguments) -> Option<Value> {
    if execution.grants.is_empty() {
        return None;
    }
    Some(json!({"permissions":execution.grants,"detached":true}))
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
    Ok(Some(PhysicalHost::new(root)))
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
    let pending = response
        .get("pending_effect")
        .ok_or_else(|| CliError::Operational("missing pending effect".to_owned()))?;
    let sequence = pending.get("effect_seq").cloned().unwrap_or(Value::Null);
    let reply = host.perform(pending);
    let answer = session.call(
        "effect_result",
        &json!({"resource":resource,"effect_seq":sequence,"result":reply}),
    );
    match answer.get("value") {
        Some(_) => Ok(()),
        None => Err(CliError::Operational(answer.to_string())),
    }
}
