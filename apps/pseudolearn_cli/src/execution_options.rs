use crate::{error::CliError, messages::invalid_option_value};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ExecutionArguments {
    pub seed: Option<i64>,
    pub depth: Option<usize>,
    pub statements: Option<u64>,
    pub cells: Option<u64>,
    pub trace: bool,
    pub native: bool,
    pub grants: Vec<String>,
    pub files_root: Option<String>,
    pub record_tape: Option<String>,
    pub replay_tape: Option<String>,
}

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
                execution.grants.push(name.to_owned());
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
