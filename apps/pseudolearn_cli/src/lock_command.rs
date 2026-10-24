use crate::error::CliError;
use crate::messages;
use crate::options::CliOptions;
use crate::project_files::{self, LOCK_NAME};
use crate::project_report::{Stream, render};
use crate::project_session::{call, lock_packages};
use cap_std::ambient_authority;
use cap_std::fs::Dir;
use serde_json::{Value, json};
use std::path::Path;

pub fn execute_lock(options: &CliOptions) -> Result<i32, CliError> {
    let locale = &options.interface_language;
    let directory = options
        .project
        .directory
        .as_deref()
        .ok_or_else(|| CliError::Usage(messages::missing_input(locale).to_owned()))?;
    let snapshot = project_files::load(directory, locale)?;
    let packages = match lock_packages(&snapshot) {
        Ok(packages) => packages,
        Err(failures) => {
            let report = json!({"manifest_errors": failures});
            render(options, &snapshot, (&report, Stream::Error));
            return Ok(1);
        }
    };
    let built = call("build_lock", &json!({"packages": packages}))?;
    let Some(text) = built.get("lock").and_then(Value::as_str) else {
        return Err(lock_failure(locale, &built));
    };
    let target = format!("{}/{LOCK_NAME}", directory.trim_end_matches('/'));
    write_atomically(directory, text).map_err(|_| {
        CliError::Operational(messages::render(
            "unwritableOutput",
            locale,
            &[("path", &target)],
        ))
    })?;
    print!(
        "{}",
        messages::render("lockWritten", locale, &[("path", &target)])
    );
    Ok(0)
}

fn lock_failure(locale: &str, built: &Value) -> CliError {
    let code = built
        .pointer("/lock_errors/0/code")
        .and_then(Value::as_str)
        .unwrap_or("lockInvalid");
    CliError::Operational(messages::render("lockMismatch", locale, &[("code", code)]))
}

fn write_atomically(directory: &str, text: &str) -> std::io::Result<()> {
    let root = Dir::open_ambient_dir(Path::new(directory), ambient_authority())?;
    let staged = format!(".{LOCK_NAME}.partial");
    let written = root
        .write(&staged, text)
        .and_then(|()| root.rename(&staged, &root, LOCK_NAME));
    if written.is_err() {
        let _removed = root.remove_file(&staged);
    }
    written
}
