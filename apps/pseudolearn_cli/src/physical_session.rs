use crate::error::CliError;
use crate::execution_options::ExecutionArguments;
use crate::physical_host::PhysicalHost;
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

pub(crate) fn host_document(execution: &ExecutionArguments) -> Option<Value> {
    execution
        .replay_tape
        .is_none()
        .then(|| json!({"detached":true}))
}

pub(crate) fn open_host(execution: &ExecutionArguments) -> Result<Option<PhysicalHost>, CliError> {
    if execution.replay_tape.is_some() {
        return Ok(None);
    }
    let directory = execution
        .working_directory
        .as_ref()
        .map(std::path::PathBuf::from)
        .map_or_else(std::env::current_dir, Ok)
        .map_err(|error| CliError::Operational(error.to_string()))?;
    let certificates = execution
        .test_roots
        .iter()
        .map(|path| std::fs::read(path).map_err(|error| CliError::Operational(error.to_string())))
        .collect::<Result<Vec<_>, _>>()?;
    let mut host = PhysicalHost::new(directory, execution.program_arguments.clone());
    host.set_network_policy(pseudolearn_host::NetworkPolicy::from_host_roots(
        certificates,
    ));
    Ok(Some(host))
}

pub(crate) fn declare_network_capabilities(session: &mut ApiSession) -> Result<(), CliError> {
    let answer = session.call(
        "negotiate",
        &json!({"network_capabilities":json!({"tls_validation":true,"wire_limit":"available","certificate_errors_distinguished":true,"redirect_location_visible":true,"ssrf_policy":"none","compression":"gzip"})}),
    );
    if answer.get("value").is_some() {
        Ok(())
    } else {
        Err(CliError::Operational(answer.to_string()))
    }
}

pub(crate) fn resolve_effect(
    session: &mut ApiSession,
    resource: &Value,
    response: &Value,
    host: &mut crate::dap_effects::EffectHost,
) -> Result<(), CliError> {
    let effects = response
        .get("pending_effects")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_else(|| {
            response
                .get("pending_effect")
                .cloned()
                .into_iter()
                .collect()
        });
    for effect in effects {
        host.submit(effect).map_err(CliError::Operational)?;
    }
    for (request, reply) in host.completed() {
        let answer = session.call(
            "effect_result",
            &json!({"resource":resource,
            "effect_seq":request.get("effect_seq"),"result":reply}),
        );
        if answer.get("value").is_none() {
            return Err(CliError::Operational(answer.to_string()));
        }
    }
    std::thread::sleep(std::time::Duration::from_millis(1));
    Ok(())
}
