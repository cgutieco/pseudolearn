use crate::{error::CliError, messages::invalid_option_value};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ProjectArguments {
    pub directory: Option<String>,
    pub entry: Option<String>,
}

pub fn parse_project_option(
    arguments: &[String],
    index: &mut usize,
    locale: &str,
    project: &mut ProjectArguments,
) -> Result<(), CliError> {
    let flag = arguments.get(*index).map_or("", String::as_str);
    let next = index.saturating_add(1);
    let choice = arguments.get(next).map_or("", String::as_str);
    if choice.is_empty() || choice.starts_with("--") {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    match flag {
        "--proyecto" | "--project" => project.directory = Some(choice.to_owned()),
        _ => project.entry = Some(choice.to_owned()),
    }
    *index = next.saturating_add(1);
    Ok(())
}
