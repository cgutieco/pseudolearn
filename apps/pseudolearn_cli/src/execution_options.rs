use crate::{error::CliError, messages::invalid_option_value};

const MAX_HTTP_BODY_BYTES: u64 = 8_388_608;
const MAX_HTTP_WIRE_BYTES: u64 = 8_388_608;
const MAX_HTTP_HEADER_BYTES: u64 = 16_384;
const MAX_HTTP_HEADERS: u64 = 64;
const MAX_PENDING_NETWORK: u64 = 8;
const MAX_HTTP_TIMEOUT_NANOS: u64 = 30_000_000_000;
const MAX_JSON_DEPTH: usize = 64;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ExecutionArguments {
    pub seed: Option<i64>,
    pub depth: Option<usize>,
    pub statements: Option<u64>,
    pub cells: Option<u64>,
    pub tasks: Option<u64>,
    pub trace: bool,
    pub native: bool,
    pub grants: Vec<String>,
    pub files_root: Option<String>,
    pub origins: Vec<String>,
    pub local_origins: Vec<String>,
    pub test_roots: Vec<String>,
    pub record_tape: Option<String>,
    pub replay_tape: Option<String>,
}

#[cfg(test)]
#[path = "execution_options_tests.rs"]
mod execution_options_tests;

pub fn parse_numeric(
    arguments: &[String],
    index: &mut usize,
    locale: &str,
    execution: &mut ExecutionArguments,
) -> Result<(), CliError> {
    let flag = arguments.get(*index).map_or("", String::as_str);
    let next = index.saturating_add(1);
    let choice = arguments.get(next).map_or("", String::as_str);
    let invalid = || CliError::Usage(invalid_option_value(locale, flag, choice));
    match flag {
        "--semilla" | "--seed" => execution.seed = Some(choice.parse().map_err(|_| invalid())?),
        "--profundidad" | "--depth" => {
            execution.depth = Some(choice.parse().map_err(|_| invalid())?);
        }
        "--sentencias" | "--statements" => {
            execution.statements = Some(choice.parse().map_err(|_| invalid())?);
        }
        "--celdas" | "--cells" => execution.cells = Some(choice.parse().map_err(|_| invalid())?),
        "--tareas" | "--tasks" => execution.tasks = Some(choice.parse().map_err(|_| invalid())?),
        _ => return Err(invalid()),
    }
    *index = next.saturating_add(1);
    Ok(())
}

pub fn parse_tape_option(
    arguments: &[String],
    index: &mut usize,
    locale: &str,
    execution: &mut ExecutionArguments,
) -> Result<(), CliError> {
    let flag = arguments.get(*index).map_or("", String::as_str);
    let next = index.saturating_add(1);
    let choice = arguments.get(next).map_or("", String::as_str);
    if choice.is_empty() {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    match flag {
        "--grabar-cinta" | "--record-tape" => execution.record_tape = Some(choice.to_owned()),
        "--reproducir-cinta" | "--replay-tape" => execution.replay_tape = Some(choice.to_owned()),
        _ => return Err(CliError::Usage(invalid_option_value(locale, flag, choice))),
    }
    *index = next.saturating_add(1);
    Ok(())
}

pub fn parse_grant_option(
    arguments: &[String],
    index: &mut usize,
    locale: &str,
    execution: &mut ExecutionArguments,
) -> Result<(), CliError> {
    let flag = arguments.get(*index).map_or("", String::as_str);
    let next = index.saturating_add(1);
    let choice = arguments.get(next).map_or("", String::as_str);
    let invalid = || CliError::Usage(invalid_option_value(locale, flag, choice));
    match flag {
        "--conceder" | "--grant" => {
            for name in choice.split(',') {
                if !crate::physical_session::PERMISSION_VOCABULARY.contains(&name) {
                    return Err(invalid());
                }
                execution.grants.push(if name == "network" {
                    "red".to_owned()
                } else {
                    name.to_owned()
                });
            }
        }
        "--archivos" | "--files" if !choice.is_empty() => {
            execution.files_root = Some(choice.to_owned());
        }
        _ => return Err(invalid()),
    }
    *index = next.saturating_add(1);
    Ok(())
}

pub fn parse_network_option(
    arguments: &[String],
    index: &mut usize,
    locale: &str,
    execution: &mut ExecutionArguments,
) -> Result<(), CliError> {
    let flag = arguments.get(*index).map_or("", String::as_str);
    let next = index.saturating_add(1);
    let choice = arguments.get(next).map_or("", String::as_str);
    if choice.is_empty() {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    match flag {
        "--origen" | "--origin" => execution.origins.push(choice.to_owned()),
        "--origen-local" | "--local-origin" => execution.local_origins.push(choice.to_owned()),
        "--raiz-prueba" | "--test-root" => execution.test_roots.push(choice.to_owned()),
        _ => return Err(CliError::Usage(invalid_option_value(locale, flag, choice))),
    }
    *index = next.saturating_add(1);
    Ok(())
}

impl ExecutionArguments {
    pub fn limits(&self) -> pseudolearn_api::ExecutionLimits {
        pseudolearn_api::ExecutionLimits {
            depth: self.depth,
            statements: self.statements,
            cells: self.cells,
            micro_steps: None,
            tasks: self.tasks,
            channel_capacity: None,
            max_json_depth: Some(MAX_JSON_DEPTH),
            max_http_body_bytes: Some(MAX_HTTP_BODY_BYTES),
            max_http_wire_bytes: Some(MAX_HTTP_WIRE_BYTES),
            max_http_header_bytes: Some(MAX_HTTP_HEADER_BYTES),
            max_http_headers: Some(MAX_HTTP_HEADERS),
            max_pending_network: Some(MAX_PENDING_NETWORK),
            max_http_timeout_nanos: Some(MAX_HTTP_TIMEOUT_NANOS),
        }
    }
}
