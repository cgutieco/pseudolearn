use crate::{error::CliError, messages, options::CliOptions};
use pseudolearn_api::{
    ApiDiagnostic, ApiSession, ExecuteRequest, detect_vocabulary_profile,
};
use serde_json::{Value, json};
use std::io::{BufRead, Write};

pub fn execute_run(options: &CliOptions) -> Result<i32, CliError> {
    let locale = &options.interface_language;
    let path = options
        .positional_arguments
        .first()
        .ok_or_else(|| CliError::Usage(messages::missing_input(locale).to_owned()))?;
    let source = std::fs::read_to_string(path)
        .map_err(|_| CliError::Operational(messages::unreadable_input(locale, path)))?;
    let request = build_request(options, source)?;
    if options.execution.native {
        return crate::native_run_command::execute_native(options, path, request);
    }
    let mut session = ApiSession::default();
    let analysis = result(session.call("create_analysis", &json!(request)))?;
    let mut start = serde_json::to_value(&request).map_err(operational)?;
    if let Some(fields) = start.as_object_mut() {
        fields.insert(
            "analysis".to_owned(),
            analysis.get("resource").cloned().unwrap_or(Value::Null),
        );
    }
    let resource = match result(session.call("start", &start)) {
        Ok(execution) => execution.get("resource").cloned().unwrap_or(Value::Null),
        Err(error) if options.execution.replay_tape.is_some() => return Err(error),
        Err(_) => return render_rejected(options, path, &request),
    };
    let mut host = crate::physical_session::open_host(&options.execution)?;
    stream_execution(
        (&mut session, &resource, host.as_mut()),
        options,
        (path, &request.program),
    )
}

fn stream_execution(
    (session, resource, mut host): (
        &mut ApiSession,
        &Value,
        Option<&mut crate::physical_host::PhysicalHost>,
    ),
    options: &CliOptions,
    source: (&str, &str),
) -> Result<i32, CliError> {
    let mut output_bytes = 0;
    loop {
        let response =
            result(session.call("advance", &json!({"resource":resource,"batch_size":4096})))?;
        present_batch(options, source, &response, &mut output_bytes)?;
        match response
            .pointer("/termination/kind")
            .and_then(Value::as_str)
        {
            Some("running") => {}
            Some("awaiting_effect") if host.is_some() => {
                if let Some(physical) = host.as_deref_mut() {
                    crate::physical_session::resolve_effect(session, resource, &response, physical)?;
                }
            }
            Some("awaiting_input") => {
                if !feed_input(session, resource)? {
                    return finish(options, source.0, &response);
                }
            }
            _ => {
                if let Some(path) = &options.execution.record_tape {
                    crate::tape_files::persist(path, &response)?;
                }
                return finish(options, source.0, &response);
            }
        }
    }
}

fn feed_input(session: &mut ApiSession, resource: &Value) -> Result<bool, CliError> {
    let mut input = String::new();
    let count = std::io::stdin()
        .lock()
        .read_line(&mut input)
        .map_err(operational)?;
    if count == 0 {
        return Ok(false);
    }
    result(session.call(
        "input",
        &json!({"resource":resource,"text":input.trim_end_matches(['\r','\n'])}),
    ))?;
    Ok(true)
}

fn present_batch(
    options: &CliOptions,
    source: (&str, &str),
    response: &Value,
    printed: &mut usize,
) -> Result<(), CliError> {
    if options.json_output {
        return Ok(());
    }
    let output = response.get("output").and_then(Value::as_str).unwrap_or("");
    print!("{}", output.get(*printed..).unwrap_or(""));
    *printed = output.len();
    std::io::stdout().flush().map_err(operational)?;
    if options.execution.trace {
        let events = response
            .get("events")
            .and_then(Value::as_array)
            .map_or(&[][..], Vec::as_slice);
        crate::trace_output::render(source.0, source.1, &options.interface_language, events);
    }
    Ok(())
}

fn finish(options: &CliOptions, path: &str, response: &Value) -> Result<i32, CliError> {
    if options.json_output {
        println!("{response}");
    } else {
        if response
            .pointer("/termination/kind")
            .and_then(Value::as_str)
            == Some("awaiting_input")
        {
            eprint!(
                "{}",
                messages::render(
                    "inputExhausted",
                    &options.interface_language,
                    &[("path", path)]
                )
            );
        }
        let diagnostics: Vec<ApiDiagnostic> =
            serde_json::from_value(response.get("diagnostics").cloned().unwrap_or(json!([])))
                .map_err(operational)?;
        render_diagnostics(options, path, &diagnostics);
    }
    Ok(i32::from(
        response
            .pointer("/termination/kind")
            .and_then(Value::as_str)
            != Some("completed"),
    ))
}

fn render_rejected(
    options: &CliOptions,
    path: &str,
    request: &ExecuteRequest,
) -> Result<i32, CliError> {
    let response = pseudolearn_api::execute_program(request);
    if options.json_output {
        println!("{}", serde_json::to_string(&response).map_err(operational)?);
    } else {
        render_diagnostics(options, path, &response.diagnostics);
    }
    Ok(1)
}

pub(crate) fn render_diagnostics(options: &CliOptions, path: &str, diagnostics: &[ApiDiagnostic]) {
    for diagnostic in diagnostics {
        let position = (diagnostic.span.start.line, diagnostic.span.start.column);
        eprint!(
            "{}",
            messages::format_diagnostic_line(
                &options.interface_language,
                path,
                position,
                diagnostic
            )
        );
    }
}

fn result(response: Value) -> Result<Value, CliError> {
    response
        .get("value")
        .cloned()
        .ok_or_else(|| operational(response))
}

fn operational(error: impl std::fmt::Display) -> CliError {
    CliError::Operational(error.to_string())
}

pub(crate) fn build_request(options: &CliOptions, source: String) -> Result<ExecuteRequest, CliError> {
    let profile = options.vocabulary.clone().unwrap_or_else(|| {
        detect_vocabulary_profile(&source)
            .unwrap_or("es")
            .to_owned()
    });
    let execution_mode = if options.execution.replay_tape.is_some() {
        Some("replay_from_tape".to_owned())
    } else {
        None
    };
    let effect_tape = if let Some(path) = &options.execution.replay_tape {
        Some(crate::tape_files::read(path)?)
    } else {
        None
    };
    Ok(ExecuteRequest {
        program: source,
        profile,
        strictness: options.strictness.clone().unwrap_or("strict".to_owned()),
        seed: options.execution.seed.unwrap_or(42),
        observe: if options.execution.trace {
            "events"
        } else {
            "none"
        }
        .to_owned(),
        limits: options.execution.limits(),
        execution_mode,
        effect_tape,
        host: crate::physical_session::host_document(&options.execution),
        ..ExecuteRequest::default()
    })
}
