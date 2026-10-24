use crate::error::CliError;
use crate::options::CliOptions;
use crate::project_report::{Stream, has_failures, render};
use crate::project_session::{call, prepare};
use serde_json::Value;
use std::io::Write;

pub fn execute_check(options: &CliOptions) -> Result<i32, CliError> {
    let prepared = prepare(options, false)?;
    let outcome = call("analyze_project", &prepared.arguments)?;
    if options.json_output {
        println!("{outcome}");
    } else {
        render(options, &prepared.snapshot, (&outcome, Stream::Standard));
    }
    Ok(i32::from(has_failures(&outcome)))
}

pub fn execute_run(options: &CliOptions) -> Result<i32, CliError> {
    let prepared = prepare(options, true)?;
    let outcome = call("execute_project", &prepared.arguments)?;
    if options.json_output {
        println!("{outcome}");
    } else {
        let output = outcome.get("output").and_then(Value::as_str).unwrap_or("");
        print!("{output}");
        std::io::stdout()
            .flush()
            .map_err(|error| CliError::Operational(error.to_string()))?;
        render(options, &prepared.snapshot, (&outcome, Stream::Error));
    }
    Ok(i32::from(!completed(&outcome)))
}

fn completed(outcome: &Value) -> bool {
    outcome.pointer("/termination/kind").and_then(Value::as_str) == Some("completed")
}
