#![forbid(unsafe_code)]

use crate::error::CliError;
use crate::messages::{invalid_preference_value, missing_command, preference_saved};
use crate::options::{CliOptions, preference_file_path};

pub fn execute_preferences(options: &CliOptions, arguments: &[String]) -> Result<i32, CliError> {
    let property = match arguments.first() {
        Some(first) => first.as_str(),
        None => {
            return Err(CliError::Usage(
                missing_command(&options.interface_language).to_owned(),
            ));
        }
    };
    if property != "idioma" && property != "language" {
        return Err(CliError::Usage(invalid_preference_value(
            &options.interface_language,
            property,
            "",
        )));
    }
    let choice = match arguments.get(1) {
        Some(second) => second.as_str(),
        None => {
            return Err(CliError::Usage(invalid_preference_value(
                &options.interface_language,
                property,
                "",
            )));
        }
    };
    if choice != "es" && choice != "en" {
        return Err(CliError::Usage(invalid_preference_value(
            &options.interface_language,
            property,
            choice,
        )));
    }

    save_preference_language(choice)?;
    let message = preference_saved(&options.interface_language, choice);
    print!("{message}");
    Ok(0)
}

fn save_preference_language(choice: &str) -> Result<(), CliError> {
    let preference_path = preference_file_path()
        .ok_or_else(|| CliError::Operational("No preference path available".to_owned()))?;
    if let Some(parent) = preference_path.parent() {
        let _ = std::fs::create_dir_all(parent);
    }
    let content = format!("idioma = \"{choice}\"\n");
    std::fs::write(&preference_path, content)
        .map_err(|error| CliError::Operational(error.to_string()))
}
