#![forbid(unsafe_code)]

use serde_json::{Value, json};
use std::io::Write;
use std::path::PathBuf;
use std::process::{Command, Stdio};

fn acceptance_source(name: &str) -> std::io::Result<String> {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("examples/language-constructs/acceptance")
        .join(name);
    std::fs::read_to_string(path)
}

fn execute_natively(program: &str) -> std::io::Result<Value> {
    let request =
        json!({"kind":"execute","program":program,"profile":"es","seed":42,"observe":"none"});
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["--see-adapter", "aot"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()?;
    if let Some(mut pipe) = child.stdin.take() {
        writeln!(pipe, "{request}")?;
        writeln!(pipe, "{}", json!({"kind":"shutdown"}))?;
    }
    let output = child.wait_with_output()?;
    let response = String::from_utf8_lossy(&output.stdout)
        .lines()
        .filter_map(|line| serde_json::from_str::<Value>(line).ok())
        .find(|value| value.get("kind").and_then(Value::as_str) == Some("execute"));
    response.ok_or_else(|| std::io::Error::other("missing execute response"))
}

#[test]
fn native_prints_the_values_derived_from_the_construct_rules() -> std::io::Result<()> {
    let response = execute_natively(&acceptance_source("constructs.es.pseudo")?)?;
    assert_eq!(
        response.get("output"),
        Some(&json!("3:15\n7\n4:6\n12:0\n5050\n")),
        "{response}"
    );
    assert_eq!(
        response.pointer("/termination/kind"),
        Some(&json!("completed")),
        "{response}"
    );
    Ok(())
}

#[test]
fn native_releases_block_objects_at_the_end_of_each_iteration() -> std::io::Result<()> {
    let response = execute_natively(&acceptance_source("scope.es.pseudo")?)?;
    assert_eq!(response.get("output"), Some(&json!("1\n")), "{response}");
    assert_eq!(
        response.pointer("/termination/kind"),
        Some(&json!("completed")),
        "{response}"
    );
    Ok(())
}

#[test]
fn native_reports_a_syntax_error_without_running_anything() -> std::io::Result<()> {
    let response = execute_natively("Algoritmo Main\nEscribir 1 +;\nFinAlgoritmo\n")?;
    assert_eq!(response.get("output"), Some(&json!("")), "{response}");
    assert_ne!(
        response.pointer("/termination/kind"),
        Some(&json!("completed")),
        "{response}"
    );
    Ok(())
}
