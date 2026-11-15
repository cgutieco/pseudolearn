use crate::{error::CliError, options::CliOptions};
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

pub(crate) fn configure(options: &CliOptions, arguments: &mut Value) -> Result<(), CliError> {
    let request = crate::run_command::build_request(options, String::new())?;
    let execution = json!(request);
    for name in [
        "seed",
        "observe",
        "limits",
        "host",
        "effect_tape",
        "execution_mode",
    ] {
        arguments[name] = execution.get(name).cloned().unwrap_or(Value::Null);
    }
    Ok(())
}

pub(crate) fn run(options: &CliOptions, arguments: &Value) -> Result<Value, CliError> {
    let mut session = ApiSession::default();
    crate::physical_session::declare_network_capabilities(&mut session)?;
    let started = value(session.call("start_project", arguments))?;
    let Some(resource) = started.get("resource") else {
        return Ok(started);
    };
    let mut host = crate::physical_session::open_host(&options.execution)?
        .map(crate::dap_effects::EffectHost::new)
        .transpose()
        .map_err(CliError::Operational)?;
    loop {
        let response =
            value(session.call("advance", &json!({"resource":resource,"batch_size":4096})))?;
        match response
            .pointer("/termination/kind")
            .and_then(Value::as_str)
        {
            Some("running") => (),
            Some("awaiting_effect") => {
                let host = host
                    .as_mut()
                    .ok_or_else(|| operational("missing physical host"))?;
                crate::physical_session::resolve_effect(&mut session, resource, &response, host)?;
            }
            Some("awaiting_input") => {
                if !crate::run_command::feed_input(&mut session, resource, &response)? {
                    return Ok(response);
                }
            }
            _ => return Ok(response),
        }
    }
}

fn value(response: Value) -> Result<Value, CliError> {
    response
        .get("value")
        .cloned()
        .ok_or_else(|| operational(response))
}

fn operational(error: impl std::fmt::Display) -> CliError {
    CliError::Operational(error.to_string())
}
