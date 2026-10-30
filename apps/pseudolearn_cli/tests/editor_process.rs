#![forbid(unsafe_code)]

use serde_json::Value;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

const APP_MANIFEST: &str = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n";
const GEO_MANIFEST: &str = "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n";
const MAIN: &str = "Importar geo.vectores.Doble;\nAlgoritmo Principal\nDefinir Mutable valor Como Entero <- 0;\nLeer valor;\nEscribir Doble(valor);\nFinAlgoritmo\n";
const LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";
const BROKEN_LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar total;\nFinSubProceso\n";
const FILE_PROGRAM: &str =
    "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x + 1;\nFinAlgoritmo\n";

fn sandbox(name: &str, library: &str) -> std::io::Result<PathBuf> {
    let base = Path::new(env!("CARGO_TARGET_TMPDIR"))
        .join(format!("editor-{name}-{}", std::process::id()));
    for (path, text) in [
        ("project/app/pseudolearn.toml", APP_MANIFEST),
        ("project/geo/pseudolearn.toml", GEO_MANIFEST),
        ("project/app/main.pseudo", MAIN),
        ("project/geo/vectores.pseudo", library),
        ("p.pseudo", FILE_PROGRAM),
    ] {
        let target = base.join(path);
        if let Some(parent) = target.parent() {
            std::fs::create_dir_all(parent)?;
        }
        std::fs::write(target, text)?;
    }
    Ok(base)
}

fn run_editor(
    directory: &Path,
    arguments: &[&str],
    stdin: &str,
) -> Result<(Vec<Value>, i32), String> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(arguments)
        .current_dir(directory)
        .env_clear()
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|error| error.to_string())?;
    let mut input = child.stdin.take().ok_or("missing stdin")?;
    let _ = input.write_all(stdin.as_bytes());
    drop(input);
    let output = child
        .wait_with_output()
        .map_err(|error| error.to_string())?;
    let events = String::from_utf8_lossy(&output.stdout)
        .lines()
        .map(|line| serde_json::from_str(line).map_err(|error| error.to_string()))
        .collect::<Result<Vec<Value>, String>>()?;
    Ok((events, output.status.code().unwrap_or(-1)))
}

fn finished(events: &[Value]) -> Option<&Value> {
    events.iter().find(|event| event["event"] == "finished")
}

fn printed(events: &[Value]) -> String {
    events
        .iter()
        .filter(|event| event["event"] == "output")
        .filter_map(|event| event["text"].as_str())
        .collect()
}

#[test]
fn project_runs_in_editor_mode_with_input() -> Result<(), String> {
    let base = sandbox("project", LIBRARY).map_err(|error| error.to_string())?;
    let (events, code) = run_editor(
        &base,
        &[
            "run",
            "--editor",
            "--project",
            "project",
            "--entry",
            "app/main",
        ],
        "{\"command\":\"input\",\"text\":\"21\"}\n",
    )?;
    assert_eq!(code, 0);
    assert_eq!(
        events.first().map(|event| event["event"].clone()),
        Some("hello".into())
    );
    assert_eq!(printed(&events), "42\n");
    assert_eq!(
        finished(&events).map(|event| event["status"].clone()),
        Some("completed".into())
    );
    Ok(())
}

#[test]
fn project_with_module_error_reports_diagnostics_without_running() -> Result<(), String> {
    let base = sandbox("broken", BROKEN_LIBRARY).map_err(|error| error.to_string())?;
    let (events, code) = run_editor(
        &base,
        &[
            "run",
            "--editor",
            "--project",
            "project",
            "--entry",
            "app/main",
        ],
        "",
    )?;
    assert_eq!(code, 1);
    assert!(events.iter().any(|event| event["event"] == "diagnostics"));
    assert_eq!(printed(&events), "");
    Ok(())
}

#[test]
fn single_file_runs_in_editor_mode() -> Result<(), String> {
    let base = sandbox("file", LIBRARY).map_err(|error| error.to_string())?;
    let (events, code) = run_editor(
        &base,
        &["run", "--editor", "p.pseudo"],
        "{\"command\":\"input\",\"text\":\"41\"}\n",
    )?;
    assert_eq!(code, 0);
    assert_eq!(printed(&events), "42\n");
    Ok(())
}

#[test]
fn closing_stdin_while_waiting_finishes_as_input_closed() -> Result<(), String> {
    let base = sandbox("eof", LIBRARY).map_err(|error| error.to_string())?;
    let (events, code) = run_editor(&base, &["run", "--editor", "p.pseudo"], "")?;
    assert_eq!(code, 1);
    assert_eq!(
        finished(&events).map(|event| event["status"].clone()),
        Some("input_closed".into())
    );
    Ok(())
}

#[test]
fn cancel_command_finishes_as_cancelled() -> Result<(), String> {
    let base = sandbox("cancel", LIBRARY).map_err(|error| error.to_string())?;
    let (events, code) = run_editor(
        &base,
        &["run", "--editor", "p.pseudo"],
        "{\"command\":\"cancel\"}\n",
    )?;
    assert_eq!(code, 1);
    assert_eq!(
        finished(&events).map(|event| event["status"].clone()),
        Some("cancelled".into())
    );
    Ok(())
}

#[test]
fn missing_entry_is_a_usage_error_before_any_event() -> Result<(), String> {
    let base = sandbox("noentry", LIBRARY).map_err(|error| error.to_string())?;
    let (events, code) = run_editor(&base, &["run", "--editor", "--project", "project"], "")?;
    assert_eq!(code, 2);
    assert_eq!(events, Vec::<Value>::new());
    Ok(())
}

#[test]
fn missing_file_is_an_operational_error_before_any_event() -> Result<(), String> {
    let base = sandbox("nofile", LIBRARY).map_err(|error| error.to_string())?;
    let (events, code) = run_editor(&base, &["run", "--editor", "absent.pseudo"], "")?;
    assert_ne!(code, 0);
    assert_eq!(events, Vec::<Value>::new());
    Ok(())
}
