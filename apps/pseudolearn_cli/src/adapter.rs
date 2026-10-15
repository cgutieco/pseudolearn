#![forbid(unsafe_code)]

use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::io::{BufRead, Write};
use std::path::{Path, PathBuf};
use std::process::{Child, Command, ExitCode, Stdio};

pub fn run_see_adapter() -> ExitCode {
    let stdin = std::io::stdin();
    let locked_stdin = stdin.lock();
    for line in locked_stdin.lines() {
        let Ok(line_text) = line else { break };
        let trimmed = line_text.trim();
        if trimmed.is_empty() {
            continue;
        }
        let parsed: Value = match serde_json::from_str(trimmed) {
            Ok(parsed_value) => parsed_value,
            Err(_) => continue,
        };
        let kind = parsed.get("kind").and_then(Value::as_str).unwrap_or("");
        match kind {
            "hello" => respond_hello(),
            "shutdown" => {
                respond_shutdown();
                return ExitCode::SUCCESS;
            }
            "cli" => respond_cli(&parsed),
            _ => respond_unsupported(),
        }
    }
    ExitCode::SUCCESS
}

fn respond_hello() {
    let response = json!({
        "kind": "hello",
        "protocol": "see-protocol/1",
        "subject": "cli",
        "subject_version": "0.1.0",
        "capabilities": ["cli"],
        "profiles": ["es", "en"],
        "strictness": ["strict", "flexible"]
    });
    send_response(&response);
}

fn respond_shutdown() {
    let response = json!({
        "kind": "shutdown"
    });
    send_response(&response);
}

fn respond_unsupported() {
    let response = json!({
        "kind": "error",
        "message": "Unsupported operation"
    });
    send_response(&response);
}

fn respond_cli(request_value: &Value) {
    let arguments = extract_arguments(request_value);
    let environment = extract_environment(request_value);
    let stdin_content = request_value
        .get("stdin")
        .and_then(Value::as_str)
        .unwrap_or("");
    let Ok(sandbox_folder) = setup_sandbox(request_value) else {
        send_response(&json!({
            "kind": "cli",
            "exit_code": 1,
            "output": "",
            "error_output": "Failed to setup sandbox folder\n"
        }));
        return;
    };

    let outcome = execute_in_sandbox(&sandbox_folder, &arguments, &environment, stdin_content);
    let _cleaned = std::fs::remove_dir_all(&sandbox_folder);
    send_response(&outcome);
}

fn extract_arguments(request_value: &Value) -> Vec<String> {
    request_value
        .get("arguments")
        .and_then(Value::as_array)
        .map_or_else(Vec::new, |array| {
            array
                .iter()
                .filter_map(Value::as_str)
                .map(str::to_owned)
                .collect()
        })
}

fn extract_environment(request_value: &Value) -> BTreeMap<String, String> {
    let mut variables = BTreeMap::new();
    if let Some(map) = request_value.get("environment").and_then(Value::as_object) {
        for (key, string_value) in map {
            if let Some(text) = string_value.as_str() {
                variables.insert(key.clone(), text.to_owned());
            }
        }
    }
    variables
}

fn setup_sandbox(request_value: &Value) -> Result<PathBuf, std::io::Error> {
    let unique_timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(0, |duration| duration.as_nanos());
    let sandbox_path = std::env::temp_dir().join(format!("pseudo_sandbox_{unique_timestamp}"));
    std::fs::create_dir_all(&sandbox_path)?;

    if let Some(files) = request_value.get("files").and_then(Value::as_object) {
        for (relative_path, file_content) in files {
            let target_file = sandbox_path.join(relative_path);
            if let Some(parent) = target_file.parent() {
                std::fs::create_dir_all(parent)?;
            }
            let text = file_content.as_str().unwrap_or("");
            std::fs::write(&target_file, text)?;
        }
    }
    Ok(sandbox_path)
}

fn execute_in_sandbox(
    sandbox_path: &Path,
    arguments: &[String],
    environment: &BTreeMap<String, String>,
    stdin_content: &str,
) -> Value {
    let Ok(mut child) = spawn_sandbox_process(sandbox_path, arguments, environment) else {
        return json!({
            "kind": "cli",
            "exit_code": 1,
            "output": "",
            "error_output": "Failed to spawn pseudo command\n"
        });
    };

    if !stdin_content.is_empty()
        && let Some(mut input_pipe) = child.stdin.take()
    {
        let _written = input_pipe.write_all(stdin_content.as_bytes());
    }

    collect_process_outcome(child, arguments)
}

fn spawn_sandbox_process(
    sandbox_path: &Path,
    arguments: &[String],
    environment: &BTreeMap<String, String>,
) -> Result<Child, std::io::Error> {
    let current_binary = std::env::current_exe().unwrap_or_else(|_| PathBuf::from("pseudo"));
    let mut command = Command::new(current_binary);
    command.current_dir(sandbox_path);
    command.args(arguments);
    command.env_clear();
    for (name, variable_value) in environment {
        command.env(name, variable_value);
    }
    if let Ok(system_path) = std::env::var("PATH") {
        command.env("PATH", system_path);
    }
    command.stdin(Stdio::piped());
    command.stdout(Stdio::piped());
    command.stderr(Stdio::piped());
    command.spawn()
}

fn collect_process_outcome(child: Child, arguments: &[String]) -> Value {
    let Ok(output) = child.wait_with_output() else {
        return json!({
            "kind": "cli",
            "exit_code": 1,
            "output": "",
            "error_output": "Failed to wait on pseudo command\n"
        });
    };

    let stdout_text = String::from_utf8_lossy(&output.stdout).into_owned();
    let stderr_text = String::from_utf8_lossy(&output.stderr).into_owned();
    let code = output.status.code().unwrap_or(1);
    let parsed_json: Option<Value> = if arguments.iter().any(|arg_text| arg_text == "--json") {
        serde_json::from_str(&stdout_text).ok()
    } else {
        None
    };

    json!({
        "kind": "cli",
        "exit_code": code,
        "output": stdout_text,
        "error_output": stderr_text,
        "json": parsed_json
    })
}

fn send_response(value: &Value) {
    let mut stdout = std::io::stdout().lock();
    if let Ok(serialized) = serde_json::to_string(value) {
        let _written = writeln!(stdout, "{serialized}");
        let _flushed = stdout.flush();
    }
}
