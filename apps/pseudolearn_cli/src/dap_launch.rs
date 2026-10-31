use crate::dap_session::DapSession;
use crate::dap_sources::SourceSnapshot;
use crate::options::CliOptions;
use serde_json::{Value, json};

pub(crate) fn launch(session: &mut DapSession, arguments: &Value) -> Result<(), String> {
    let mut options = session.options.clone().ok_or("missing launch options")?;
    crate::dap_launch_options::configure(&mut options, arguments)?;
    crate::physical_session::declare_network_capabilities(&mut session.api).map_err(cli_detail)?;
    let host = crate::physical_session::open_host(&options.execution).map_err(cli_detail)?;
    if arguments.get("project").is_some() {
        project(session, &mut options, arguments)?;
    } else {
        file(session, &options, arguments)?;
    }
    session.effects = host.map(crate::dap_effects::EffectHost::new);
    session.stop_on_entry = arguments
        .get("stopOnEntry")
        .and_then(Value::as_bool)
        .unwrap_or(true);
    let configured = session.call(
        "debug_configure",
        &json!({"resource":session.execution()?,
        "breakpoints":[],"stop_on_entry":session.stop_on_entry}),
    );
    if let Err(error) = configured {
        session.close();
        return Err(error);
    }
    session.refresh()
}

fn file(session: &mut DapSession, options: &CliOptions, arguments: &Value) -> Result<(), String> {
    let (path, text) = read_source(arguments)?;
    let request = crate::run_command::build_request(options, text.clone()).map_err(cli_detail)?;
    let analysis = session.call("create_analysis", &json!(request))?;
    session.document = analysis.get("document").cloned();
    let mut start = json!(request);
    start["analysis"] = analysis
        .get("resource")
        .cloned()
        .ok_or("missing analysis")?;
    let execution = session.call("start", &start)?;
    session.resource = Some(
        execution
            .get("resource")
            .cloned()
            .ok_or("program was rejected")?,
    );
    session.sources.snapshots.insert(
        0,
        SourceSnapshot {
            path: path.to_string_lossy().into_owned(),
            text,
            revision: None,
        },
    );
    Ok(())
}

fn read_source(arguments: &Value) -> Result<(std::path::PathBuf, String), String> {
    let program = arguments
        .get("program")
        .and_then(Value::as_str)
        .ok_or("missing program")?;
    let path = std::fs::canonicalize(program).map_err(detail)?;
    let root = arguments
        .get("workspaceRoot")
        .and_then(Value::as_str)
        .map(std::path::PathBuf::from)
        .or_else(|| path.parent().map(std::path::Path::to_path_buf))
        .ok_or("missing workspace root")?;
    let root = std::fs::canonicalize(root).map_err(detail)?;
    let relative = path
        .strip_prefix(&root)
        .map_err(|_| "program is outside workspace root")?;
    let directory =
        cap_std::fs::Dir::open_ambient_dir(&root, cap_std::ambient_authority()).map_err(detail)?;
    let text = directory.read_to_string(relative).map_err(detail)?;
    Ok((path, text))
}

fn project(
    session: &mut DapSession,
    options: &mut CliOptions,
    arguments: &Value,
) -> Result<(), String> {
    project_options(options, arguments)?;
    let mut prepared = crate::project_session::prepare(options, true).map_err(cli_detail)?;
    project_execution_options(options, &mut prepared.arguments)?;
    let started = session.call("start_project", &prepared.arguments)?;
    session.resource = Some(
        started
            .get("resource")
            .cloned()
            .ok_or_else(|| started.to_string())?,
    );
    for source in prepared.snapshot.sources {
        session.sources.snapshots.insert(
            source.source_id,
            SourceSnapshot {
                path: source.display,
                text: source.text,
                revision: None,
            },
        );
    }
    Ok(())
}

fn project_options(options: &mut CliOptions, arguments: &Value) -> Result<(), String> {
    if arguments.get("program").is_some() {
        return Err("ambiguous launch target".to_owned());
    }
    let directory = arguments
        .get("project")
        .and_then(Value::as_str)
        .ok_or("missing project")?;
    let directory = std::fs::canonicalize(directory).map_err(detail)?;
    options.project.directory = Some(directory.to_string_lossy().into_owned());
    options.project.entry = Some(
        arguments
            .get("entry")
            .and_then(Value::as_str)
            .ok_or("missing entry")?
            .to_owned(),
    );
    Ok(())
}

fn project_execution_options(options: &CliOptions, arguments: &mut Value) -> Result<(), String> {
    let request = crate::run_command::build_request(options, String::new()).map_err(cli_detail)?;
    let execution = json!(request);
    for name in [
        "seed",
        "observe",
        "limits",
        "host",
        "effect_tape",
        "execution_mode",
    ] {
        if let Some(value) = execution.get(name) {
            arguments[name] = value.clone();
        }
    }
    Ok(())
}

fn detail(error: impl std::fmt::Display) -> String {
    error.to_string()
}

fn cli_detail(error: crate::error::CliError) -> String {
    match error {
        crate::error::CliError::Usage(detail) | crate::error::CliError::Operational(detail) => {
            detail
        }
    }
}
